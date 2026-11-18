import 'package:get/get.dart';
import 'package:harry_service_app/app/modules/auth/controllers/pass_reset_controller.dart';

class PassResetBindings extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies

    Get.lazyPut<PassResetController>(() => PassResetController());
  }
}
