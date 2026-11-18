import 'package:get/get.dart';

import '../../../../core/controllers/auth_controller.dart';
import '../../../../core/utils/price_label.dart';
import '../../../../data/api/peak_api.dart';

/// Wallet for providers (balance, payout accounts, withdrawals) and payment
/// history for customers. One controller for the wallet, history and
/// withdraw screens.
class WalletController extends GetxController {
  WalletController({bool? isProvider}) : _isProvider = isProvider;

  final bool? _isProvider;

  /// Providers have a balance and withdrawals; customers see their payments.
  bool get isProvider =>
      _isProvider ??
      (Get.isRegistered<AuthController>() &&
          (Get.find<AuthController>().role ?? 'User') != 'User');

  WalletApi get _api => Get.find<PeakApi>().wallet;

  static const pageSize = 20;

  // ── balance + accounts ──
  num? balance;
  List<PayoutAccount> accounts = const [];
  bool isLoading = false;
  String? errorMessage;

  // ── activity (withdrawals for providers, payments for customers) ──
  final List<Withdrawal> withdrawals = [];
  final List<PaymentRecord> payments = [];
  bool isActivityLoading = false;
  bool isLoadingMore = false;
  bool hasMore = false;
  String? activityError;
  int _page = 1;

  // ── actions ──
  bool isWithdrawing = false;
  bool isAddingAccount = false;

  bool get hasActivity => isProvider ? withdrawals.isNotEmpty : payments.isNotEmpty;

  /// Wallet screen: balance/accounts and the first page of activity.
  Future<void> load() async {
    await Future.wait([if (isProvider) loadAccount(), loadActivity()]);
  }

  Future<void> loadAccount() async {
    isLoading = balance == null;
    errorMessage = null;
    update();
    final r = await _api.account();
    isLoading = false;
    if (r.isSuccess) {
      balance = r.data!.balance;
      accounts = r.data!.accounts;
    } else {
      errorMessage = r.errorMessage;
    }
    update();
  }

  Future<void> loadActivity() async {
    isActivityLoading = !hasActivity;
    activityError = null;
    update();
    final ok = await _fetchPage(1, replace: true);
    isActivityLoading = false;
    if (ok) _page = 1;
    update();
  }

  Future<void> loadMoreActivity() async {
    if (!hasMore || isLoadingMore || isActivityLoading) return;
    isLoadingMore = true;
    update();
    if (await _fetchPage(_page + 1, replace: false)) _page++;
    isLoadingMore = false;
    update();
  }

  Future<bool> _fetchPage(int page, {required bool replace}) async {
    if (isProvider) {
      final r = await _api.withdrawals(page: page, limit: pageSize);
      if (!r.isSuccess) {
        activityError = r.errorMessage;
        return false;
      }
      if (replace) withdrawals.clear();
      final known = withdrawals.map((w) => w.id).toSet();
      withdrawals.addAll(r.data!.items.where((w) => !known.contains(w.id)));
      hasMore = r.data!.hasMore;
    } else {
      final r = await _api.payments(page: page, limit: pageSize);
      if (!r.isSuccess) {
        activityError = r.errorMessage;
        return false;
      }
      if (replace) payments.clear();
      final known = payments.map((p) => p.id).toSet();
      payments.addAll(r.data!.items.where((p) => !known.contains(p.id)));
      hasMore = r.data!.hasMore;
    }
    return true;
  }

  /// Checks the typed amount. Returns a message, or null when it's fine.
  String? validateAmount(String text) {
    final amount = parseAmount(text);
    if (amount == null || amount <= 0) return 'Enter an amount greater than €0.';
    final b = balance ?? 0;
    if (amount > b) {
      return 'Your balance is ${euroLabel(b)}. You asked for ${euroLabel(amount)}.';
    }
    return null;
  }

  /// "12,50" and "12.50" both work.
  static num? parseAmount(String text) {
    final t = text.trim().replaceAll(',', '.').replaceAll('€', '').trim();
    final v = num.tryParse(t);
    if (v == null || !v.isFinite) return null;
    return v;
  }

  /// Sends a withdrawal. Returns null on success, or a message to show.
  /// The amount is reserved at once, so balance and history are reloaded.
  Future<String?> withdraw({required String? accountId, required String amountText}) async {
    if (isWithdrawing) return null;
    if (accountId == null || accountId.isEmpty) return 'Choose where to send the money.';
    final problem = validateAmount(amountText);
    if (problem != null) return problem;
    isWithdrawing = true;
    update();
    final r = await _api.withdraw(accountId: accountId, amount: parseAmount(amountText)!, balance: balance);
    isWithdrawing = false;
    update();
    if (!r.isSuccess) {
      // The balance may have changed elsewhere; show the real one.
      if (!r.failure!.isOffline) await loadAccount();
      return r.errorMessage;
    }
    await Future.wait([loadAccount(), loadActivity()]);
    return null;
  }

  /// Adds a payout account. Returns null on success, or a message to show.
  Future<String?> addAccount({
    required String accountType,
    required String cardHolderName,
    required String cardNumber,
  }) async {
    if (isAddingAccount) return null;
    final digits = cardNumber.replaceAll(RegExp(r'[\s-]'), '');
    if (cardHolderName.trim().isEmpty || digits.isEmpty) {
      return 'Fill in the account holder and number.';
    }
    if (!RegExp(r'^\d+$').hasMatch(digits)) return 'Use digits only for the account number.';
    if (digits.length < 8) return 'The account number must be at least 8 digits.';
    isAddingAccount = true;
    update();
    final r = await _api.addAccount(accountType: accountType, cardNumber: digits, cardHolderName: cardHolderName);
    isAddingAccount = false;
    update();
    if (!r.isSuccess) return r.errorMessage;
    await loadAccount();
    return null;
  }
}

/// Status line for a withdrawal in the history.
String withdrawalStatusText(Withdrawal w) => switch (w.status) {
      WithdrawalStatus.pending => 'Pending',
      WithdrawalStatus.paid => w.card == null ? 'Paid' : 'Paid to ${w.card}',
      WithdrawalStatus.rejected => 'Rejected — returned to your balance',
      WithdrawalStatus.unknown => 'Processing',
    };

/// Title for a customer payment.
String paymentTitle(PaymentRecord p) => p.isLateFee ? 'Late fee' : 'Booking payment';

/// Status line for a customer payment.
String paymentStatusText(PaymentRecord p) => switch (p.status) {
      PaymentStatus.paid => 'Paid',
      PaymentStatus.refunded => 'Refunded to your card',
      PaymentStatus.partiallyRefunded => '${euroLabel(p.refundedAmount)} refunded to your card',
      PaymentStatus.unknown => 'Processing',
    };
