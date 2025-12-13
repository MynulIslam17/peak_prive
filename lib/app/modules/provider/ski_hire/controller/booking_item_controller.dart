import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/api_urls.dart';
import 'package:harry_service_app/app/core/controllers/auth_controller.dart';
import 'package:harry_service_app/app/data/services/network_caller.dart';

// Import models
import '../../massage/models/massage_item_model.dart';
import '../models/hire_item_model.dart' hide User, Product;
import 'package:harry_service_app/app/modules/provider/restaurant/model/restaurant_item_model.dart'
    hide User, Product;

enum ProviderType { Ski_Hire, Restaurant, Massage }

class ItemController extends GetxController {
  final authController = Get.find<AuthController>();
  final networkCaller = Get.find<NetworkCaller>();

  // Store booking data for each provider
  HireItemModel? hireItem;
  RestaurantItemModel? restaurantItem;
  MassageItemModel? massageItem;

  ProviderType? currentProvider;
  bool isLoading = false;
  String? errorMessage;

  /// Fetch booking by ID
  Future<void> fetchBookingById({
    required String bookingId,
    required ProviderType providerType,
  }) async {
    isLoading = true;
    currentProvider = providerType;
    errorMessage = null;
    update();

    try {
      final response = await networkCaller.getRequest(
        url: AppUrls.bookingSingleItem(bookingId),
      );

      if (response.statusCode == 200 && response.body?['data'] != null) {
        switch (providerType) {
          case ProviderType.Ski_Hire:
            hireItem = HireItemModel.fromJson(response.body!);
            break;
          case ProviderType.Restaurant:
            restaurantItem = RestaurantItemModel.fromJson(response.body!);
            break;
          case ProviderType.Massage:
            massageItem = MassageItemModel.fromJson(response.body!);
            break;
        }
      } else {
        errorMessage = "Failed to load booking (${response.statusCode})";
      }
    } catch (e) {
      errorMessage = "Something went wrong: $e";
    } finally {
      isLoading = false;
      update();
    }
  }

  /// Clear all data
  void clearAll() {
    hireItem = null;
    restaurantItem = null;
    massageItem = null;
    currentProvider = null;
    errorMessage = null;
    isLoading = false;
    update();
  }
}
