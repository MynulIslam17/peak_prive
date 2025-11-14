

 import 'package:get/get.dart';
import 'package:harry_service_app/app/core/controllers/auth_controller.dart';
import 'package:harry_service_app/app/core/controllers/role_controller.dart';
import 'package:harry_service_app/app/core/utils/set_up_client.dart';
import 'package:harry_service_app/app/modules/role/views/role_selection_screen.dart';


import '../controllers/nav_controller.dart';

class AppBindings extends Bindings{
  @override
  void dependencies() {


    /// nav controller
    Get.lazyPut<NavController>(()=>NavController());


    /// role controller
   // Get.lazyPut<RoleController>(()=>RoleController());



    Get.put(setUpNetworkClient());
    Get.put(RoleController());
    Get.put(AuthController());



    
  }




}