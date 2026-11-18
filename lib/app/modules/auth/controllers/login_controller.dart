import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/api_urls.dart';
import 'package:harry_service_app/app/data/models/network_response.dart';
import 'package:harry_service_app/app/data/models/auth_tokens.dart';
import 'package:harry_service_app/app/data/models/user_model.dart';
import 'package:harry_service_app/app/data/services/network/network_caller.dart';
import 'package:harry_service_app/app/modules/auth/models/login_request_model.dart';
import 'package:harry_service_app/app/core/controllers/auth_controller.dart';

class LoginController extends GetxController {
  bool _loginProgress = false;
  String? _errorMessage;
  UserModel? _userModel;
  String? _accessToken;
  String? _refreshToken;

  bool get loginProgress => _loginProgress;
  String? get errorMessage => _errorMessage;
  UserModel? get getUserModel => _userModel;
  String? get getAccessToken => _accessToken;
  String? get getRefreshToken => _refreshToken;

  Future<bool> login(LoginRequestModel model) async {
    bool success = false;

    _loginProgress = true;
    update();

    try {
      NetworkResponse response = await Get.find<NetworkCaller>().postRequest(
        url: AppUrls.loginUrl,
        body: model.toJson(),
      );

      if (response.isSuccess) {
        final data = response.body?["data"];
        final user = data is Map ? data["user"] : null;
        final tokens = AuthTokens.fromBody(response.body);
        if (user is! Map || !tokens.hasAccess) {
          _errorMessage = "Login failed!";
        } else {
          _userModel = UserModel.fromJson(Map<String, dynamic>.from(user));
          _accessToken = tokens.accessToken;
          _refreshToken = tokens.refreshToken;
          _userModel!.token = _accessToken;
          await Get.find<AuthController>().saveUserData(
            model: _userModel!,
            token: _accessToken!,
            refreshToken: _refreshToken,
            storeRefreshToken: true,
          );
          success = true;
          _errorMessage = null;
        }
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
