import 'package:get/get.dart';
import 'package:harry_service_app/app/modules/user/shared/controllers/add_account_controller.dart';
import 'package:harry_service_app/app/modules/user/shared/controllers/my_cards_controller.dart';

import '../controllers/get_balance_controller.dart';
import '../controllers/withdraw_controller.dart';

class WalletBinder extends Bindings{
  @override
  void dependencies() {

    Get.lazyPut<BalanceController>(()=>BalanceController());
    Get.lazyPut<AddAccountController>(()=>AddAccountController());
    Get.lazyPut<MyCardsController>(()=>MyCardsController());
    Get.lazyPut<WithdrawRequestController>(()=>WithdrawRequestController());

  }
}