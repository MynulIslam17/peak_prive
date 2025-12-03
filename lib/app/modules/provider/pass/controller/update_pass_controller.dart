import 'dart:io';
import 'package:get/get.dart';
import 'package:harry_service_app/app/data/models/network_response.dart';
import 'package:harry_service_app/app/data/services/network_caller.dart';

class UpdatePassController extends GetxController {
  final NetworkCaller _network = Get.find<NetworkCaller>();

  bool isLoading = false;
  String? errorMessage;
  String? updatedPassId;

  /// Update Ski Pass
  /// If `profileImage` is null, it will skip sending a new image
  Future<bool> updateSkiPass({
    required String passId,
    required String title,
    required String skiPassType,
    required String area,
    required String price,
    required String description,
    File? profileImage, // Optional for edit
    required List<Map<String, String>> serviceFields,
    required String ApiUrl,
  }) async {
    isLoading = true;
    errorMessage = null;
    updatedPassId = null;
    update();

    try {
      // Base fields
      Map<String, String> fields = {
        "_id": passId,
        "title": title.trim(),
        "skiPassType": skiPassType.trim(),
        "serviceArea": area.trim(),
        "amount": price.trim(),
        "description": description.trim(),
      };


      for (int i = 0; i < serviceFields.length; i++) {
        final service = serviceFields[i];
        fields["services[$i][title]"] = service["title"]!;
        fields["services[$i][description]"] = service["service"]!;
      }

      // Prepare files if profileImage is provided
      Map<String, File>? files;
      if (profileImage != null) {
        files = {"file": profileImage};
      }

      // PATCH request
      NetworkResponse response = await _network.multipartRequest(
        url: ApiUrl,
        method: "PATCH", // <-- PATCH
        fields: fields,
        files: files,
      );

      if (!response.isSuccess) {
        errorMessage = response.errorMessage ?? "Failed to update ski pass.";
        isLoading = false;
        update();
        return false;
      }

      final data = response.body?["data"];
      if (data != null && data.containsKey("_id")) {
        updatedPassId = data["_id"];
        Get.snackbar("Success", "Ski Pass updated successfully!");
      } else {
        updatedPassId = passId; // fallback
      }

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

  /// Reset state
  void reset() {
    isLoading = false;
    errorMessage = null;
    updatedPassId = null;
    update();
  }
}
