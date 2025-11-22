import 'package:get/get.dart';
import '../../../../core/constants/api_urls.dart';
import '../../../../core/controllers/nav_controller.dart';
import '../../../../data/models/network_response.dart';
import '../../../../data/services/network_caller.dart';
import '../models/booking_model.dart';

class GetMyBookingController extends GetxController {
  final serviceController = Get.find<NavController>();

  bool _isLoading = false;
  String? _errorMessage;
  BookingModel? _bookingModel;

  /// ---------- GETTERS ----------
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  BookingModel? get bookingModel => _bookingModel;

  /// All bookings
  List<Booking> get bookings => _bookingModel?.result ?? [];
  Pagination? get pagination => _bookingModel?.pagination;

  /// Product IDs
  List<String> get productIds =>
      bookings.map((b) => b.product?.id).whereType<String>().toList();

  /// ---------- API CALL ----------
  Future<bool> getMyBooking() async {
    _isLoading = true;
    update();

    _errorMessage = null;

    try {
      NetworkResponse res = await Get.find<NetworkCaller>().getRequest(
        url: AppUrls.myBookingUrl(serviceController.getServiceType),
      );

      _isLoading = false;

      if (res.isSuccess && res.body != null) {
        final data = res.body!['data'];

        _bookingModel = BookingModel.fromJson(data);

        update();
        return true;
      } else {
        _errorMessage = res.errorMessage ?? "Something went wrong";
        update();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = "Failed to load bookings: $e";
      update();
      return false;
    }
  }

  /// Filter bookings by status (returns Booking list)
  List<Booking> bookingsByStatus(String status) {
    return bookings
        .where((b) => b.bookingStatus?.toLowerCase() == status.toLowerCase())
        .toList();
  }

  /// Count helpers
  int get bookingCount => bookings.length;
  int get completedCount =>
      bookings.where((b) => b.bookingStatus?.toLowerCase() == "completed").length;
  int get pendingCount =>
      bookings.where((b) => b.bookingStatus?.toLowerCase() == "pending").length;
}
