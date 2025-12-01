import 'dart:io';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:harry_service_app/app/data/models/network_response.dart';
import 'package:harry_service_app/app/data/services/network_caller.dart';

class CreatePassController extends GetxController {
  final NetworkCaller _network = Get.find<NetworkCaller>();

  bool isLoading = false;
  String? errorMessage;
  String? createdPassId;

  Future<bool> createSkiPass({
    required String title,
    required String skiPassType,
    required String area,
    required String price,
    required String description,
    required File profileImage,
    required List<Map<String, String>> serviceFields,
    required String ApiUrl,
  }) async {
    isLoading = true;
    errorMessage = null;
    createdPassId = null;
    update();

    try {
      // Base fields
      Map<String, String> fields = {
        "title": title.trim(),
        "skiPassType": skiPassType.trim(),
        "serviceArea": area.trim(),
        "amount": price.trim(),
        "description": description.trim(),
      };

      // Convert serviceFields into separate indexed entries for multipart
      for (int i = 0; i < serviceFields.length; i++) {
        final service = serviceFields[i];
        fields["services[$i][title]"] = service["title"]!;
        fields["services[$i][description]"] = service["service"]!;
      }

      // File
      Map<String, File> files = {"file": profileImage};

      // Call network
      NetworkResponse response = await _network.multipartRequest(
        url: ApiUrl,
        method: "POST",
        fields: fields,
        files: files,
      );

      if (!response.isSuccess) {
        errorMessage = response.errorMessage ?? "Failed to create ski pass.";
        isLoading = false;
        update();
        return false;
      }

      final data = response.body?["data"];
      if (data != null && data.containsKey("_id")) {
        createdPassId = data["_id"];
        Get.snackbar("Success", "Ski Pass created successfully!");
      } else {
        createdPassId = "Pass creation confirmed";
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

  void reset() {
    isLoading = false;
    errorMessage = null;
    createdPassId = null;
    update();
  }
}
