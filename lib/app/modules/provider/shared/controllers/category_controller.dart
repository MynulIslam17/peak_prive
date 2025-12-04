import 'package:get/get.dart';
import 'package:harry_service_app/app/data/services/network_caller.dart';
import '../../../user/shared/models/category_model.dart';

class CategoryController extends GetxController {
  /// List of categories
  List<ServiceCategory> categories = [];

  /// Error message
  String errorMessage = '';

  /// Loading state
  bool isLoading = false;

  /// Fetch categories from API
  Future<void> fetchCategories(String url) async {
    try {
      isLoading = true;
      errorMessage = '';
      categories = [];
      update(); // Notify UI

      final response = await Get.find<NetworkCaller>().getRequest(url: url);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.body?['data'] ?? [];
        categories = data.map((json) => ServiceCategory.fromJson(json)).toList();
      } else {
        errorMessage = response.body?['message'] ?? 'Failed to fetch categories';
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      update(); // Notify UI even after error
    }
  }

  /// Helper to get names only
  List<String> get categoryNames => categories.map((c) => c.name).toList();
}
