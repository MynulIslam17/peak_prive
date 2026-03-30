

import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:harry_service_app/app/modules/user/shared/controllers/all_massage_controller.dart';
import 'package:harry_service_app/app/modules/user/shared/controllers/all_restaurant_controller.dart';
import 'package:harry_service_app/app/modules/user/shared/controllers/all_transport_controller.dart';
import 'package:harry_service_app/app/modules/user/shared/controllers/get_my_booking_controller.dart';


import '../../../chats/controllers/chat_list_controller.dart';
import '../controllers/all_pass_controller.dart';
import '../controllers/all_ski_hire_controller.dart';
import '../controllers/hire_rating_controller.dart';

class BottomNavBinding extends Bindings {
  @override
  void dependencies() {


    Get.put(AllPassController());  /// pass home

    Get.put(SkiHireController()); /// hire home
    Get.put(TransportController()); /// transport home
    Get.put(MassageController()); /// massage home
    Get.put(RestaurantController()); /// massage home

    Get.put(GetMyBookingController());

    Get.put(HireRatingController());




  }
}
