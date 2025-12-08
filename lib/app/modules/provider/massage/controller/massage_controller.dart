import 'dart:io';
import 'package:get/get.dart';

import 'package:harry_service_app/app/data/models/network_response.dart';
import 'package:harry_service_app/app/data/services/network_caller.dart';

// Assuming this is the correct path for your clean model
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
      // -----------------------------
      for (int i = 0; i < priceByDurations.length; i++) {
        final item = priceByDurations[i];

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


  /// --------------------------------------------------
  /// |                 UPDATE METHOD                  |
  /// --------------------------------------------------

  /// Handles PATCH request to update an existing Massage Service Post.
  /// The full URL (including the Post ID) must be provided via the 'apiUrl'.
  Future<bool> updateMassagePost({
    required String apiUrl, // FULL API URL (e.g., /massage/12345)

    // Optional fields for update
    String? categoryId,
    String? title,
    String? openTime,
    String? closeTime,
    String? description, // Core description
    String? serviceArea,
    String? amount,
    String? benefits, // Specific benefits field
    String? ourRecommendations,
    File? file, // Optional new file
    List<MassageDuration>? priceByDurations, // Optional new duration list
  }) async {
    isLoading = true;
    errorMessage = null;
    update();

    try {
      Map<String, String> fields = {};
      Map<String, File> files = {};

      // -----------------------------
      // 1. Base Fields (Only include provided/non-null fields)
      // -----------------------------
      if (categoryId != null) fields["category"] = categoryId.trim();
      if (title != null) fields["title"] = title.trim();
      if (openTime != null) fields["openTime"] = openTime.trim();
      if (closeTime != null) fields["closeTime"] = closeTime.trim();

      // Map both description and benefits
      if (description != null) fields["description"] = description.trim();
      if (benefits != null) fields["benefits"] = benefits.trim();

      if (serviceArea != null) fields["serviceArea"] = serviceArea.trim();
      if (amount != null) fields["amount"] = amount.trim();
      if (ourRecommendations != null) fields["ourRecommendations"] = ourRecommendations.trim();

      // -----------------------------
      // 2. Price By Duration Array Fields (If provided)
      // -----------------------------
      if (priceByDurations != null) {
        for (int i = 0; i < priceByDurations.length; i++) {
          final item = priceByDurations[i];
          final itemAmount = item.amount.trim();
          final itemDuration = item.duration.trim();

          // Only include valid pairs
          if (itemAmount.isNotEmpty && itemDuration.isNotEmpty) {
            // Creates fields like: priceByDuration[0][amount]=65
            fields["priceByDuration[$i][amount]"] = itemAmount;
            fields["priceByDuration[$i][duration]"] = itemDuration;
          }
        }
      }

      // -----------------------------
      // 3. File (Only include if a new file is provided)
      // -----------------------------
      if (file != null) {
        files["file"] = file;
      }

      // -----------------------------
      // 4. Network Call (Uses PATCH method)
      // -----------------------------
      NetworkResponse response = await _network.multipartRequest(
        url: apiUrl, // Complete URL is used directly
        method: "PATCH",
        fields: fields,
        files: files,
      );

      // -----------------------------
      // 5. Response Handling
      // -----------------------------
      if (!response.isSuccess) {
        errorMessage = response.errorMessage ?? "Failed to update massage post.";
        isLoading = false;
        update();
        return false;
      }

      // Success
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

  /// Resets the controllers state variables.
  void reset() {
    isLoading = false;
    errorMessage = null;
    createdPostId = null;
    update();
  }
}