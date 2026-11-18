import 'package:get/get.dart';

import '../controllers/wallet_controller.dart';

/// Wallet, transactions and withdraw share one [WalletController].
class WalletBinder extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<WalletController>()) {
      Get.lazyPut<WalletController>(() => WalletController(), fenix: true);
    }
  }
}
