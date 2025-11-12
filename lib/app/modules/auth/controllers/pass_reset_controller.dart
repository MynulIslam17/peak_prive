
import 'package:get/get.dart';
import 'package:harry_service_app/app/modules/auth/models/reset_pass_request_model.dart';

import '../../../core/constants/api_urls.dart';
import '../../../data/models/network_response.dart';
import '../../../data/services/network_caller.dart';

class PassResetController extends GetxController{

  bool _resetProgress = false;
  bool get resetProgress => _resetProgress;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Verify OTP with backend
  Future<bool> resetPassword(ResetPassRequestModel model) async {

    bool isSuccess = false;
    _resetProgress = true;
    update();

    try {
      NetworkResponse response = await Get.find<NetworkCaller>()
          .postRequest(url: AppUrls.passResetUrl, body:model.toJson());

      if (response.isSuccess) {
        isSuccess = true;
        _errorMessage = null;
      } else {
        _errorMessage = response.errorMessage ?? "Resend Otp failed";
      }
    } catch (e) {
      _errorMessage = "Something went wrong: $e";
    } finally {
      _resetProgress = false;
      update();
    }

    return isSuccess;
  }



}