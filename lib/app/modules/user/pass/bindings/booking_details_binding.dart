import 'package:get/get.dart';
import 'package:harry_service_app/app/modules/user/pass/controllers/pass_booking_controller.dart';


class BookingDetailsBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateBookingController>(() => CreateBookingController());
  }
}
