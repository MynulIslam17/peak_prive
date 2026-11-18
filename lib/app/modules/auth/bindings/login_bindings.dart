
import 'package:get/get.dart';
import 'package:harry_service_app/app/modules/auth/controllers/login_controller.dart';

class LoginBindings extends Bindings{
  @override
  void dependencies() {
    // TODO: implement dependencies

    Get.lazyPut<LoginController>(()=>LoginController());

  }

}