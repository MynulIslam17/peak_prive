import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/api_urls.dart';
import 'package:harry_service_app/app/data/models/network_response.dart';
import 'package:harry_service_app/app/data/services/network_caller.dart';
import '../../../../core/utils/json_helper.dart';
import '../models/get_balance_model.dart';

class BalanceController extends GetxController {
  GetBalance? getBalance;
  bool isLoading = false;
  String errorMessage = '';

  /// -----------------------------
  /// FETCH BALANCE FROM API
  /// -----------------------------
  Future<void> fetchBalance() async {
    try {
      isLoading = true;
      errorMessage = '';
      update();

      final NetworkResponse response =
      await Get.find<NetworkCaller>().getRequest(url: AppUrls.getBalanceUrl);

      if (response.statusCode == 200 && response.body != null) {
        getBalance = GetBalance.fromJson(JsonHelper.getMap(response.body)!);
      } else {
        errorMessage = 'Failed to load balance (${response.statusCode})';
      }
    } catch (e) {
      errorMessage = 'Error: $e';
    } finally {
      isLoading = false;
      update();
    }
  }

  /// -----------------------------
  /// REFRESH BALANCE
  /// Pull-to-refresh support
  /// -----------------------------
  Future<void> refreshBalance() async {
    await fetchBalance();
  }

  /// -----------------------------
  /// UPDATE SINGLE TRANSACTION
  /// -----------------------------
  void updateSingleTransaction(Transaction updatedTransaction) {
    if (getBalance?.data?.transactions != null) {
      final index = getBalance!.data!.transactions!.indexWhere(
              (t) => t.createdAt == updatedTransaction.createdAt && t.user == updatedTransaction.user);

      if (index != -1) {
        getBalance!.data!.transactions![index] = updatedTransaction;
        update(); // Notify UI
      }
    }
  }

  /// -----------------------------
  /// UPDATE BALANCE VALUE
  /// -----------------------------
  void updateBalance(int newBalance) {
    if (getBalance?.data != null) {
      getBalance!.data!.balance = newBalance;
      update();
    }
  }

  /// -----------------------------
  /// CALCULATIONS
  /// -----------------------------
  /// Total incoming money (Earn + Deposit + Receive)
  int get totalIn {
    final transactions = getBalance?.data?.transactions ?? [];
    return transactions
        .where((t) => t.flow == WalletFlowType.IN)
        .fold(0, (sum, t) => sum + (t.balance ?? 0));
  }

  /// Total outgoing money (Withdraw + Send)
  int get totalOut {
    final transactions = getBalance?.data?.transactions ?? [];
    return transactions
        .where((t) => t.flow == WalletFlowType.OUT)
        .fold(0, (sum, t) => sum + (t.balance ?? 0));
  }

  /// -----------------------------
  /// GET LATEST TRANSACTIONS (SORTED BY DATE DESC)
  /// -----------------------------
  List<Transaction> get latestTransactions {
    final transactions = getBalance?.data?.transactions ?? [];
    final sorted = [...transactions];
    sorted.sort((a, b) {
      final dateA = a.createdAt ?? DateTime(0);
      final dateB = b.createdAt ?? DateTime(0);
      return dateB.compareTo(dateA);
    });
    return sorted;
  }
}