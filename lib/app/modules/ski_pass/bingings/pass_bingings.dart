

 import 'package:get/get.dart';
import 'package:harry_service_app/app/modules/ski_pass/controllers/nav_controller.dart';

class PassBindings extends Bindings{
  @override
  void dependencies() {
    // TODO: implement dependencies


    Get.lazyPut<NavController>(()=>NavController());
    
  }




}