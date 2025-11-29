import 'package:get/get.dart';
import 'package:harry_service_app/app/modules/provider/shared/controllers/provider_home_controller.dart';

class ProviderNavBindings extends Bindings{
  @override
  void dependencies() {
    // TODO: implement dependencies

    //Get.lazyPut<ProviderHomeController>(()=>ProviderHomeController());
    Get.put(ProviderHomeController());
  }

}