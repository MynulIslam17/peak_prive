import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/api_urls.dart';
import '../../../../data/services/network_caller.dart';

import '../models/get_single_restarant.dart';

class SingleRestaurantBookingItem extends GetxController {
  final NetworkCaller networkCaller = Get.find<NetworkCaller>();

  GetSingleRestaurant? getSingleRestaurant;
  bool isLoading = false;
  String? errorMessage;

  /// Fetch single Restaurant booking by ID
  Future<void> fetchBooking(String bookingId) async {
    isLoading = true;
    errorMessage = null;
    update();

    try {
      final response = await networkCaller.getRequest(
        url: AppUrls.bookingSingleItem(bookingId),
      );

      if (response.statusCode == 200 && response.body != null) {
        getSingleRestaurant =
            GetSingleRestaurant.fromJson(response.body!);
      } else {
        errorMessage = "Booking not found";
      }
    } catch (e) {
      errorMessage = "Failed to load booking";
      debugPrint(e.toString());
    } finally {
      isLoading = false;
      update();
    }
  }

  void clear() {
    getSingleRestaurant = null;
    errorMessage = null;
    isLoading = false;
    update();
  }
}
