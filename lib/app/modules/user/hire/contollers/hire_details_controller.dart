import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/api_urls.dart';
import 'package:harry_service_app/app/data/models/network_response.dart';
import 'package:harry_service_app/app/data/services/network/network_caller.dart';
import '../models/hire_details_model.dart';

class HireDetailsController extends GetxController {
  HireDetailsModel? hireDetails;
  bool isLoading = false;
  String? errorMessage;

  /// NEW: Store selected item quantities
  Map<String, int> selectedItems = {};

  /// Add quantity for item
  void addItem(String itemId) {
    selectedItems[itemId] = (selectedItems[itemId] ?? 0) + 1;
    update();
  }

  /// Remove quantity for item
  void removeItem(String itemId) {
    if (!selectedItems.containsKey(itemId)) return;

    if (selectedItems[itemId]! > 1) {
      selectedItems[itemId] = selectedItems[itemId]! - 1;
    } else {
      selectedItems.remove(itemId);
    }
    update();
  }

  /// Get quantity instantly
  int getQuantity(String itemId) {

    return selectedItems[itemId] ?? 0;

  }

  /// Calculate total price based on quantity × item price
  double get totalSelectedPrice {
    if (hireDetails == null) return 0;

    double total = 0;

    for (var item in hireDetails!.items) {
      if (selectedItems.containsKey(item.id)) {
        total += item.price * selectedItems[item.id]!;
      }
    }

    return total;
  }

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
