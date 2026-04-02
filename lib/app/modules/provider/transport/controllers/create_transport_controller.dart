import 'dart:io';
import 'package:get/get.dart';
import '../../../../data/models/network_response.dart';
import '../../../../data/services/network/network_caller.dart';

/// Controller to handle creating and updating Transport Services.
/// Uses multipart requests to handle images and service data.
class AddNewTransportServiceController extends GetxController {
  final NetworkCaller _network = Get.find<NetworkCaller>();

  // ----------------------- STATE VARIABLES -----------------------
  bool isLoading = false;
  String? errorMessage;
  String? createdServiceId;

  // ----------------------- CREATE SERVICE -----------------------

  Future<bool> createTransportService({
    required Map<String, dynamic> data,
    required File file,
    required String apiUrl,
  }) async {
    isLoading = true;
    errorMessage = null;
    createdServiceId = null;
    update();

    try {
      // Convert all values to string for multipart request
      final Map<String, String> fields = {};
      data.forEach((key, value) {
        if (value != null) fields[key] = value.toString().trim();
      });

      // Prepare files map
      final Map<String, File> files = {"file": file};

      // Send network request
      final NetworkResponse response = await _network.multipartRequest(
        url: apiUrl,
        method: "POST",
        fields: fields,
        files: files,
      );

      if (!response.isSuccess) {
        errorMessage = response.errorMessage ?? "Failed to create transport service.";
        return false;
      }

      // Optionally, store created ID if API returns it
      // createdServiceId = response.body?['data']['_id'];

      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      update();
    }
  }

  // ----------------------- UPDATE SERVICE -----------------------

  Future<bool> updateTransportService({
    required String serviceId,
    required Map<String, dynamic> data,
    File? file,
    required String apiUrl,
  }) async {
    isLoading = true;
    errorMessage = null;
    update();

    try {
      // Convert all values to string for multipart request
      final Map<String, String> fields = {};
      data.forEach((key, value) {
        if (value != null) fields[key] = value.toString().trim();
      });

      // Prepare files map if new image is provided
      final Map<String, File> files = {};
      if (file != null) files["file"] = file;


      // Send network request
      final NetworkResponse response = await _network.multipartRequest(
        url: apiUrl,
        method: "PATCH",
        fields: fields,
        files: files,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }

      errorMessage = response.errorMessage ??
          "Failed to update transport service. Status: ${response.statusCode}";
      return false;
    } catch (e) {
      errorMessage = "An unexpected error occurred: ${e.toString()}";
      return false;
    } finally {
      isLoading = false;
      update();
    }
  }
}
