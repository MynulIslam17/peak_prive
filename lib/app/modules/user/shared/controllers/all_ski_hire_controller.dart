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
  String? selectedCategoryName; // ADD THIS: Track selected category

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetch all ski hire items, optionally filtered by category
  Future<bool> fetchAllSkiHireAndCategory([String? category]) async {
    _isLoading = true;
    update(); // triggers UI rebuild

    bool success = false;

    try {

      selectedCategoryName = category;

      /// Parallel requests for items and categories
      ///
      final itemFuture = Get.find<NetworkCaller>().getRequest(
        url: AppUrls.hireAllServiceUrl(category), /// if category null hit another url if present hit another
      );
      final categoryFuture = Get.find<NetworkCaller>().getRequest(
        url: AppUrls.hireCategory,
      );

      final results = await Future.wait([itemFuture, categoryFuture]);
      final itemResponse = results[0];
      final categoryResponse = results[1];

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
      _isLoading = false;
      update(); // trigger UI rebuild
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
}