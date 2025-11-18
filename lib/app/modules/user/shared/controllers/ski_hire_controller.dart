import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/api_urls.dart';
import 'package:harry_service_app/app/data/models/network_response.dart';
import 'package:harry_service_app/app/data/services/network_caller.dart';
import '../models/ski_hire_model.dart';

class SkiHireController extends GetxController {
  // --------------------------
  // List of ski hire items
  // --------------------------
  List<SkiHireItem> skiHireList = [];

  // --------------------------
  // Loading and error state
  // --------------------------
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // --------------------------
  // Fetch all ski hire items from API
  // --------------------------
  Future<bool> fetchAllSkiHire() async {
    bool success = false;

    _isLoading = true;
    update(); // Notify UI to show loading

    try {
      // Call API
      NetworkResponse response = await Get.find<NetworkCaller>().getRequest(
        url: AppUrls.hireAllServiceUrl,
      );

      if (response.isSuccess) {
        final data = response.body!['data'];
        List<dynamic> resultList = data['result'];

        // Parse list of ski hire items
        skiHireList =
            resultList.map((item) => SkiHireItem.fromJson(item)).toList();

        _errorMessage = null;
        success = true;
      } else {
        _errorMessage = response.errorMessage ?? "Unable to fetch data";
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      update(); // Notify UI to hide loading
    }

    return success;
  }

  // --------------------------
  // Fetch a single ski hire item by ID
  // --------------------------
  SkiHireItem? getSkiHireById(String id) {
    try {
      return skiHireList.firstWhere((element) => element.id == id);
    } catch (e) {
      return null;
    }
  }

  // --------------------------
  // Clear list and error state
  // --------------------------
  void clearData() {
    skiHireList.clear();
    _errorMessage = null;
    update();
  }
}
