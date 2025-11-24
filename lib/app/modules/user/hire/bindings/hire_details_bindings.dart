import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:harry_service_app/app/modules/user/hire/contollers/hire_details_controller.dart';

class HireDetailsBinding extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies

    Get.lazyPut<HireDetailsController>(() => HireDetailsController());
  }
}
