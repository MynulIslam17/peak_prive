import 'package:get/get.dart';
import 'package:harry_service_app/app/data/services/network_caller.dart';
import 'package:harry_service_app/app/modules/provider/shared/models/provider_all_service_model.dart' show SkiPass;
import '../../../user/shared/models/ski_pass_model.dart' hide SkiPass;

class AllServiceController extends GetxController {
  /// List of ski passes or services
  List<SkiPass> skiPassList = [];

  /// Indicates if API request is ongoing
  bool isLoading = false;

  /// Stores error messages
  String? errorMessage;

  /// Last used URL for fetch/refresh
  String? lastUrl;

  /// Fetch data from the API
  Future<bool> fetchSkiPassData(String url) async {
    try {
      isLoading = true;
      errorMessage = null;
      lastUrl = url; // store the URL for later refresh
      update();

      final response = await Get.find<NetworkCaller>().getRequest(url: url);

      if (response.statusCode == 200) {
        final data = response.body?['data'];
        final resultList = data?['result'] as List? ?? [];

        skiPassList = resultList
            .map((e) => SkiPass.fromJson(e as Map<String, dynamic>?))
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

  /// Pull-to-refresh using last URL
  Future<void> refreshData() async {
    if (lastUrl != null) {
      await fetchSkiPassData(lastUrl!);
    } else {
      errorMessage = "No previous URL to refresh";
      update();
    }
  }
}
