import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/api_urls.dart';
import 'package:harry_service_app/app/data/models/network_response.dart';
import 'package:harry_service_app/app/data/models/user_model.dart';
import 'package:harry_service_app/app/data/services/network/network_caller.dart';
import 'package:harry_service_app/app/modules/auth/models/login_request_model.dart';
import 'package:harry_service_app/app/core/controllers/auth_controller.dart';

class LoginController extends GetxController {
  bool _loginProgress = false;
  String? _errorMessage;
  UserModel? _userModel;
  String? _accessToken;

  bool get loginProgress => _loginProgress;
  String? get errorMessage => _errorMessage;
  UserModel? get getUserModel => _userModel;
  String? get getAccessToken => _accessToken;

  Future<bool> login(LoginRequestModel model) async {
    bool success = false;

    _loginProgress = true;
    update();

    try {
      NetworkResponse response = await Get.find<NetworkCaller>()
          .postRequest(url: AppUrls.loginUrl, body: model.toJson());

      if (response.isSuccess) {
        final data = response.body!["data"];

        // Create user model from response
        _userModel = UserModel.fromJson(data["user"]);

        // Assign access token
        _accessToken = data["tokens"]["accessToken"];
        _userModel!.token = _accessToken;

        // Save user + token in AuthController immediately
       await Get.find<AuthController>().saveUserData(
          model: _userModel!,
          token: _accessToken!,
        );

        success = true;
        _errorMessage = null;
      } else {
        _errorMessage = response.errorMessage ?? "Login failed!";
      }
    } finally {
      _loginProgress = false;
      update();
    }

    return success;
  }
}
