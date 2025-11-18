

import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:harry_service_app/app/modules/user/shared/controllers/get_my_booking_controller.dart';

import '../controllers/all_pass_controller.dart';

class BottomNavBinding extends Bindings {
  @override
  void dependencies() {

    Get.put(AllPassController());
    Get.put(GetMyBookingController());

  }
}
