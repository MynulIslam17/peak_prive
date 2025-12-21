import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/api_urls.dart';
import 'package:harry_service_app/app/data/models/network_response.dart';
import 'package:harry_service_app/app/data/services/network_caller.dart';

import '../models/get_balance_model.dart';

class BalanceController extends GetxController {
  GetBalance? getBalance;
  bool isLoading = false;
  String errorMessage = '';

  /// Fetch balance from API
  Future<void> fetchBalance() async {
    try {
      isLoading = true;
      errorMessage = '';
      update();

      final NetworkResponse response =
      await Get.find<NetworkCaller>().getRequest(
        url: AppUrls.getBalanceUrl,
      );

      if (response.statusCode == 200 && response.body != null) {
        getBalance = GetBalance.fromJson(response.body!);
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

  /* ---------------------------------------------------------------------- */
  /*                               CALCULATIONS                              */
  /* ---------------------------------------------------------------------- */

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
}
