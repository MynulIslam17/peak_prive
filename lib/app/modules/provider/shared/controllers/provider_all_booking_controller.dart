import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../../core/constants/api_urls.dart';
import '../../../../core/controllers/auth_controller.dart';
import '../../../../data/services/network_caller.dart';
import '../models/restaurant_bookin_model.dart';
import '../models/ski_pass_booking_model.dart';

class ProviderBookingController extends GetxController {
  final authController = Get.find<AuthController>();

  /// SkiPass bookings
  List<Result> bookingResultsList = [];

  /// Restaurant bookings
  List<RestaurantResult> restaurantList = [];

  bool isLoading = false;
  String? errorMessage;

  Future<bool> fetchProviderBookings() async {
    try {
      isLoading = true;
      errorMessage = null;

      // Clear previous data
      bookingResultsList.clear();
      restaurantList.clear();

      update();

      final response = await Get.find<NetworkCaller>()
          .getRequest(url: AppUrls.providerBookingUrl);

      if (response.statusCode == 200) {
        final data = response.body?['data'];
        final resultList = data?['result'] as List? ?? [];

        if (authController.userModel!.providerType == "SkiPass") {
          bookingResultsList = resultList
              .map((e) => Result.fromJson(e as Map<String, dynamic>))
              .toList();
        } else if (authController.userModel!.providerType == "Restaurant") {
          restaurantList = resultList
              .map((e) => RestaurantResult.fromJson(e as Map<String, dynamic>))
              .toList();
        }

        return true;
      } else {
        errorMessage = "Failed to load data: ${response.statusCode}";
        bookingResultsList.clear();
        restaurantList.clear();
        return false;
      }
    } catch (e) {
      errorMessage = "Something went wrong: $e";
      bookingResultsList.clear();
      restaurantList.clear();
      return false;
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> refreshData() async {
    await fetchProviderBookings();
  }
}
