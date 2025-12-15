import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/api_urls.dart';
import 'package:harry_service_app/app/core/controllers/auth_controller.dart';
import 'package:harry_service_app/app/data/services/network_caller.dart';
import 'package:harry_service_app/app/modules/provider/pass/models/pass_item_model.dart';

class SinglePassBookingItem extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final NetworkCaller networkCaller = Get.find<NetworkCaller>();

  SkiPassItemModel? booking;
  bool isLoading = false;
  String? errorMessage;

  /// Fetch single Ski Pass booking by ID
  Future<void> fetchBooking(String bookingId) async {
    isLoading = true;
    errorMessage = null;
    update();

    try {
      final response = await networkCaller.getRequest(
        url: AppUrls.bookingSingleItem(bookingId),
      );

      if (response.statusCode == 200 && response.body != null) {
        final data = response.body!['data'];
        booking = SkiPassItemModel.fromJson(data); // Correct model parsing
      } else {
        errorMessage = "Booking not found";
      }
    } catch (e, stackTrace) {
      debugPrint("Error fetching booking: $e\n$stackTrace");
      errorMessage = "An error occurred while fetching the booking.";
    } finally {
      isLoading = false;
      update();
    }
  }

  /// Clear controller state
  void clear() {
    booking = null;
    errorMessage = null;
    isLoading = false;
    update();
  }
}
