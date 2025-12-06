import 'package:get/get.dart';
import 'package:harry_service_app/app/core/controllers/auth_controller.dart';
import 'package:harry_service_app/app/data/services/network_caller.dart';
import 'package:harry_service_app/app/modules/provider/shared/models/provider_massage_service_model.dart';
import '../../../user/shared/models/ski_pass_model.dart';
import '../models/provider_resturant_service.dart';

class AllServiceController extends GetxController {
  /// Lists for different provider types
  List<SkiPass> skiPassList = [];
  List<Result> restaurantServiceList = [];
  List<MassageResult> massageServiceList = [];

  final authController = Get.find<AuthController>();

  /// Loading state
  bool isLoading = false;

  /// Error message
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
          case 'Ski_Pass':
            skiPassList = resultList
                .map((e) => SkiPass.fromJson(e as Map<String, dynamic>))
                .toList();
            break;

          case 'Restaurant':
            restaurantServiceList = resultList
                .map((e) => Result.fromJson(e as Map<String, dynamic>))
                .toList();
            break;

          case 'Massage':
            massageServiceList = resultList
                .map((e) => MassageResult.fromJson(e as Map<String, dynamic>))
                .toList();
            break;

          default:
            errorMessage = "Unknown provider type: $providerType";
            clearLists();
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

  /// Removes an item locally from the correct list after a successful delete API call,
  /// avoiding a full data refresh (and the shimmer effect).
  void removeItemFromList(String itemId, String providerType) {
    int initialLength;

    switch (providerType) {
      case 'Ski_Pass':
        initialLength = skiPassList.length;
        // 1. PERFORM THE REMOVAL (This returns void)
        skiPassList.removeWhere((item) => item.id == itemId);
        // 2. CHECK IF LIST LENGTH CHANGED
        if (skiPassList.length < initialLength) update();
        break;

      case 'Restaurant':
        initialLength = restaurantServiceList.length;
        // 1. PERFORM THE REMOVAL
        restaurantServiceList.removeWhere((item) => item.sId == itemId);
        // 2. CHECK IF LIST LENGTH CHANGED
        if (restaurantServiceList.length < initialLength) update();
        break;

      case 'Massage':
        initialLength = massageServiceList.length;
        // 1. PERFORM THE REMOVAL
        massageServiceList.removeWhere((item) => item.sId == itemId);
        // 2. CHECK IF LIST LENGTH CHANGED
        if (massageServiceList.length < initialLength) update();
        break;
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
    massageServiceList = [];
  }

  /// ----------------------------
  /// Restaurant Category Helpers
  /// ----------------------------

  /// Get unique restaurant categories
  List<String> getRestaurantCategories() {
    return restaurantServiceList
        .map((r) => r.category?.name ?? 'Unknown')
        .toSet()
        .toList();
  }

  /// Group restaurants by category
  Map<String, List<Result>> getRestaurantByCategory() {
    final Map<String, List<Result>> map = {};

    for (var r in restaurantServiceList) {
      final name = r.category?.name ?? 'Unknown';
      map.putIfAbsent(name, () => []);
      map[name]!.add(r);
    }

    return map;
  }
}