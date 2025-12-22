import 'dart:async';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/api_urls.dart';
import 'package:harry_service_app/app/data/services/network_caller.dart';
import '../models/category_model.dart';
import '../models/ski_hire_model.dart';

class SkiHireController extends GetxController {
  List<SkiHireItem> skiHireList = [];
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
  void searchSkiHire({String? category, String? search}) {
    _debounceTimer?.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      fetchAllSkiHireAndCategory(category: category, search: search);
    });
  }

  /// 🔹 Fetch all ski hire items (with optional category & search)
  Future<bool> fetchAllSkiHireAndCategory({
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
      /// Build URL for items
      String url = AppUrls.hireAllServiceUrl(category);

      if (search != null && search.trim().isNotEmpty) {
        final encodedSearch = Uri.encodeQueryComponent(search.trim());
        url += url.contains('?') ? '&search=$encodedSearch' : '?search=$encodedSearch';
      }

      /// Parallel requests for items and categories
      final itemFuture = Get.find<NetworkCaller>().getRequest(url: url);
      final categoryFuture = Get.find<NetworkCaller>().getRequest(url: AppUrls.hireCategory);

      final results = await Future.wait([itemFuture, categoryFuture]);
      final itemResponse = results[0];
      final categoryResponse = results[1];

      /// Ignore outdated responses
      if (requestId != _requestCounter) return false;

      // Clear old data
      skiHireList.clear();
      categoryList.clear();

      // Parse ski hire items
      if (itemResponse.isSuccess && itemResponse.body != null) {
        final data = itemResponse.body!['data'];
        final resultList = data['result'] as List<dynamic>;
        skiHireList = resultList.map((item) => SkiHireItem.fromJson(item)).toList();
      }

      // Parse categories
      if (categoryResponse.isSuccess && categoryResponse.body != null) {
        final data = categoryResponse.body!['data'] as List<dynamic>? ?? [];
        categoryList = data.map((e) => ServiceCategory.fromJson(e)).toList();
        success = true;
      }
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

  /// Clears all data
  void clearData() {
    skiHireList.clear();
    categoryList.clear();
    _errorMessage = null;
    selectedCategoryName = null;
    update();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }
}
