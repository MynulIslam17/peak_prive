import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../../core/constants/api_urls.dart';
import '../../../data/models/network_response.dart';
import '../../../data/services/network/network_caller.dart';

class ResendOtpController extends GetxController {
  bool _resendOtpProgress = false;
  bool get resendOtpProgress => _resendOtpProgress;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Verify OTP with backend
  Future<bool> resendOtp(String email) async {
    Map<String, dynamic> body = {"email": email};

    bool isSuccess = false;
    _resendOtpProgress = true;
    update();

    try {
      NetworkResponse response = await Get.find<NetworkCaller>().postRequest(url: AppUrls.resendOtp, body: body);

      if (response.isSuccess) {
        isSuccess = true;
        _errorMessage = null;
      } else {
        _errorMessage = response.errorMessage ?? "Resend Otp failed";
      }
    } catch (e) {
      _errorMessage = "Something went wrong: $e";
    } finally {
      _resendOtpProgress = false;
      update();
    }

    return isSuccess;
  }
}
