import 'dart:convert';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/controllers/auth_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/api_urls.dart';
import '../../../../data/models/network_response.dart';
import '../../../../data/services/network_caller.dart';
import '../../../../data/models/user_model.dart';

class GetProfileController extends GetxController {
  bool _fetchProgress = false;
  String? _errorMessage;
  UserModel? _userModel; /// Store the profile data in the controllers

  bool get fetchProgress => _fetchProgress;
  String? get errorMessage => _errorMessage;
  UserModel? get userModel => _userModel;

  /// Finds authController to save in local storage
  final authController = Get.find<AuthController>();

  /// Fetch the user profile from the API
  Future<bool> fetchProfile() async {
    bool success = false;

    _fetchProgress = true;
    update();

    try {
      NetworkResponse response = await Get.find<NetworkCaller>().getRequest(
        url: AppUrls.getMyProfileUrl,
      );

      if (response.isSuccess) {
        final data = response.body!['data'];

        if (data != null) {
          /// Convert the 'data' to a UserModel
          _userModel = UserModel.fromJson(data);

          /// Save the profile data to local storage for future use
          if (_userModel != null && authController.accessToken != null) {

            authController.saveUserData(model: _userModel!, token: authController.accessToken!);
            success = true;
            _errorMessage = null;
          } else {
            _errorMessage = "User data or token is null.";
          }
        } else {
          _errorMessage = "No data available in response.";
        }
      } else {
        _errorMessage = response.errorMessage ?? "Can't fetch data";
      }
    } catch (e) {
      _errorMessage = "Error occurred: $e";
    } finally {
      _fetchProgress = false;
      update();
    }

    return success;
  }
}