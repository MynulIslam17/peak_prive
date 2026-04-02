import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:harry_service_app/app/modules/user/massage/models/get_single_massage.dart';
import '../../../../core/constants/api_urls.dart';
import '../../../../data/services/network/network_caller.dart';

class SingleMassageBookingItem extends GetxController {
  final NetworkCaller _networkCaller = Get.find<NetworkCaller>();

  GetSingleMassage? getSingleMassage;
  bool isLoading = false;
  String? errorMessage;

  /// ---------------- FETCH SINGLE MASSAGE BOOKING ----------------
  Future<void> fetchBooking(String bookingId) async {
    isLoading = true;
    errorMessage = null;
    update();

    try {
      final response = await _networkCaller.getRequest(
        url: AppUrls.bookingSingleItem(bookingId),
      );

      if (response.statusCode == 200 && response.body != null) {
        getSingleMassage = GetSingleMassage.fromJson(response.body!);
      } else {
        errorMessage = "Massage booking not found";
      }
    } catch (e, stackTrace) {
      errorMessage = "Failed to load massage booking";
      debugPrint("Massage Booking Error: $e");
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      isLoading = false;
      update();
    }
  }

  /// ---------------- GETTERS (UI FRIENDLY) ----------------
  MassageBookingData? get bookingData => getSingleMassage?.data;

  bool get hasData => bookingData != null;

  /// ---------------- CLEAR STATE ----------------
  void clear() {
    getSingleMassage = null;
    errorMessage = null;
    isLoading = false;
    update();
  }

  @override
  void onClose() {
    clear();
    super.onClose();
  }
}
