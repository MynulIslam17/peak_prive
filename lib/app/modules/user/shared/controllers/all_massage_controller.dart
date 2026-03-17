import 'dart:async';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/api_urls.dart';
import 'package:harry_service_app/app/data/services/network_caller.dart';
import '../models/all_massage_model.dart';
import '../models/category_model.dart';

class MassageController extends GetxController {
  /// Data
  final List<Massage> massageList = [];
  final List<ServiceCategory> categoryList = [];

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

  /// Public search trigger (call this from UI)
  void searchMassage({String? category, String? search}) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      fetchAllMassageAndCategory(category: category, search: search);
    });
  }

  /// Core fetch method with pagination
  Future<bool> fetchAllMassageAndCategory({
    String? category,
    String? search,
    bool isLoadMore = false,
  }) async {
    // Prevent multiple pagination calls
    if (isLoadMore && (_isLoading || _isMoreLoading)) return false;
    if (isLoadMore && !_hasMore) return false;

    final int requestId = ++_requestCounter;
    bool success = false;

    // Reset pagination if category changed
    if (!isLoadMore && category != selectedCategoryName) {
      _page = 1;
      _hasMore = true;
      massageList.clear();
    }

    if (isLoadMore) {
      _isMoreLoading = true;
    } else {
      _isLoading = true;
      if (_page == 1) massageList.clear();
    }

    _errorMessage = null;
    selectedCategoryName = category;
    update();

    try {
      // Build URL with pagination
      String url = AppUrls.massageServiceUrl(category);
      url += url.contains('?') ? '&page=$_page&limit=$_limit' : '?page=$_page&limit=$_limit';

      if (search != null && search.trim().isNotEmpty) {
        final encodedSearch = Uri.encodeQueryComponent(search.trim());
        url += '&search=$encodedSearch';
      }

      final massageResponse = await Get.find<NetworkCaller>().getRequest(url: url);

      // Ignore outdated responses
      if (requestId != _requestCounter) return false;

      if (!massageResponse.isSuccess || massageResponse.body == null) {
        _errorMessage = 'Failed to load massage services';
        if (!isLoadMore) massageList.clear();
        return false;
      }

      final model = MassageModel.fromJson(massageResponse.body);
      final newItems = model.data.result;

      if (!isLoadMore) massageList.clear();
      massageList.addAll(newItems);

      // Pagination logic
      final pagination = model.data.pagination;
      if (_page >= pagination.totalPages || newItems.length < _limit) {
        _hasMore = false;
      } else {
        _page++;
      }

      // Fetch categories only once
      if (!isLoadMore && categoryList.isEmpty) {
        final categoryResponse = await Get.find<NetworkCaller>().getRequest(
          url: AppUrls.massageCategoryUrl,
        );

        if (categoryResponse.isSuccess && categoryResponse.body != null) {
          final list = categoryResponse.body!['data'] as List<dynamic>? ?? [];
          categoryList.addAll(
            list.map((e) => ServiceCategory.fromJson(e as Map<String, dynamic>)),
          );
        }
      }

      success = true;
    } catch (e) {
      if (requestId == _requestCounter) _errorMessage = e.toString();
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

  /// Load more trigger for pagination
  Future<void> loadMore() async {
    if (_hasMore && !_isMoreLoading) {
      await fetchAllMassageAndCategory(
        category: selectedCategoryName,
        isLoadMore: true,
      );
    }
  }

  /// Clear all data
  void clearData() {
    _debounceTimer?.cancel();
    massageList.clear();
    categoryList.clear();
    selectedCategoryName = null;
    _errorMessage = null;
    _page = 1;
    _hasMore = true;
    _isMoreLoading = false;
    update();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }
}