import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../../core/constants/api_urls.dart';
import '../../../data/models/network_response.dart';
import '../../../data/services/network/network_caller.dart';

class EmailVerifyController extends GetxController {
  bool _emailVerifyProgress = false;
  bool get emailVerifyProgress => _emailVerifyProgress;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Verify OTP with backend
  Future<bool> emailVerify(String email) async {
    Map<String, dynamic> body = {
      "email": email,
    };

    bool isSuccess = false;
    _emailVerifyProgress = true;
    update();

    try {
      // Making the network call
      NetworkResponse response = await Get.find<NetworkCaller>()
          .postRequest(url: AppUrls.verifyEmail, body: body);

      if (response.isSuccess) {
        isSuccess = true;
        _errorMessage = null; // Clear the error message if the response is successful
      } else {
        // Set the error message with the response error or a default message
        _errorMessage = response.errorMessage ?? "Failed to verify email. Please try again.";
      }
    } catch (e) {
      // Log and display a generic error message in case of any exception
      _errorMessage = "Something went wrong: $e";
    } finally {
      // Ensure progress is stopped after the request
      _emailVerifyProgress = false;
      update();
    }

    return isSuccess;
  }
}
