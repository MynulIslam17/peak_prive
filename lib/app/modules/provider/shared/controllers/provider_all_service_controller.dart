import 'package:get/get.dart';
import '../../../../core/controllers/auth_controller.dart';
import '../../../../data/services/network_caller.dart';
import '../models/hire_service_model.dart';
import '../models/provider_massage_service_model.dart';
import '../models/provider_pass_service_model.dart';
import '../models/provider_resturant_service.dart' show Result;
import '../models/provider_transport_service_model.dart';

class AllServiceController extends GetxController {
  List<SkiPass> skiPassList = [];
  List<Result> restaurantServiceList = [];
  List<MassageResult> massageServiceList = [];
  List<TransportResult> transportServiceList = [];
  List<HireResult> hireServiceList = [];

  final authController = Get.find<AuthController>();

  bool isLoading = false;
  String? errorMessage;
  String? lastFetchedUrl;

  /// Fetch services generically
  Future<bool> fetchServices(String url, {bool showLoader = true}) async {
    bool success = false;
    try {
      if (showLoader) {
        isLoading = true;
        update();
      }

      errorMessage = null;
      lastFetchedUrl = url;

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

          case 'Transport':
            transportServiceList = resultList
                .map((e) => TransportResult.fromJson(e as Map<String, dynamic>))
                .toList();
            break;

          case 'Ski_Hire':
            hireServiceList = resultList
                .map((e) => HireResult.fromJson(e as Map<String, dynamic>))
                .toList();
            break;

          default:
            errorMessage = "Unknown provider type: $providerType";
            clearLists();
            return false;
        }

        success = true;
      } else {
        errorMessage = "Failed to load data: ${response.statusCode}";
        clearLists();
      }
      return success;
    } catch (e) {
      errorMessage = "Something went wrong: $e";
      clearLists();
      return false;
    } finally {
      if (showLoader) isLoading = false;
      update();
    }
  }

  /// Refresh using last fetched URL
  Future<void> refreshServices({bool showLoader = false}) async {
    if (lastFetchedUrl != null) {
      await fetchServices(lastFetchedUrl!, showLoader: showLoader);
    } else {
      errorMessage = "No previous URL to refresh";
      update();
    }
  }

  /// Remove an item locally from the correct list
  void removeItemFromList(String itemId, String providerType) {
    int initialLength;

    switch (providerType) {
      case 'Ski_Pass':
        initialLength = skiPassList.length;
        skiPassList.removeWhere((item) => item.id == itemId);
        break;

      case 'Restaurant':
        initialLength = restaurantServiceList.length;
        restaurantServiceList.removeWhere((item) => item.sId == itemId);
        break;

      case 'Massage':
        initialLength = massageServiceList.length;
        massageServiceList.removeWhere((item) => item.sId == itemId);
        break;

      case 'Transport':
        initialLength = transportServiceList.length;
        transportServiceList.removeWhere((item) => item.sId == itemId);
        break;

      case 'Ski_Hire':
        initialLength = hireServiceList.length;
        hireServiceList.removeWhere((item) => item.id == itemId);
        break;
    }

    update();
  }

  /// Clear all lists
  void clearLists() {
    skiPassList.clear();
    restaurantServiceList.clear();
    massageServiceList.clear();
    transportServiceList.clear();
    hireServiceList.clear();
  }

  /// ----------------------------
  /// Restaurant Category Helpers
  /// ----------------------------
  List<String> getRestaurantCategories() {
    return restaurantServiceList
        .map((r) => r.category?.name ?? 'Unknown')
        .toSet()
        .toList();
  }

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
