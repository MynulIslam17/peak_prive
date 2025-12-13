import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/api_urls.dart';
import 'package:harry_service_app/app/core/controllers/auth_controller.dart';
import 'package:harry_service_app/app/data/services/network_caller.dart';

// Hide conflicting model names
import 'package:harry_service_app/app/modules/provider/restaurant/model/restaurant_item_model.dart'
    hide User, Product, BookingItems;

import '../models/hire_item_model.dart';
enum ProviderType {
  Ski_Hire,
  Restaurant,
}

class ItemController extends GetxController {
  final authController = Get.find<AuthController>();

  /// Provider-specific models
  HireItemModel? hireItem;
  RestaurantItemModel? restaurantItem;

  ProviderType? currentProvider;

  bool isLoading = false;
  String? errorMessage;

  /* ------------------------------------------------------------------
     COMMON DATA ACCESS (SAFE & BEGINNER FRIENDLY)
  ------------------------------------------------------------------ */

  /// Get unified booking data based on provider
  dynamic get _data {
    switch (currentProvider) {
      case ProviderType.Ski_Hire:
        return hireItem?.data;
      case ProviderType.Restaurant:
        return restaurantItem?.data;
      default:
        return null;
    }
  }

  /// Common shortcut getters
  User? get user => _data?.user;
  Product? get product => _data?.product;
  List<BookingItems>? get bookingItems => _data?.bookingItems;
  String? get bookingStatus => _data?.bookingStatus;
  int? get totalPrice => _data?.totalPrice;

  /* ------------------------------------------------------------------
     API CALL
  ------------------------------------------------------------------ */

  Future<void> fetchBookingById({
    required String bookingId,
    required ProviderType providerType,
  }) async {
    isLoading = true;
    currentProvider = providerType;
    errorMessage = null;
    update();

    try {
      final response = await Get.find<NetworkCaller>().getRequest(
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
}
