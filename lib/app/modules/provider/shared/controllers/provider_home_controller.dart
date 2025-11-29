import 'dart:convert';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/api_urls.dart';
import 'package:harry_service_app/app/data/models/network_response.dart';
import 'package:harry_service_app/app/data/services/network_caller.dart';
import '../models/provider_home_model.dart';

class ProviderHomeController extends GetxController {
  // -------------------------
  // VARIABLES
  // -------------------------

  /// Stores the provider home data after successful API fetch
  ProviderHomeModel? providerHome;

  /// Indicates whether the API request is in progress
  bool isLoading = false;

  /// Stores any error messages from the API or exceptions
  String? errorMessage;

  // -------------------------
  // FETCH PROVIDER HOME DATA
  // -------------------------

  /// Fetches provider home data from API.
  /// Updates [providerHome], [isLoading], and [errorMessage].
  /// Returns true if the API call is successful, false otherwise.
  Future<bool> fetchProviderHomeData() async {
    try {
      isLoading = true; // Start loading
      errorMessage = null; // Clear previous errors
      update(); // Refresh UI

      // Make API call using NetworkCaller
      NetworkResponse response =
      await Get.find<NetworkCaller>().getRequest(url: AppUrls.providerHome);

      // Check if API response is valid
      if (response.statusCode == 200 &&
          response.body != null &&
          response.body!["data"] != null) {
        final data = response.body!["data"];
        providerHome = ProviderHomeModel.fromJson(data); // Parse JSON
        return true;
      } else {
        errorMessage = "Failed to load data: ${response.statusCode}";
        return false;
      }
    } catch (e) {
      // Catch exceptions and save error
      errorMessage = "Something went wrong: $e";
      return false;
    } finally {
      isLoading = false; // Stop loading
      update(); // Refresh UI
    }
  }

  // -------------------------
  // OPTIONAL: REFRESH DATA
  // -------------------------

  /// Refreshes provider home data manually
  Future<void> refreshData() async {
    await fetchProviderHomeData();
  }
}
