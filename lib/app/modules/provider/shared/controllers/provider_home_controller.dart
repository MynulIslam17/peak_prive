import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/api_urls.dart';
import 'package:harry_service_app/app/data/models/network_response.dart';
import 'package:harry_service_app/app/data/services/network/network_caller.dart';
import '../models/provider_home_model.dart';

class ProviderHomeController extends GetxController {

  ProviderHomeModel? providerHome;
  bool isLoading = false;
  String? errorMessage;

  /// Fetches provider home data from API.
  /// Set [showLoader] to false to perform a silent background fetch.
  /// Returns true if the API call is successful, false otherwise.
  Future<bool> fetchProviderHomeData({bool showLoader = true}) async {
    try {
      if (showLoader) {
        isLoading = true;
      }
      errorMessage = null;
      update();

      NetworkResponse response =
      await Get.find<NetworkCaller>().getRequest(url: AppUrls.providerHome);

      if (response.statusCode == 200) {
        final data = response.body!["data"]!;
        providerHome = ProviderHomeModel.fromJson(data);
        return true;
      } else {
        errorMessage = "Failed to load data: ${response.statusCode}";
        return false;
      }
    } catch (e) {
      errorMessage = "Something went wrong: $e";
      return false;
    } finally {
      if (showLoader) {
        isLoading = false;
      }
      update();
    }
  }

  /// Refreshes provider home data manually without showing the full-screen loader.
  Future<void> refreshData() async {
    await fetchProviderHomeData(showLoader: false);
  }
}