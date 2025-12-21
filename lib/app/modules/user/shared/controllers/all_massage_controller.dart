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
  Future<bool> fetchAllMassageAndCategory([String? category, String? search]) async {
    _isLoading = true;
    update();

    bool success = false;

    try {
      selectedCategoryName = category;

      /// Build URL
      String url = AppUrls.massageServiceUrl(category);
      if (search != null && search.isNotEmpty) {
        // Check if URL already has '?', if not use '?', otherwise use '&'
        url += url.contains('?') ? '&search=$search' : '?search=$search';
      }



      final massageResponse = await Get.find<NetworkCaller>().getRequest(url: url);
      final categoryResponse = await Get.find<NetworkCaller>().getRequest(url: AppUrls.massageCategoryUrl);

      /// Clear old data
      massageList.clear();
      categoryList.clear();

      if (massageResponse.isSuccess && massageResponse.body != null) {
        final data = massageResponse.body!['data'];
        if (data != null && data['result'] != null) {
          final list = data['result'] as List<dynamic>;
          massageList = list.map((e) => Massage.fromJson(e as Map<String, dynamic>)).toList();
        }
      }

      if (categoryResponse.isSuccess && categoryResponse.body != null) {
        final list = categoryResponse.body!['data'] as List<dynamic>? ?? [];
        categoryList = list.map((e) => ServiceCategory.fromJson(e as Map<String, dynamic>)).toList();
        success = true;
      }
    } catch (e) {
      _errorMessage = e.toString();
      success = false;
    } finally {
      _isLoading = false;
      update();
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
