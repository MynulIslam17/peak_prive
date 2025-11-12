
import 'package:get/get.dart';
import 'package:harry_service_app/app/modules/auth/controllers/otp_controller.dart';
import 'package:harry_service_app/app/modules/auth/controllers/resend_otp_controller.dart';

class OtpBindings extends Bindings{
  @override
  void dependencies() {
    // TODO: implement dependencies

    Get.lazyPut<OtpController>(()=>OtpController());
    Get.lazyPut<ResendOtpController>(()=>ResendOtpController());

  }

}