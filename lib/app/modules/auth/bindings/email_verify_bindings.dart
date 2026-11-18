import 'package:get/get.dart';
import 'package:harry_service_app/app/modules/auth/controllers/email_verify_controller.dart';

class EmailVerifyBindings extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies

    Get.lazyPut<EmailVerifyController>(() => EmailVerifyController());
  }
}
