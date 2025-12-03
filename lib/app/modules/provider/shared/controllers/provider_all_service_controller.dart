import 'package:get/get.dart';
import 'package:harry_service_app/app/core/controllers/auth_controller.dart';
import 'package:harry_service_app/app/data/services/network_caller.dart';
import '../../../user/shared/models/ski_pass_model.dart' hide SkiPass;
import '../models/provider_resturant_service.dart';
import '../models/provider_pass_service.dart';

class AllServiceController extends GetxController {
  /// Lists for different provider types
  List<SkiPass> skiPassList = [];
  List<Result> restaurantServiceList = [];


  final authController = Get.find<AuthController>();

  /// Loading state
  bool isLoading = false;

  /// Error message (if any)
  String? errorMessage;

  /// Cache last URL for refresh
  String? lastFetchedUrl;

  /// Fetch ANY service list (generic)
  Future<bool> fetchServices(String url) async {
    try {
      isLoading = true;
      errorMessage = null;
      lastFetchedUrl = url;
      update();

      final response = await Get.find<NetworkCaller>().getRequest(url: url);

      if (response.statusCode == 200) {
        final data = response.body?['data'];
        final resultList = data?['result'] as List? ?? [];

        final providerType = authController.userModel?.providerType ?? '';

        switch (providerType) {
          case 'ski_pass':
            skiPassList = resultList
                .map((e) => SkiPass.fromJson(e as Map<String, dynamic>))
                .toList();
            break;
          case 'Restaurant':
            restaurantServiceList = resultList
                .map((e) => Result.fromJson(e as Map<String, dynamic>))
                .toList();
            break;

          default:
            errorMessage = "Unknown provider type: $providerType";
            return false;
        }

        return true;
      } else {
        errorMessage = "Failed to load data: ${response.statusCode}";
        clearLists();
        return false;
      }
    } catch (e) {
      errorMessage = "Something went wrong: $e";
      clearLists();
      return false;
    } finally {
      isLoading = false;
      update();
    }
  }

  /// Refresh using last fetched URL
  Future<void> refreshServices() async {
    if (lastFetchedUrl != null) {
      await fetchServices(lastFetchedUrl!);
    } else {
      errorMessage = "No previous URL to refresh";
      update();
    }
  }

  /// Clear all lists
  void clearLists() {
    skiPassList = [];
    restaurantServiceList = [];

  }
}
