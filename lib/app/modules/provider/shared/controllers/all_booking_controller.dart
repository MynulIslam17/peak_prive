import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/api_urls.dart';
import 'package:harry_service_app/app/data/services/network_caller.dart';
import 'package:harry_service_app/app/modules/provider/shared/models/all_booking_model.dart';

class BookingController extends GetxController {
  /// List of bookings
  List<Result> bookings = [];

  /// Loading state
  bool isLoading = false;

  /// Error message
  String? errorMessage;

  /// Fetch bookings from API
  Future<void> fetchBookings({bool showLoader = true}) async {
    try {
      if (showLoader) {
        isLoading = true;
        update();
      }

      errorMessage = null;

      final response = await Get.find<NetworkCaller>().getRequest(
        url: AppUrls.providerBookingUrl,
      );

      if (response.statusCode == 200 && response.body?['data'] != null) {
        final dataJson = response.body!['data'] as Map<String, dynamic>;
        final allBooking = AllBookingModel.fromJson({
          'code': response.body?['code'] ?? 0,
          'message': response.body?['message'] ?? '',
          'data': dataJson,
        });

        bookings = allBooking.data?.result ?? [];
      } else {
        bookings = [];
        errorMessage = "Failed to load bookings: ${response.statusCode}";
      }
    } catch (e) {
      bookings = [];
      errorMessage = "Something went wrong: $e";
    } finally {
      if (showLoader) {
        isLoading = false;
        update();
      }
    }
  }

  /// Refresh bookings (loader can be controlled)
  Future<void> refreshBookings({bool showLoader = false}) async {
    await fetchBookings(showLoader: showLoader);
  }


}
