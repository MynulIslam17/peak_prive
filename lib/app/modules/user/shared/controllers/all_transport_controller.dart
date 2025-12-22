import 'dart:async';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/api_urls.dart';
import 'package:harry_service_app/app/data/services/network_caller.dart';
import '../models/all_transport_model.dart';
import '../models/category_model.dart';

class TransportController extends GetxController {
  List<TransportItem> transportList = [];
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
  void searchTransport({String? category, String? search}) {
    _debounceTimer?.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      fetchAllTransportAndCategory(category: category, search: search);
    });
  }

  /// 🔹 Fetch all transport items (with optional category & search)
  Future<bool> fetchAllTransportAndCategory({
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
      /// Build URL for transport items
      String url = AppUrls.transportServiceUrl(category);

      if (search != null && search.trim().isNotEmpty) {
        final encodedSearch = Uri.encodeQueryComponent(search.trim());
        url += url.contains('?') ? '&search=$encodedSearch' : '?search=$encodedSearch';
      }

      /// Parallel requests for transport items and categories
      final transportFuture = Get.find<NetworkCaller>().getRequest(url: url);
      final categoryFuture = Get.find<NetworkCaller>().getRequest(url: AppUrls.transportCategoryUrl);

      final results = await Future.wait([transportFuture, categoryFuture]);
      final transportResponse = results[0];
      final categoryResponse = results[1];

      /// Ignore outdated responses
      if (requestId != _requestCounter) return false;

      // Clear old data
      transportList.clear();
      categoryList.clear();

      // Parse transport items
      if (transportResponse.isSuccess && transportResponse.body != null) {
        final data = transportResponse.body!['data'];
        final resultList = data['result'] as List<dynamic>? ?? [];
        transportList = resultList.map((item) => TransportItem.fromJson(item)).toList();
      }

      // Parse categories
      if (categoryResponse.isSuccess && categoryResponse.body != null) {
        final data = categoryResponse.body!['data'] as List<dynamic>? ?? [];
        categoryList = data.map((e) => ServiceCategory.fromJson(e)).toList();
      }

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

  /// Clears all data
  void clearData() {
    transportList.clear();
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
