import 'dart:async';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/api_urls.dart';
import 'package:harry_service_app/app/data/services/network/network_caller.dart';
import 'package:harry_service_app/app/modules/user/shared/models/category_model.dart';
import '../../../../data/models/network_response.dart';
import '../models/all_restaurant_model.dart' hide Category;

class RestaurantController extends GetxController {
  /// Restaurant list
  List<RestaurantItem> restaurantList = [];

  /// Category list
  List<ServiceCategory> categoryList = [];

  /// State
  bool _isLoading = false;
  bool _isMoreLoading = false;
  bool _isCategoryLoading = false;
  bool _hasMore = true;

  String? _errorMessage;
  String? selectedCategoryName;

  /// Pagination
  int _page = 1;
  final int _limit = 10;

  /// Search debounce
  Timer? _debounceTimer;
  int _requestCounter = 0;

  /// Getters
  bool get isLoading => _isLoading;
  bool get isMoreLoading => _isMoreLoading;
  bool get hasMore => _hasMore;
  bool get isCategoryLoading => _isCategoryLoading;
  String? get errorMessage => _errorMessage;

  /// 🔹 Debounced search
  void searchRestaurant({String? category, String? search}) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      fetchAllRestaurantsAndCategory(category: category, search: search);
    });
  }

  /// 🔹 Fetch restaurants with pagination
  Future<bool> fetchAllRestaurantsAndCategory({
    String? category,
    String? search,
    bool isLoadMore = false,
  }) async {
    if ((isLoadMore && (_isLoading || _isMoreLoading)) || (isLoadMore && !_hasMore)) return false;

    final int requestId = ++_requestCounter;
    bool success = false;

    if (!isLoadMore && category != selectedCategoryName) {
      _page = 1;
      _hasMore = true;
      restaurantList.clear();
    }

    if (isLoadMore) {
      _isMoreLoading = true;
    } else {
      _isLoading = true;
      if (_page == 1) restaurantList.clear();
      _isCategoryLoading = categoryList.isEmpty;
    }

    _errorMessage = null;
    selectedCategoryName = category;
    update();

    try {
      String url = AppUrls.restaurantServiceUrl(category);
      url += url.contains('?') ? '&page=$_page&limit=$_limit' : '?page=$_page&limit=$_limit';

      if (search != null && search.trim().isNotEmpty) {
        final encodedSearch = Uri.encodeQueryComponent(search.trim());
        url += '&search=$encodedSearch';
      }

      // 🔹 Restaurant API
      final restaurantResponse = await Get.find<NetworkCaller>().getRequest(url: url);

      // 🔹 Category API (load once)
      NetworkResponse? categoryResponse;
      if (!isLoadMore && categoryList.isEmpty) {
        _isCategoryLoading = true;
        update();
        categoryResponse = await Get.find<NetworkCaller>().getRequest(url: AppUrls.restaurantCategoryUrl);
      }

      if (requestId != _requestCounter) return false;

      // Parse restaurant list
      if (restaurantResponse.isSuccess && restaurantResponse.body != null) {
        final data = restaurantResponse.body!['data'] as Map<String, dynamic>? ?? {};
        final resultList = data['result'] as List<dynamic>? ?? [];
        final restaurants = resultList
            .map((e) => RestaurantItem.fromJson(e as Map<String, dynamic>))
            .toList();

        if (isLoadMore) {
          restaurantList.addAll(restaurants);
        } else {
          restaurantList = restaurants;
        }

        // Pagination
        final pagination = data['pagination'];
        if (pagination != null) {
          final currentPage = pagination['page'] ?? 1;
          final totalPages = pagination['totalPages'] ?? 1;
          _page = currentPage;
          _hasMore = currentPage < totalPages;
          if (isLoadMore) _page++;
        } else {
          _hasMore = false;
        }
      }

      // Parse categories
      if (!isLoadMore &&
          categoryResponse != null &&
          categoryResponse.isSuccess &&
          categoryResponse.body != null) {
        final list = categoryResponse.body!['data'] as List<dynamic>? ?? [];
        categoryList = list
            .map((e) => ServiceCategory.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      success = true;
    } catch (e) {
      _errorMessage = e.toString();
      success = false;
    } finally {
      if (requestId == _requestCounter) {
        _isLoading = false;
        _isMoreLoading = false;
        _isCategoryLoading = false;
        update();
      }
    }

    return success;
  }

  /// 🔹 Load more restaurants
  Future<void> loadMoreRestaurant() async {
    if (!isMoreLoading && hasMore) {
      _page++;
      await fetchAllRestaurantsAndCategory(
        category: selectedCategoryName,
        isLoadMore: true,
      );
    }
  }

  /// 🔹 Clear controller state
  void clearData() {
    restaurantList.clear();
    categoryList.clear();
    selectedCategoryName = null;
    _errorMessage = null;
    _page = 1;
    _hasMore = true;
    _isMoreLoading = false;
    _isLoading = false;
    _isCategoryLoading = false;
    update();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }
}