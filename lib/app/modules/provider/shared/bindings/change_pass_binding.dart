
import 'package:get/get.dart';
import 'package:harry_service_app/app/modules/provider/shared/controllers/change_pass_controller.dart';

class ChangePassBinding extends Bindings{
  @override
  void dependencies() {
    // TODO: implement dependencies

    Get.lazyPut<ChangePasswordController>(()=>ChangePasswordController());



  }




}