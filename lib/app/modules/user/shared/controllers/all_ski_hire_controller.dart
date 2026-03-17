import 'dart:async';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/api_urls.dart';
import 'package:harry_service_app/app/data/models/network_response.dart';
import 'package:harry_service_app/app/data/services/network_caller.dart';
import '../models/category_model.dart';
import '../models/ski_hire_model.dart';

class SkiHireController extends GetxController {

  List<SkiHireItem> skiHireList = [];
  List<ServiceCategory> categoryList = [];

  bool _isLoading = false;
  bool _isMoreLoading = false;
  bool _hasMore = true;

  String? _errorMessage;
  String? selectedCategoryName;

  int _page = 1;
  final int _limit = 3;

  /// Search control
  Timer? _debounceTimer;
  int _requestCounter = 0;

  bool get isLoading => _isLoading;
  bool get isMoreLoading => _isMoreLoading;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;

  /// 🔹 Debounced search entry point
  void searchSkiHire({String? category, String? search}) {
    _debounceTimer?.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      fetchAllSkiHireAndCategory(category: category, search: search);
    });
  }

  /// 🔹 Fetch ski hire items with pagination
  Future<bool> fetchAllSkiHireAndCategory({
    String? category,
    String? search,
    bool isLoadMore = false,
  }) async {

    /// Prevent multiple pagination calls
    if (isLoadMore && (_isLoading || _isMoreLoading)) return false;
    if (isLoadMore && !_hasMore) return false;

    final int requestId = ++_requestCounter;
    bool success = false;

    /// Reset pagination if category changes
    if (!isLoadMore && category != selectedCategoryName) {
      _page = 1;
      _hasMore = true;
      skiHireList.clear();
    }

    if (isLoadMore) {
      _isMoreLoading = true;
    } else {
      _isLoading = true;
      if (_page == 1) {
        skiHireList.clear();
      }
    }

    _errorMessage = null;
    selectedCategoryName = category;
    update();

    try {

      /// Build URL with pagination
      String url = AppUrls.hireAllServiceUrl(category);

      url += url.contains('?')
          ? '&page=$_page&limit=$_limit'
          : '?page=$_page&limit=$_limit';

      /// Add search if exists
      if (search != null && search.trim().isNotEmpty) {
        final encodedSearch = Uri.encodeQueryComponent(search.trim());
        url += '&search=$encodedSearch';
      }

      /// Parallel requests
      final itemFuture = Get.find<NetworkCaller>().getRequest(url: url);

      final categoryFuture =
      (!isLoadMore && categoryList.isEmpty)
          ? Get.find<NetworkCaller>().getRequest(url: AppUrls.hireCategory)
          : Future.value(null);

      final results = await Future.wait([itemFuture, categoryFuture]);

      final itemResponse = results[0] as NetworkResponse;
      final categoryResponse = results[1] as NetworkResponse?;

      /// Ignore outdated responses
      if (requestId != _requestCounter) return false;

      /// Parse items
      if (itemResponse.isSuccess && itemResponse.body != null) {

        final data = itemResponse.body!['data'];
        final resultList = data['result'] as List<dynamic>;

        final newItems =
        resultList.map((item) => SkiHireItem.fromJson(item)).toList();

        skiHireList.addAll(newItems);

        final pagination = data['pagination'];
        final totalPages = pagination['totalPages'];

        if (_page >= totalPages || newItems.length < _limit) {
          _hasMore = false;
        } else {
          _page++;
        }
      }

      /// Parse categories
      if (!isLoadMore &&
          categoryResponse != null &&
          categoryResponse.isSuccess &&
          categoryResponse.body != null) {

        final data = categoryResponse.body!['data'] as List<dynamic>? ?? [];

        categoryList =
            data.map((e) => ServiceCategory.fromJson(e)).toList();

        success = true;
      }

    } catch (e) {

      _errorMessage = e.toString();
      success = false;

    } finally {

      if (requestId == _requestCounter) {
        _isLoading = false;
        _isMoreLoading = false;
        update();
      }

    }

    return success;
  }

  /// 🔹 Clear controller state
  void clearData() {
    skiHireList.clear();
    categoryList.clear();
    _errorMessage = null;
    selectedCategoryName = null;

    _page = 1;
    _hasMore = true;

    update();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }
}