import 'dart:io';

import 'package:get/get.dart';
// Assuming NetworkCaller and NetworkResponse are correctly imported
import '../../../../data/models/network_response.dart';
import '../../../../data/services/network_caller.dart';

class AddNewTransportServiceController extends GetxController {
  final NetworkCaller _network = Get.find<NetworkCaller>();

  bool isLoading = false;
  String? errorMessage;
  String? createdServiceId;

  /// Handles POST request to create a new transport service.
  /// It now accepts a Map<String, dynamic> for the fields.
  Future<bool> createTransportService({
    required Map<String, dynamic> data, // Accepts map of fields
    required File file,                  // The required file
    required String apiUrl,
  }) async {
    isLoading = true;
    errorMessage = null;
    createdServiceId = null;
    update();

    try {
      // -----------------------------
      // 1. Base Fields (Convert Map<String, dynamic> to Map<String, String>)
      // -----------------------------
      Map<String, String> fields = {};
      data.forEach((key, value) {
        // Ensure all values are converted to String and trimmed for the API
        if (value != null) {
          fields[key] = value.toString().trim();
        }
      });

      // Ensure mandatory fields are present in the map if you expect them
      // Example: if (fields['title'] == null) throw Exception("Title is missing");

      // -----------------------------
      // 2. Files
      // -----------------------------
      Map<String, File> files = {
        "file": file, // Key 'file' is used here
      };

      // -----------------------------
      // 3. Network Call
      // -----------------------------
      NetworkResponse response = await _network.multipartRequest(
        url: apiUrl,
        method: "POST",
        fields: fields,
        files: files,
      );

      // -----------------------------
      // 4. Response Handling
      // -----------------------------
      if (!response.isSuccess) {
        errorMessage = response.errorMessage ?? "Failed to create transport service.";
        isLoading = false;
        update();
        return false;
      }

      // Success
      isLoading = false;
      // Optional: Extract createdServiceId from response body if your API returns it
      update();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      update();
      return false;
    }
  }
}