import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/api_urls.dart';
import 'package:harry_service_app/app/data/models/network_response.dart';
import 'package:harry_service_app/app/data/services/network_caller.dart';
import 'package:harry_service_app/app/modules/user/itinerary/models/my_itineraray_model.dart';

class GetAllItineraryController extends GetxController {
  final List<ItineraryItem> itineraryList = [];
  MyItinerary? myItinerary;

  bool _isLoading = false;
  bool _isMoreLoading = false;
  String? _errorMessage;

  int _page = 1;
  final int _limit = 10;
  bool _hasMore = true;

  // Getters for UI
  bool get isLoading => _isLoading;
  bool get isMoreLoading => _isMoreLoading;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;

  Future<void> getMyItinerary({bool isLoadMore = false}) async {
    // 1. Guard Clauses
    if (_isLoading || _isMoreLoading) return;
    if (isLoadMore && !_hasMore) return;

    // 2. State Initialization
    _errorMessage = null;
    if (isLoadMore) {
      _isMoreLoading = true;
    } else {
      _isLoading = true;
      _page = 1;
      _hasMore = true;
      itineraryList.clear();
    }
    update();

    try {
      // 3. Network Request
      final NetworkResponse response = await Get.find<NetworkCaller>().getRequest(
        url: "${AppUrls.myItineraryUrl}?page=$_page&limit=$_limit",
      );

      if (response.statusCode == 200 && response.body != null) {
        final responseData = MyItinerary.fromJson(response.body!);
        myItinerary = responseData;

        // 4. Data Handling
        final List<ItineraryItem> newItems = responseData.data.result;
        itineraryList.addAll(newItems);

        // 5. Pagination Logic
        if (_page >= responseData.data.pagination.totalPages || newItems.length < _limit) {
          _hasMore = false;
        } else {
          _page++;
        }
      } else {
        _errorMessage = response.errorMessage ?? "Failed to load itinerary";
      }
    } catch (e) {
      _errorMessage = "An unexpected error occurred: $e";
    } finally {
      // 6. Final State Reset
      _isLoading = false;
      _isMoreLoading = false;
      update();
    }
  }
}