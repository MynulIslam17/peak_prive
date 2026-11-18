
import 'package:get/get.dart';

import 'package:harry_service_app/app/modules/user/shared/controllers/update_profile_controller.dart';

import '../controllers/get_profile_controller.dart';

class GetProfileBinding extends Bindings{
  @override
  void dependencies() {
    // TODO: implement dependencies

    Get.lazyPut<GetProfileController>(()=>GetProfileController());
    Get.lazyPut<UpdateProfileController>(()=>UpdateProfileController());




  }






}