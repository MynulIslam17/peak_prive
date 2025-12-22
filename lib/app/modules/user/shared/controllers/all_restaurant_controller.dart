import 'dart:async';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/api_urls.dart';
import 'package:harry_service_app/app/data/services/network_caller.dart';
import 'package:harry_service_app/app/modules/user/shared/models/category_model.dart';
import '../models/all_restaurant_model.dart' hide Category;

class RestaurantController extends GetxController {
  /// List of restaurants
  List<RestaurantItem> restaurantList = [];

  /// List of restaurant categories
  List<ServiceCategory> categoryList = [];

  bool _isLoading = false;
  String? _errorMessage;
  String? selectedCategoryName;

  /// Search control
  Timer? _debounceTimer;
  int _requestCounter = 0;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// 🔹 Debounced search entry point
  void searchRestaurant({String? category, String? search}) {
    _debounceTimer?.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      fetchAllRestaurantsAndCategory(category: category, search: search);
    });
  }

  /// 🔹 Fetch all restaurants (with optional category & search)
  Future<bool> fetchAllRestaurantsAndCategory({
    String? category,
    String? search,
  }) async {
    final int requestId = ++_requestCounter;
    bool success = false;

    _isLoading = true;
    _errorMessage = null;
    selectedCategoryName = category;
    update();

    try {
      /// Build URL for restaurants
      String url = AppUrls.restaurantServiceUrl(category);

      if (search != null && search.trim().isNotEmpty) {
        final encodedSearch = Uri.encodeQueryComponent(search.trim());
        url += url.contains('?') ? '&search=$encodedSearch' : '?search=$encodedSearch';
      }

      /// Parallel requests for restaurants and categories
      final restaurantFuture = Get.find<NetworkCaller>().getRequest(url: url);
      final categoryFuture = Get.find<NetworkCaller>().getRequest(url: AppUrls.restaurantCategoryUrl);

      final results = await Future.wait([restaurantFuture, categoryFuture]);
      final restaurantResponse = results[0];
      final categoryResponse = results[1];

      /// Ignore outdated responses
      if (requestId != _requestCounter) return false;

      // Clear old data
      restaurantList.clear();
      categoryList.clear();

      // Parse restaurant list
      if (restaurantResponse.isSuccess && restaurantResponse.body != null) {
        final data = restaurantResponse.body!['data'] as Map<String, dynamic>? ?? {};
        final resultList = data['result'] as List<dynamic>? ?? [];
        restaurantList = resultList
            .map((e) => RestaurantItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      // Parse categories
      if (categoryResponse.isSuccess && categoryResponse.body != null) {
        final list = categoryResponse.body!['data'] as List<dynamic>? ?? [];
        categoryList = list
            .map((e) => ServiceCategory.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      _errorMessage = null;
      success = true;
    } catch (e) {
      _errorMessage = e.toString();
      success = false;
    } finally {
      if (requestId == _requestCounter) {
        _isLoading = false;
        update();
      }
    }

    return success;
  }

  /// Clear all data
  void clearData() {
    restaurantList.clear();
    categoryList.clear();
    selectedCategoryName = null;
    _errorMessage = null;
    update();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }
}
