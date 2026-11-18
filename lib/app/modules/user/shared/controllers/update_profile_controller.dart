import 'dart:io';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/controllers/auth_controller.dart';
import 'package:harry_service_app/app/data/models/user_model.dart';
import 'package:harry_service_app/app/data/models/network_response.dart';
import 'package:harry_service_app/app/data/services/network/network_caller.dart';

class UpdateProfileController extends GetxController {
  final AuthController _auth = Get.find<AuthController>();
  final NetworkCaller _network = Get.find<NetworkCaller>();

  bool isLoading = false;
  String? errorMessage;
  UserModel? updatedUser;

  /// ********* UPDATE PROFILE *********
  Future<bool> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? address,
    File? profileImage,
    required String ApiUrl,
    String method = "PATCH",
  }) async {
    isLoading = true;
    errorMessage = null;
    update();

    try {
      Map<String, String> fields = {};

      if (fullName != null && fullName.trim().isNotEmpty) {
        fields["fullName"] = fullName.trim();
      }
      if (phoneNumber != null && phoneNumber.trim().isNotEmpty) {
        fields["phoneNumber"] = phoneNumber.trim();
      }
      if (address != null && address.trim().isNotEmpty) {
        fields["address"] = address.trim();
      }

      if (fields.isEmpty && profileImage == null) {
        errorMessage = "No changes to update";
        isLoading = false;
        update();
        return false;
      }

      Map<String, File>? files =
      profileImage != null ? {"file": profileImage} : null;

      NetworkResponse response = await _network.multipartRequest(
        url: ApiUrl,
        method: method,
        fields: fields,
        files: files,
      );

      if (!response.isSuccess) {
        errorMessage = response.errorMessage;
        isLoading = false;
        update();
        return false;
      }

      final data = response.body?["data"];
      if (data == null) {
        errorMessage = "Invalid server response";
        isLoading = false;
        update();
        return false;
      }

      updatedUser = UserModel.fromJson(data);

      ///  Update globally
      _auth.userModel = updatedUser;
      await _auth.saveUserData(
        model: updatedUser!,
        token: _auth.accessToken!,
      );

      ///  THIS triggers UI refresh for GetBuilder<UpdateProfileController>
      _auth.update();

      isLoading = false;
      update();

      return true;

    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      update();
      return false;
    }
  }

  void reset() {
    isLoading = false;
    errorMessage = null;
    updatedUser = null;
    update();
  }
}
