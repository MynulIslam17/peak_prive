

import 'dart:io';
import 'package:get/get.dart';

import 'package:harry_service_app/app/data/models/network_response.dart';
import 'package:harry_service_app/app/data/services/network_caller.dart';

import '../models/price_duration_model.dart';


class AddNewMassageController extends GetxController {
  final NetworkCaller _network = Get.find<NetworkCaller>();

  // State variables
  bool isLoading = false;
  String? errorMessage;
  String? createdPostId;

  /// Handles POST request to create a new Massage Service Post using
  /// multipart/form-data.
  Future<bool> createMassagePost({
    required String categoryId,
    required String title,
    required String openTime,
    required String closeTime,
    required String description,
    required String serviceArea,
    required String amount, // Base amount
    required String benefits,
    required String ourRecommendations,
    required File file, // The main image/file
    // Now using the clean MassageDuration model
    required List<MassageDuration> priceByDurations,
    required String apiUrl,
  }) async {
    isLoading = true;
    errorMessage = null;
    createdPostId = null;
    update();

    try {
      // -----------------------------
      // 1. Base Fields (Map<String, String>)
      // -----------------------------
      Map<String, String> fields = {
        "category": categoryId.trim(),
        "title": title.trim(),
        "openTime": openTime.trim(),
        "closeTime": closeTime.trim(),
        "description": description.trim(),
        "serviceArea": serviceArea.trim(),
        "amount": amount.trim(),
        "benefits": benefits.trim(),
        "ourRecommendations": ourRecommendations.trim(),
      };

      // -----------------------------
      // 2. Price By Duration Array Fields
      // Iterates over the clean data model (MassageDuration)
      // -----------------------------
      for (int i = 0; i < priceByDurations.length; i++) {
        final item = priceByDurations[i];

        // Data is accessed directly from the model fields (not controllers)
        final itemAmount = item.amount.trim();
        final itemDuration = item.duration.trim();

        // Only include non-empty items
        if (itemAmount.isNotEmpty && itemDuration.isNotEmpty) {
          // Creates fields like: priceByDuration[0][amount]=65
          fields["priceByDuration[$i][amount]"] = itemAmount;
          fields["priceByDuration[$i][duration]"] = itemDuration;
        }
      }

      // -----------------------------
      // 3. File (Map<String, File>)
      // -----------------------------
      Map<String, File> files = {
        "file": file,
      };

      // -----------------------------
      // 4. Network Call
      // -----------------------------
      NetworkResponse response = await _network.multipartRequest(
        url: apiUrl,
        method: "POST",
        fields: fields,
        files: files,
      );

      // -----------------------------
      // 5. Response Handling
      // -----------------------------
      if (!response.isSuccess) {
        errorMessage = response.errorMessage ?? "Failed to create massage post.";
        isLoading = false;
        update();
        return false;
      }

      // Success
      if (response.body != null && response.body!['data'] != null) {
        createdPostId = response.body!['data']['_id']?.toString();
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

  /// Resets the controller state variables.
  void reset() {
    isLoading = false;
    errorMessage = null;
    createdPostId = null;
    update();
  }
}