import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/modules/user/trasnport/model/get_single_trasnport.dart';
import '../../../../core/constants/api_urls.dart';
import '../../../../data/services/network/network_caller.dart';

class SingleTransportBookingItem extends GetxController {
  final NetworkCaller networkCaller = Get.find<NetworkCaller>();

  GetSingleTransport? getSingleTransport;
  bool isLoading = false;
  String? errorMessage;

  /// Fetch single transport booking by ID
  Future<void> fetchBooking(String bookingId) async {
    isLoading = true;
    errorMessage = null;
    update(); // Notifies listeners

    try {
      final response = await networkCaller.getRequest(
        url: AppUrls.bookingSingleItem(bookingId),
      );

      if (response.statusCode == 200 && response.body != null) {
        getSingleTransport = GetSingleTransport.fromJson(response.body!);
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

  /// Clear controllers state
  void clear() {
    getSingleTransport = null;
    errorMessage = null;
    isLoading = false;
    update();
  }
}
