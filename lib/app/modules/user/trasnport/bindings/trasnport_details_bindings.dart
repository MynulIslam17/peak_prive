
import 'package:get/get.dart';
import 'package:harry_service_app/app/modules/user/pass/controllers/pass_booking_controller.dart';
import 'package:harry_service_app/app/modules/user/trasnport/controlers/trasnport_details_controller.dart';

class TransportDetailsBindings extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut<TransportDetailsController>(()=>TransportDetailsController());
    Get.lazyPut<CreateBookingController>(()=>CreateBookingController());

  }

}