import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/api_urls.dart';
import 'package:harry_service_app/app/data/services/network_caller.dart';
import 'package:harry_service_app/app/modules/user/shared/models/category_model.dart';

import '../../hire/models/hire_details_model.dart';
import '../models/all_restaurant_model.dart' hide Category;

class RestaurantController extends GetxController {
  /// List of restaurants
  List<RestaurantItem> restaurantList = [];

  /// List of restaurant categories
  List<ServiceCategory> categoryList = [];

  bool _isLoading = false;
  String? _errorMessage;
  String? selectedCategoryName;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetch all restaurants + categories (optionally filtered by category)
  Future<bool> fetchAllRestaurantsAndCategory([String? category]) async {
    _isLoading = true;
    update(); // trigger UI rebuild

    bool success = false;

    try {
      // Track selected category
      selectedCategoryName = category;

      // Parallel API requests
      final restaurantFuture = Get.find<NetworkCaller>().getRequest(
        url: AppUrls.restaurantServiceUrl(category),
      );

      final categoryFuture = Get.find<NetworkCaller>().getRequest(
        url: AppUrls.restaurantCategoryUrl,
      );

      final responses = await Future.wait([restaurantFuture, categoryFuture]);
      final restaurantResponse = responses[0];
      final categoryResponse = responses[1];

      // Clear old data
      restaurantList.clear();
      categoryList.clear();

      /// Parse restaurant list safely
      if (restaurantResponse.isSuccess && restaurantResponse.body != null) {
        final data = restaurantResponse.body!['data'] as Map<String, dynamic>?;
        final resultList = data?['result'] as List<dynamic>? ?? [];
        restaurantList = resultList
            .map((e) => RestaurantItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      /// Parse categories safely using ServiceCategory
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
      _isLoading = false;
      update(); // trigger UI rebuild
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
}
