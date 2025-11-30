import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/api_urls.dart';
import 'package:harry_service_app/app/data/models/network_response.dart';
import 'package:harry_service_app/app/data/services/network_caller.dart';
import '../../../user/shared/models/ski_pass_model.dart';

/// Controller to manage fetching and storing ski pass data
class SkiPassController extends GetxController {
  /// List of ski passes
  List<SkiPass> skiPassList = [];

  /// Indicates if API request is ongoing
  bool isLoading = false;

  /// Stores error messages if API fails
  String? errorMessage;

  /// Fetches ski pass data from the API
  /// Returns true if successful, false otherwise
  Future<bool> fetchSkiPassData() async {
    try {
      isLoading = true;
      errorMessage = null;
      update();

      final response = await Get.find<NetworkCaller>()
          .getRequest(url: AppUrls.providerServiceUrl);

      if (response.statusCode == 200) {
        final data = response.body?['data'];
        final resultList = data?['result'] as List? ?? [];
        skiPassList = resultList
            .map((e) => SkiPass.fromJson(e as Map<String, dynamic>))
            .toList();
        return true;
      } else {
        errorMessage = "Failed to load data: ${response.statusCode}";
        skiPassList = [];
        return false;
      }
    } catch (e) {
      errorMessage = "Something went wrong: $e";
      skiPassList = [];
      return false;
    } finally {
      isLoading = false;
      update();
    }
  }

  /// Manually refreshes ski pass data
  Future<void> refreshData() async {
    await fetchSkiPassData();
  }
}
