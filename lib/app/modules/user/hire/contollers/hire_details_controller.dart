
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/api_urls.dart';
import 'package:harry_service_app/app/data/models/network_response.dart';
import 'package:harry_service_app/app/data/services/network_caller.dart';
import '../models/hire_details_model.dart';

class HireDetailsController extends GetxController {
  HireDetailsModel? hireDetails;
  bool isLoading = false;
  String? errorMessage;

  /// Fetch details for a specific hire item by ID
  Future<bool> fetchHireDetails(String id) async {
    isLoading = true;
    update();

    try {
      NetworkResponse response = await Get.find<NetworkCaller>().getRequest(
        url: AppUrls.hireDetailsUrl(id),
      );

      if (response.isSuccess && response.body != null) {
        hireDetails = HireDetailsModel.fromJson(response.body!['data']);
        errorMessage = null;
        return true;
      } else {
        errorMessage = response.errorMessage ?? "Failed to fetch data";
        return false;
      }
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      update();
    }
  }
}
