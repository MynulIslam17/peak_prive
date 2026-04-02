
import 'dart:io';

import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../../../data/models/network_response.dart';
import '../../../../data/services/network/network_caller.dart';

class HireController extends GetxController {
  final NetworkCaller _network = Get.find<NetworkCaller>();

  bool isLoading = false;
  String? errorMessage;
  String? createdServiceId;

  // -----------------------------------------------------------
  // CREATE HIRE SERVICE
  // -----------------------------------------------------------

  Future<bool> createHireService({
    required String apiUrl,
    required File thumbnail,
    required List<File> itemImages, // files[x]
    required Map<String, dynamic> data, // all fields + productItems
  }) async {
    isLoading = true;
    errorMessage = null;
    createdServiceId = null;
    update();

    try {
      // ---------- Convert normal fields to String ----------
      final Map<String, String> fields = {};
      data.forEach((key, value) {
        if (value != null) fields[key] = value.toString().trim();
      });

      // ---------- Prepare files ----------
      final Map<String, File> files = {};

      // main thumbnail
      files["thumbnail"] = thumbnail;

      // dynamic item images
      for (int i = 0; i < itemImages.length; i++) {
        files["files[$i]"] = itemImages[i];
      }

      // ---------- Call API ----------
      final NetworkResponse response = await _network.multipartRequest(
        url: apiUrl,
        method: "POST",
        fields: fields,
        files: files,
      );

      if (!response.isSuccess) {
        errorMessage =
            response.errorMessage ?? "Failed to create hire service.";
        return false;
      }

      // If backend returns created id
      // createdServiceId = response.body?["data"]["_id"];

      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      update();
    }
  }

  // -----------------------------------------------------------
  // UPDATE HIRE SERVICE
  // -----------------------------------------------------------

  Future<bool> updateHireService({
    required String apiUrl,
    File? thumbnail,
    List<File>? itemImages,
    required Map<String, dynamic> data,
  }) async {
    isLoading = true;
    errorMessage = null;
    update();

    try {
      // -------- Convert all normal fields --------
      final Map<String, String> fields = {};
      data.forEach((key, value) {
        if (value != null) fields[key] = value.toString().trim();
      });

      // -------- Prepare files --------
      final Map<String, File> files = {};

      if (thumbnail != null) {
        files["thumbnail"] = thumbnail;
      }

      if (itemImages != null) {
        for (int i = 0; i < itemImages.length; i++) {
          files["files[$i]"] = itemImages[i];
        }
      }

      // -------- Call API --------
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
          "Failed to update hire service. Status: ${response.statusCode}";
      return false;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      update();
    }
  }
}
