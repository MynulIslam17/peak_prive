
import 'package:get/get.dart';
import 'package:harry_service_app/app/modules/user/pass/controllers/pass_details_controller.dart';

class SinglePassDetailsBindings extends Bindings{
  @override
  void dependencies() {
    // TODO: implement dependencies

    Get.lazyPut<PassDetailsController>(
        ()=>PassDetailsController()

    );

  }


}