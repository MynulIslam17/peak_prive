import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/api_urls.dart';
import 'package:harry_service_app/app/data/models/network_response.dart';
import 'package:harry_service_app/app/data/services/network/network_caller.dart';
import 'package:harry_service_app/app/modules/provider/shared/models/change_pass_request_model.dart';

class ChangePasswordController extends GetxController {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Change password API call
  Future<bool> changePassword(ChangePassRequestModel model) async {
    _isLoading = true;
    _errorMessage = null;
    update();

    try {


      /// Call API
      NetworkResponse response = await Get.find<NetworkCaller>()
          .postRequest(url: AppUrls.changePasswordUrl, body: model.toJson());

      _isLoading = false;
       update();

      if (response.isSuccess) {
        _errorMessage = null;
        return true;
      } else {
        ///if  API failed
        _errorMessage = response.errorMessage ?? "Failed to change password";
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      update();
      return false;
    }
  }

  /// Reset state if needed
  void reset() {
    _isLoading = false;
    _errorMessage = null;
    update();
  }
}
