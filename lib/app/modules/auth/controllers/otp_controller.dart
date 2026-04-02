import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/api_urls.dart';
import 'package:harry_service_app/app/data/models/network_response.dart';
import 'package:harry_service_app/app/data/services/network/network_caller.dart';

import '../models/otp_request_model.dart';


class OtpController extends GetxController {
  bool _otpProgress = false;
  bool get otpProgress => _otpProgress;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Verify OTP with backend
  Future<bool> otpVerify(OtpRequestModel model) async {
    bool isSuccess = false;
    _otpProgress = true;
    update();

    try {
      NetworkResponse response = await Get.find<NetworkCaller>()
          .postRequest(url: AppUrls.verifyOtp, body: model.toJson());

      if (response.isSuccess) {
        isSuccess = true;
        _errorMessage = null;
      } else {
        _errorMessage = response.errorMessage ?? "OTP verification failed";
      }
    } catch (e) {
      _errorMessage = "Something went wrong: $e";
    } finally {
      _otpProgress = false;
      update();
    }

    return isSuccess;
  }
}
