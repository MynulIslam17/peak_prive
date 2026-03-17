import 'package:get/get.dart';
import '../../../../core/constants/api_urls.dart';
import '../../../../core/controllers/nav_controller.dart';
import '../../../../data/models/network_response.dart';
import '../../../../data/services/network_caller.dart';
import '../models/booking_model.dart';

class GetMyBookingController extends GetxController {
  final serviceController = Get.find<NavController>();

  // Per-status state
  final Map<String, bool> _isLoading = {
    'Active': false,
    'Completed': false,
    'Cancelled': false,
  };
  final Map<String, bool> _isMoreLoading = {
    'Active': false,
    'Completed': false,
    'Cancelled': false,
  };
  final Map<String, bool> _hasMore = {
    'Active': true,
    'Completed': true,
    'Cancelled': true,
  };
  final Map<String, int> _page = {
    'Active': 1,
    'Completed': 1,
    'Cancelled': 1,
  };
  final Map<String, BookingModel?> _bookingModels = {
    'Active': null,
    'Completed': null,
    'Cancelled': null,
  };
  final Map<String, String?> _errorMessages = {
    'Active': null,
    'Completed': null,
    'Cancelled': null,
  };
  // Track which tabs have been fetched at least once
  final Map<String, bool> _fetched = {
    'Active': false,
    'Completed': false,
    'Cancelled': false,
  };


  // In GetMyBookingController, ensure this is accessible
  bool hasAttemptedFetch(String status) => _fetched[status] ?? false;

  final int _limit;
  GetMyBookingController({int limit = 7}) : _limit = limit;

  // Per-status getters
  bool isLoadingFor(String status) => _isLoading[status] ?? false;
  bool isMoreLoadingFor(String status) => _isMoreLoading[status] ?? false;
  bool hasMoreFor(String status) => _hasMore[status] ?? false;
  String? errorMessageFor(String status) => _errorMessages[status];
  List<Booking> bookingsFor(String status) =>
      _bookingModels[status]?.result ?? [];
  bool isFetchedFor(String status) => _fetched[status] ?? false;

  Future<bool> getMyBooking(String status, {bool isLoadMore = false}) async {
    if (isLoadMore) {
      if ((_isMoreLoading[status] ?? false) ||
          (_isLoading[status] ?? false) ||
          !(_hasMore[status] ?? false)) return false;
      _isMoreLoading[status] = true;
    } else {
      if (_isLoading[status] ?? false) return false;
      _isLoading[status] = true;
      _page[status] = 1;
      _hasMore[status] = true;
      _bookingModels[status] = null;
    }

    update();
    _errorMessages[status] = null;

    try {
      String url = AppUrls.myBookingUrl(serviceController.getServiceType);
      url += url.contains('?')
          ? '&page=${_page[status]}&limit=$_limit&bookingStatus=$status'
          : '?page=${_page[status]}&limit=$_limit&bookingStatus=$status';

      NetworkResponse res =
      await Get.find<NetworkCaller>().getRequest(url: url);

      if (res.isSuccess && res.body != null) {
        final data = res.body!['data'];
        final BookingModel newModel = BookingModel.fromJson(data);

        if (isLoadMore && _bookingModels[status] != null) {
          _bookingModels[status] = BookingModel(
            pagination: newModel.pagination,
            result: [..._bookingModels[status]!.result, ...newModel.result],
          );
        } else {
          _bookingModels[status] = newModel;
        }

        final pg = newModel.pagination;
        if (pg != null) {
          _hasMore[status] = (_page[status] ?? 1) < pg.totalPages;
          _page[status] = (_page[status] ?? 1) + 1;
        } else {
          _hasMore[status] = false;
        }

        _fetched[status] = true;
        return true;
      } else {
        _errorMessages[status] = res.errorMessage ?? "Something went wrong";
        return false;
      }
    } catch (e) {
      _errorMessages[status] = "Failed to load bookings: $e";
      return false;
    } finally {
      _isLoading[status] = false;
      _isMoreLoading[status] = false;
      update();
    }
  }

  Future<void> loadMoreBookings(String status) async {
    if (!(_isMoreLoading[status] ?? false) &&
        !(_isLoading[status] ?? false) &&
        (_hasMore[status] ?? false)) {
      await getMyBooking(status, isLoadMore: true);
    }
  }
}