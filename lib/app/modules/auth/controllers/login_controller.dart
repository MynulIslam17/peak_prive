import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/api_urls.dart';
import 'package:harry_service_app/app/data/models/network_response.dart';
import 'package:harry_service_app/app/data/models/user_model.dart';
import 'package:harry_service_app/app/data/services/network_caller.dart';
import 'package:harry_service_app/app/modules/auth/models/login_request_model.dart';

class LoginController extends GetxController {

  // ==========================
  // State variables
  // ==========================
  bool _loginProgress = false;
  String? _errorMessage;
  UserModel? _userModel;
  String? _accessToken;

  // ==========================
  // Getters
  // ==========================
  bool get loginProgress => _loginProgress;
  String? get errorMessage => _errorMessage;
  UserModel? get getUserModel => _userModel;
  String? get getAccessToken => _accessToken;

  // ==========================
  // Methods
  // ==========================
  Future<bool> login(LoginRequestModel model) async {
    bool success = false;

    _loginProgress = true;
    update();

    NetworkResponse response = await Get.find<NetworkCaller>()
        .postRequest(url: AppUrls.loginUrl, body: model.toJson());

    _loginProgress = false;

    if (response.isSuccess) {
      // Login success
      final userdata = response.body!["data"]["user"];
      _userModel = UserModel.fromJson(userdata);

      _accessToken = response.body!["tokens"]["accessToken"];

      success = true;
      _errorMessage = null;
    } else {
      // Login failed
      _errorMessage = response.errorMessage;
    }

    update();
    return success;
  }
}
