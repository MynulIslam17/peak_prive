import 'package:get/get.dart';
import 'package:harry_service_app/app/modules/auth/controllers/user_singup_controller.dart';

class signupBindings extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies

    Get.lazyPut<UserSignupController>(() => UserSignupController());
  }
}
