import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/api_urls.dart';
import 'package:harry_service_app/app/data/models/network_response.dart';
import 'package:harry_service_app/app/data/services/network/network_caller.dart';
import 'package:harry_service_app/app/modules/auth/models/signup_request_model.dart';

class UserSignupController extends GetxController {
  // Make signupProgress a reactive variable
  bool _signupProgress = false;
  String? _errorMessage;

  bool get signupProgress => _signupProgress;
  String? get errorMessage => _errorMessage;

  /// The signup method for making the API request
  Future<bool> signup(SignupRequestModel model) async {
    bool isSuccess = false;

    /// Set the signup progress to true when the request starts
    _signupProgress = true;
    update(); // This will trigger the UI to update

    try {
      // Making the network call using your network service
      NetworkResponse response = await Get.find<NetworkCaller>().postRequest(
        url: AppUrls.userSignUp,
        body: model.toJson(),
      );

      /// Set the signup progress to false once the request completes
      _signupProgress = false;
      update(); // Trigger UI update

      if (response.isSuccess) {
        _errorMessage = null;
        isSuccess = true;
      } else {
        _errorMessage = response.errorMessage;
      }
    } catch (error) {
      ///Handle any exceptions (like network issues)
      _signupProgress = false;
      _errorMessage = "An error occurred: ${error.toString()}";
      update(); // Trigger UI update
    }

    return isSuccess;
  }
}
