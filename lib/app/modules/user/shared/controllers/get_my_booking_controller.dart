//
// import 'package:get/get.dart';
// import 'package:harry_service_app/app/core/constants/api_urls.dart';
// import 'package:harry_service_app/app/core/controllers/nav_controller.dart';
// import 'package:harry_service_app/app/data/models/network_response.dart';
// import 'package:harry_service_app/app/data/services/network_caller.dart';
// import '../models/booking_model.dart';
//
// class BookingController extends GetxController {
//   /// Service type controller
//   final serviceController = Get.find<NavController>();
//
//   bool _isLoading = false;
//   String? _errorMessage;
//   BookingModel? _bookingModel;
//
//   /// Getters
//   bool get isLoading => _isLoading;
//   String? get errorMessage => _errorMessage;
//   BookingModel? get bookingModel => _bookingModel;
//
//   /// Get all products from bookings
//   List<Product> get allProducts {
//     if (_bookingModel == null) return [];
//     return _bookingModel!.result
//         .map((b) => b.product)
//         .where((p) => p != null)
//         .cast<Product>()
//         .toList();
//   }
//
//   /// Fetch My Bookings from API
//   Future<bool> fetchBookings() async {
//     _isLoading = true;
//     _errorMessage = null;
//
//     NetworkResponse response = await Get.find<NetworkCaller>().getRequest(
//       url: AppUrls.myBookingUrl(serviceController.getServiceType),
//     );
//
//     _isLoading = false;
//
//     if (response.isSuccess && response.body != null) {
//       try {
//         final data = response.body!['data'];
//         final result = data['result'] as List<dynamic>? ?? [];
//
//         _bookingModel = BookingModel(
//           result: result.map((json) => Booking.fromJson(json)).toList(),
//         );
//
//         return true;
//       } catch (e) {
//         _errorMessage = "Failed to parse bookings: $e";
//         return false;
//       }
//     } else {
//       _errorMessage = response.errorMessage ?? "Something went wrong";
//       return false;
//     }
//   }
//
//   /// Count of bookings
//   int get bookingCount => _bookingModel?.result.length ?? 0;
//
//   /// Count of products (non-null)
//   int get productCount => allProducts.length;
// }
//
//
//





















import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../../core/constants/api_urls.dart';
import '../../../../core/controllers/nav_controller.dart';
import '../../../../data/models/network_response.dart';
import '../../../../data/services/network_caller.dart';
import '../models/booking_model.dart';

class GetMyBookingController extends GetxController {
  final serviceController = Get.find<NavController>();

  bool _bookingProgress = false;
  String? _errorMessage;

  // Store all bookings in a flat list
  List<Booking> _bookings = [];

  bool get bookingProgress => _bookingProgress;
  String? get errorMessage => _errorMessage;
  List<Booking> get bookings => _bookings;

  // Extract products directly
  List<Product> get products =>
      _bookings.map((b) => b.product).whereType<Product>().toList();

  /// Fetch My Booking
  Future<bool> getMyBooking() async {
    _bookingProgress = true;

    NetworkResponse response = await Get.find<NetworkCaller>().getRequest(
      url: AppUrls.myBookingUrl(serviceController.getServiceType),
    );

    _bookingProgress = false;

    if (response.isSuccess && response.body != null) {
      try {
        final data = response.body!['data'];
        final result = data['result'] as List<dynamic>? ?? [];

        // Flatten all bookings
        _bookings = result.map((e) => Booking.fromJson(e)).toList();

        return true;
      } catch (e) {
        _errorMessage = 'Failed to parse bookings: $e';
        return false;
      }
    } else {
      _errorMessage = response.errorMessage ?? "Something went wrong";
      return false;
    }
  }

  /// Filter bookings by status
  List<Product> productsByStatus(String status) {
    return _bookings
        .where((b) => b.bookingStatus == status)
        .map((b) => b.product)
        .whereType<Product>()
        .toList();
  }
}
