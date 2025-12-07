import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:harry_service_app/app/data/models/network_response.dart';
import 'package:harry_service_app/app/data/services/network_caller.dart';

import '../views/add_restaurant_screen.dart'; // Ensure SeatItem is imported

class AddNewRestaurantController extends GetxController {
  final NetworkCaller _network = Get.find<NetworkCaller>();

  bool isLoading = false;
  String? errorMessage;
  String? createdRestaurantId;

  /// Handles POST request to create a new restaurant.
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
      // 1. Base Fields (All required for POST)
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



  /// Handles PATCH request to update existing restaurant data.
  Future<bool> updateRestaurant({
    required Map<String, dynamic> payload,
    required String restaurantId,
    required String apiUrl,
  }) async {
    isLoading = true;
    errorMessage = null;
    update();

    try {
      Map<String, String> fields = {};
      Map<String, File> files = {};

      // -----------------------------
      // 1. Map simple fields and handle thumbnail
      // -----------------------------
      // CRITICAL: Ensure all values going into the 'fields' map are strings.
      if (payload.containsKey("title")) fields["title"] = payload["title"].toString();
      if (payload.containsKey("categoryId")) fields["category"] = payload["categoryId"].toString();
      if (payload.containsKey("openTime")) fields["openTime"] = payload["openTime"].toString();
      if (payload.containsKey("closeTime")) fields["closeTime"] = payload["closeTime"].toString();
      if (payload.containsKey("serviceArea")) fields["serviceArea"] = payload["serviceArea"].toString();

      // Thumbnail: Only included if a new File was selected (due to logic in AddRestaurantScreen)
      if (payload.containsKey("thumbnail") && payload["thumbnail"] is File) {
        files["thumbnail"] = payload["thumbnail"] as File;
      }

      // -----------------------------
      // 2. Map Time Slots (Now handles List<Map<String, dynamic>>)
      // -----------------------------
      if (payload.containsKey("slots")) { // The key is 'slots' not 'timeSlots' in the final payload
        List<Map<String, dynamic>> slots = (payload["slots"] as List).cast<Map<String, dynamic>>();

        for (int i = 0; i < slots.length; i++) {
          final slot = slots[i];

          // Include ID for existing slots
          if (slot.containsKey("_id")) fields["slots[$i][_id]"] = slot["_id"].toString();

          // Include time parts
          if (slot.containsKey("startTime")) fields["slots[$i][startTime]"] = slot["startTime"].toString();
          if (slot.containsKey("endTime")) fields["slots[$i][endTime]"] = slot["endTime"].toString();
        }
      }

      // -----------------------------
      // 3. Map Seat Items (items[0] is VIP, items[1] is Normal)
      // -----------------------------
      if (payload.containsKey("items")) {
        List<Map<String, dynamic>> items = (payload["items"] as List).cast<Map<String, dynamic>>();

        for (int i = 0; i < items.length; i++) {
          final item = items[i];
          final seatType = item["seat"].toString(); // Ensure seatType is string

          fields["items[$i][seat]"] = seatType;

          // Include ID for existing items
          if (item.containsKey("_id")) fields["items[$i][_id]"] = item["_id"].toString(); // 👈 Added

          // CRITICAL FIX: Convert numeric fields to String for multipart request
          if (item.containsKey("totalQty")) fields["items[$i][totalQty]"] = item["totalQty"].toString();
          if (item.containsKey("price")) fields["items[$i][price]"] = item["price"].toString();

          if (item.containsKey("description")) fields["items[$i][description]"] = item["description"].toString();

          // Seat Photo: Only included if a new File was selected
          if (item.containsKey("photo") && item["photo"] is File) {
            // files[0] is for the first seat item (VIP), files[1] for the second (Normal)
            files["files[$i]"] = item["photo"] as File;
          }
        }
      }

      // -----------------------------
      // 4. Network Call
      // -----------------------------
      // Assuming 'apiUrl' already includes the restaurantId (e.g., /update/{id})
      NetworkResponse response = await _network.multipartRequest(
        url: apiUrl,
        method: "PATCH",
        fields: fields,
        files: files,
      );

      // -----------------------------
      // 5. Response Handling
      // -----------------------------
      if (!response.isSuccess) {
        errorMessage = response.errorMessage ?? "Failed to update restaurant.";
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

  /// Resets the controller state variables.
  void reset() {
    isLoading = false;
    errorMessage = null;
    createdRestaurantId = null;
    update();
  }
}