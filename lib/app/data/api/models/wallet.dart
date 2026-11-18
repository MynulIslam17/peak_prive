import '../json_read.dart';

/// Payout account: `{id, accountType, cardHolderName, card: "•••• 4242"}`.
class PayoutAccount {
  const PayoutAccount({required this.id, required this.accountType, required this.cardHolderName, required this.card, this.createdAt});

  factory PayoutAccount.fromJson(Json json) => PayoutAccount(
        id: readId(json),
        accountType: readText(json['accountType']) ?? 'Account',
        cardHolderName: readText(json['cardHolderName']) ?? '',
        card: readText(json['card']) ?? '',
        createdAt: readDate(json['createdAt']),
      );

  final String id;
  final String accountType;
  final String cardHolderName;

  /// Masked, e.g. "•••• 4242".
  final String card;
  final DateTime? createdAt;
}

/// `GET /wallet/get-my-account`.
class WalletAccount {
  const WalletAccount({required this.balance, required this.accounts});

  factory WalletAccount.fromJson(Json json) => WalletAccount(
        balance: readNum(json['balance']) ?? 0,
        accounts: readList(json['accounts'], PayoutAccount.fromJson),
      );

  final num balance;
  final List<PayoutAccount> accounts;
}

enum WithdrawalStatus { pending, paid, rejected, unknown }

/// `GET /Withdraw/my` item.
class Withdrawal {
  const Withdrawal({required this.id, required this.amount, required this.status, this.card, this.transactionId, this.note, this.createdAt, this.updatedAt});

  factory Withdrawal.fromJson(Json json) {
    final s = readString(json['status'])?.toLowerCase();
    return Withdrawal(
      id: readId(json),
      amount: readNum(json['amount']) ?? 0,
      status: WithdrawalStatus.values.firstWhere((e) => e.name == s, orElse: () => WithdrawalStatus.unknown),
      card: readText(json['card']),
      transactionId: readText(json['transactionId']),
      note: readText(json['note']),
      createdAt: readDate(json['createdAt']),
      updatedAt: readDate(json['updatedAt']),
    );
  }

  final String id;
  final num amount;
  final WithdrawalStatus status;
  final String? card;
  final String? transactionId;
  final String? note;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}

enum PaymentStatus { paid, refunded, partiallyRefunded, unknown }

/// `GET /payment/all` item (customer payment history).
class PaymentRecord {
  const PaymentRecord({
    required this.id,
    required this.amount,
    required this.refundedAmount,
    required this.currency,
    required this.status,
    this.bookingId,
    this.purpose,
    this.method,
    this.transactionId,
    this.createdAt,
    this.refundedAt,
  });

  factory PaymentRecord.fromJson(Json json) {
    final s = readString(json['status'])?.toLowerCase().replaceAll('_', '');
    return PaymentRecord(
      id: readId(json),
      bookingId: readText(json['bookingId']),
      purpose: readText(json['purpose']),
      amount: readNum(json['amount']) ?? 0,
      refundedAmount: readNum(json['refundedAmount']) ?? 0,
      currency: readString(json['currency']) ?? 'eur',
      status: switch (s) {
        'paid' => PaymentStatus.paid,
        'refunded' => PaymentStatus.refunded,
        'partiallyrefunded' => PaymentStatus.partiallyRefunded,
        _ => PaymentStatus.unknown,
      },
      method: readText(json['method']),
      transactionId: readText(json['transactionId']),
      createdAt: readDate(json['createdAt']),
      refundedAt: readDate(json['refundedAt']),
    );
  }

  final String id;
  final String? bookingId;

  /// `booking` or `late_fee`.
  final String? purpose;
  final num amount;
  final num refundedAmount;
  final String currency;
  final PaymentStatus status;
  final String? method;
  final String? transactionId;
  final DateTime? createdAt;
  final DateTime? refundedAt;

  bool get isLateFee => purpose == 'late_fee';
}
