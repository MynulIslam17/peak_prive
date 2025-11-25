

   import 'package:get/get.dart';
import 'package:harry_service_app/app/modules/user/massage/controllers/message_details_controller.dart';

import '../../pass/controllers/pass_booking_controller.dart';

class MessageDetailsBindings extends Bindings{
  @override
  void dependencies() {
    // TODO: implement dependencies

    Get.lazyPut<MassageDetailsController>(()=>MassageDetailsController());
    Get.lazyPut<CreateBookingController>(()=>CreateBookingController());



  }





}