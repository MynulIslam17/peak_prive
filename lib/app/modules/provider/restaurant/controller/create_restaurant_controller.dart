import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart'; // Required for TextEditingController
import 'package:harry_service_app/app/data/models/network_response.dart';
import 'package:harry_service_app/app/data/services/network_caller.dart';

import '../views/add_restaurant_screen.dart';

class AddNewRestaurantController extends GetxController {
  final NetworkCaller _network = Get.find<NetworkCaller>();

  bool isLoading = false;
  String? errorMessage;
  String? createdRestaurantId;

  Future<bool> createRestaurant({
    required String restaurantName,
    required String categoryId,
    required String openTime,
    required String closeTime,
    required String serviceArea,
    required File thumbnailImage,
    required List<String> timeSlots,
    required List<SeatItem> seatItems,
    required String apiUrl,
    String foodType = '',
  }) async {
    isLoading = true;
    errorMessage = null;
    createdRestaurantId = null;
    update();

    try {
      // -----------------------------
      // 1. Base Fields
      // -----------------------------
      Map<String, String> fields = {
        "title": restaurantName.trim(),
        "category": categoryId.trim(),
        "openTime": openTime.trim(),
        "closeTime": closeTime.trim(),
        "serviceArea": serviceArea.trim(),
        "foodType": foodType.trim(),
      };

      // -----------------------------
      // 2. Time Slots
      // -----------------------------
      for (int i = 0; i < timeSlots.length; i++) {
        final slot = timeSlots[i].split(' - ');
        fields["slots[$i][startTime]"] = slot[0].trim();
        fields["slots[$i][endTime]"] = slot.length > 1
            ? slot[1].trim()
            : slot[0].trim();
      }

      // -----------------------------
      // 3. Seat Items
      // -----------------------------
      for (int i = 0; i < seatItems.length && i < 2; i++) {
        // max 2 items
        final item = seatItems[i];
        fields["items[$i][seat]"] = item.selectedSeatType ?? "Normal";
        fields["items[$i][totalQty]"] = item.totalSeatController.text.trim();
        fields["items[$i][price]"] = item.pricePerSeatController.text.trim();
        fields["items[$i][description]"] = item.descriptionController.text
            .trim();
      }




      // -----------------------------
      // 4. Files
      // -----------------------------
      Map<String, File> files = {
        "thumbnail": thumbnailImage, // main restaurant image
      };

      for (int i = 0; i < seatItems.length && i < 2; i++) {
        final seatImage = seatItems[i].selectedSeatImage;
        if (seatImage != null) {
          files["files[$i]"] = seatImage;

          /// files[0] and files[1]
        }
      }

      // -----------------------------
      // 5. Network Call
      // -----------------------------
      NetworkResponse response = await _network.multipartRequest(
        url: apiUrl,
        method: "POST",
        fields: fields,
        files: files,
      );

      // -----------------------------
      // 6. Response Handling
      // -----------------------------
      if (!response.isSuccess) {
        errorMessage = response.errorMessage ?? "Failed to create restaurant.";
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

  void reset() {
    isLoading = false;
    errorMessage = null;
    createdRestaurantId = null;
    update();
  }
}
