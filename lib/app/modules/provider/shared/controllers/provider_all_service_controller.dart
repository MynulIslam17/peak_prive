// import 'package:get/get.dart';
// import 'package:harry_service_app/app/core/controllers/auth_controller.dart';
// import 'package:harry_service_app/app/data/services/network_caller.dart';
// import 'package:harry_service_app/app/modules/provider/shared/models/hire_service_model.dart';
// import 'package:harry_service_app/app/modules/provider/shared/models/provider_massage_service_model.dart';
// import 'package:harry_service_app/app/modules/provider/shared/models/provider_transport_service_model.dart';
// import '../../../user/shared/models/ski_pass_model.dart';
// import '../models/provider_resturant_service.dart';
//
// class AllServiceController extends GetxController {
//   /// Lists for different provider types
//   List<SkiPass> skiPassList = [];
//   List<Result> restaurantServiceList = [];
//   List<MassageResult> massageServiceList = [];
//   List<TransportResult> transportServiceList = [];
//   List<HireResult> hireServiceList = [];
//
//   final authController = Get.find<AuthController>();
//
//   /// Loading state
//   bool isLoading = false;
//
//   /// Error message
//   String? errorMessage;
//
//   /// Cache last URL for refresh
//   String? lastFetchedUrl;
//
//   /// Fetch ANY service list (generic)
//   Future<bool> fetchServices(String url) async {
//     try {
//       isLoading = true;
//       errorMessage = null;
//       lastFetchedUrl = url;
//       update();
//
//       final response = await Get.find<NetworkCaller>().getRequest(url: url);
//
//       if (response.statusCode == 200) {
//         final data = response.body?['data'];
//         final resultList = data?['result'] as List? ?? [];
//
//         final providerType = authController.userModel?.providerType ?? '';
//
//         switch (providerType) {
//           case 'Ski_Pass':
//             skiPassList = resultList
//                 .map((e) => SkiPass.fromJson(e as Map<String, dynamic>))
//                 .toList();
//             break;
//
//           case 'Restaurant':
//             restaurantServiceList = resultList
//                 .map((e) => Result.fromJson(e as Map<String, dynamic>))
//                 .toList();
//             break;
//
//           case 'Massage':
//             massageServiceList = resultList
//                 .map((e) => MassageResult.fromJson(e as Map<String, dynamic>))
//                 .toList();
//             break;
//
//           case 'Transport':
//             transportServiceList = resultList
//                 .map((e) => TransportResult.fromJson(e as Map<String, dynamic>))
//                 .toList();
//             break;
//
//           case 'Ski_Hire':   // FIXED
//             hireServiceList = resultList
//                 .map((e) => HireResult.fromJson(e as Map<String, dynamic>))
//                 .toList();
//             break;
//
//           default:
//             errorMessage = "Unknown provider type: $providerType";
//             clearLists();
//             return false;
//         }
//
//         return true;
//       } else {
//         errorMessage = "Failed to load data: ${response.statusCode}";
//         clearLists();
//         return false;
//       }
//     } catch (e) {
//       errorMessage = "Something went wrong: $e";
//       clearLists();
//       return false;
//     } finally {
//       isLoading = false;
//       update();
//     }
//   }
//
//   /// Removes an item locally from the correct list after a successful delete API call
//   void removeItemFromList(String itemId, String providerType) {
//     int initialLength;
//
//     switch (providerType) {
//       case 'Ski_Pass':
//         initialLength = skiPassList.length;
//         skiPassList.removeWhere((item) => item.id == itemId);
//         if (skiPassList.length < initialLength) update();
//         break;
//
//       case 'Restaurant':
//         initialLength = restaurantServiceList.length;
//         restaurantServiceList.removeWhere((item) => item.sId == itemId);
//         if (restaurantServiceList.length < initialLength) update();
//         break;
//
//       case 'Massage':
//         initialLength = massageServiceList.length;
//         massageServiceList.removeWhere((item) => item.sId == itemId);
//         if (massageServiceList.length < initialLength) update();
//         break;
//
//       case 'Transport':
//         initialLength = transportServiceList.length;
//         transportServiceList.removeWhere((item) => item.sId == itemId);
//         if (transportServiceList.length < initialLength) update();
//         break;
//
//       case 'Ski_Hire':   // NEW
//         initialLength = hireServiceList.length;
//         hireServiceList.removeWhere((item) => item.id == itemId);
//         if (hireServiceList.length < initialLength) update();
//         break;
//     }
//   }
//
//   /// Refresh using last fetched URL
//   Future<void> refreshServices() async {
//     if (lastFetchedUrl != null) {
//       await fetchServices(lastFetchedUrl!);
//     } else {
//       errorMessage = "No previous URL to refresh";
//       update();
//     }
//   }
//
//   /// Clear all lists
//   void clearLists() {
//     skiPassList = [];
//     restaurantServiceList = [];
//     massageServiceList = [];
//     transportServiceList = [];
//     hireServiceList = [];   // FIXED
//   }
//
//   /// ----------------------------
//   /// Restaurant Category Helpers
//   /// ----------------------------
//
//   /// Get unique restaurant categories
//   List<String> getRestaurantCategories() {
//     return restaurantServiceList
//         .map((r) => r.category?.name ?? 'Unknown')
//         .toSet()
//         .toList();
//   }
//
//   /// Group restaurants by category
//   Map<String, List<Result>> getRestaurantByCategory() {
//     final Map<String, List<Result>> map = {};
//
//     for (var r in restaurantServiceList) {
//       final name = r.category?.name ?? 'Unknown';
//       map.putIfAbsent(name, () => []);
//       map[name]!.add(r);
//     }
//
//     return map;
//   }
// }


import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';


import '../../../../core/controllers/auth_controller.dart';
import '../../../../data/services/network_caller.dart';
import '../models/hire_service_model.dart';
import '../models/provider_massage_service_model.dart';
import '../models/provider_pass_service_model.dart';
import '../models/provider_resturant_service.dart' show Result;
import '../models/provider_transport_service_model.dart';

class AllServiceController extends GetxController {
  /// Lists for different provider types
  List<SkiPass> skiPassList = [];
  List<Result> restaurantServiceList = [];
  List<MassageResult> massageServiceList = [];
  List<TransportResult> transportServiceList = [];
  List<HireResult> hireServiceList = [];

  final authController = Get.find<AuthController>();

  /// Loading state
  bool isLoading = false;

  /// Error message
  String? errorMessage;

  /// Cache last URL for refresh
  String? lastFetchedUrl;

  /// Fetch ANY service list (generic)
  Future<bool> fetchServices(String url, {bool showLoader = true}) async {
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
      if (showLoader) {
        isLoading = false;
        update();
      }
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


  /// Removes an item locally from the correct list after a successful delete API call
  void removeItemFromList(String itemId, String providerType) {
    int initialLength;

    switch (providerType) {
      case 'Ski_Pass':
        initialLength = skiPassList.length;
        skiPassList.removeWhere((item) => item.id == itemId);
        if (skiPassList.length < initialLength) update();
        break;

      case 'Restaurant':
        initialLength = restaurantServiceList.length;
        restaurantServiceList.removeWhere((item) => item.sId == itemId);
        if (restaurantServiceList.length < initialLength) update();
        break;

      case 'Massage':
        initialLength = massageServiceList.length;
        massageServiceList.removeWhere((item) => item.sId == itemId);
        if (massageServiceList.length < initialLength) update();
        break;

      case 'Transport':
        initialLength = transportServiceList.length;
        transportServiceList.removeWhere((item) => item.sId == itemId);
        if (transportServiceList.length < initialLength) update();
        break;

      case 'Ski_Hire':
        initialLength = hireServiceList.length;
        hireServiceList.removeWhere((item) => item.id == itemId);
        if (hireServiceList.length < initialLength) update();
        break;
    }
  }

  /// Clear all lists
  void clearLists() {
    skiPassList = [];
    restaurantServiceList = [];
    massageServiceList = [];
    transportServiceList = [];
    hireServiceList = [];
  }

  /// Restaurant helpers remain unchanged
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

