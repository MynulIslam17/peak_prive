import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/api_urls.dart';
import 'package:harry_service_app/app/data/services/network_caller.dart';
import '../models/all_massage_model.dart';
import '../models/category_model.dart';

class MassageController extends GetxController {
  /// List of massage items
  List<Massage> massageList = [];

  /// List of categories
  List<ServiceCategory> categoryList = [];

  bool _isLoading = false;
  String? _errorMessage;
  String? selectedCategoryName;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetch all massage services + categories
  Future<bool> fetchAllMassageAndCategory([String? category]) async {
    _isLoading = true;
    update(); // trigger UI rebuild

    bool success = false;

    try {
      // Track selected category
      selectedCategoryName = category;

      // Parallel API requests
      final massageFuture = Get.find<NetworkCaller>().getRequest(
        url: AppUrls.massageServiceUrl(category),
      );

      final categoryFuture = Get.find<NetworkCaller>().getRequest(
        url: AppUrls.massageCategoryUrl,
      );

      final responses = await Future.wait([massageFuture, categoryFuture]);
      final massageResponse = responses[0];
      final categoryResponse = responses[1];

      // Clear old data
      massageList.clear();
      categoryList.clear();

      /// Parse massage list
      if (massageResponse.isSuccess && massageResponse.body != null) {
        final data = massageResponse.body!['data'];
        if (data != null && data['result'] != null) {
          final list = data['result'] as List<dynamic>;
          massageList = list
              .map((e) => Massage.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }

      /// Parse categories
      if (categoryResponse.isSuccess && categoryResponse.body != null) {
        final list = categoryResponse.body!['data'] as List<dynamic>? ?? [];
        categoryList = list
            .map((e) => ServiceCategory.fromJson(e as Map<String, dynamic>))
            .toList();
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

  /// Clear all data
  void clearData() {
    massageList.clear();
    categoryList.clear();
    selectedCategoryName = null;
    _errorMessage = null;
    update();
  }
}
