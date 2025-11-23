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
  String? selectedCategoryName; // Track selected category

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetch all transport items and categories (optionally filtered by category)
  Future<bool> fetchAllTransportAndCategory([String? category]) async {
    _isLoading = true;
    update(); // triggers UI rebuild

    bool success = false;

    try {
      // Update selected category
      selectedCategoryName = category;

      // Parallel requests for transport data and categories
      final transportFuture = Get.find<NetworkCaller>().getRequest(
        url: AppUrls.transportServiceUrl(category),
      );

      final categoryFuture = Get.find<NetworkCaller>().getRequest(
        url: AppUrls.transportCategoryUrl,
      );

      final results = await Future.wait([transportFuture, categoryFuture]);
      final transportResponse = results[0];
      final categoryResponse = results[1];

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
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      success = false;
    } finally {
      _isLoading = false;
      update(); // trigger UI rebuild
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
}
