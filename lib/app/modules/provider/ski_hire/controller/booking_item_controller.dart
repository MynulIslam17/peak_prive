import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/api_urls.dart';
import 'package:harry_service_app/app/core/controllers/auth_controller.dart';
import 'package:harry_service_app/app/data/services/network_caller.dart';
import 'package:harry_service_app/app/modules/provider/pass/models/pass_item_model.dart';
import 'package:harry_service_app/app/modules/provider/transport/models/transport_Item_model.dart';

// Models
import '../models/hire_item_model.dart' hide User, Product;
import 'package:harry_service_app/app/modules/provider/restaurant/model/restaurant_item_model.dart'
    hide User, Product;
import '../../massage/models/massage_item_model.dart';

enum ProviderType {
  Ski_Hire,
  Restaurant,
  Massage,
  Transport,
  Ski_Pass
}

class ItemController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final NetworkCaller networkCaller = Get.find<NetworkCaller>();

  /// Provider-specific booking models
  HireItemModel? hireItem;
  RestaurantItemModel? restaurantItem;
  MassageItemModel? massageItem;
  TransportItemModel? transportItem;
  SkiPassItemModel? passItem;

  ProviderType? currentProvider;

  bool isLoading = false;
  String? errorMessage;

  /// Fetch booking by ID
  Future<void> fetchBookingById({
    required String bookingId,
    required ProviderType providerType,
  }) async {
    isLoading = true;
    errorMessage = null;
    currentProvider = providerType;
    update();

    try {
      final response = await networkCaller.getRequest(
        url: AppUrls.bookingSingleItem(bookingId),
      );

      if (response.statusCode == 200 && response.body != null) {
        final body = response.body!;

        switch (providerType) {
          case ProviderType.Ski_Hire:
            hireItem = HireItemModel.fromJson(body);
            break;

          case ProviderType.Restaurant:
            restaurantItem = RestaurantItemModel.fromJson(body);
            break;

          case ProviderType.Massage:
            massageItem = MassageItemModel.fromJson(body);
            break;

          case ProviderType.Transport:
            transportItem = TransportItemModel.fromJson(body);
            break;

          case ProviderType.Ski_Pass:
            passItem = SkiPassItemModel.fromJson(body);
            break;
        }
      } else {
        errorMessage = "Booking not found";
      }
    } catch (e, stackTrace) {
      debugPrint("Error fetching booking: $e\n$stackTrace");
      errorMessage = "An error occurred while fetching the booking.";
    } finally {
      isLoading = false;
      update();
    }
  }

  /// Clear controllers state
  void clearAll() {
    hireItem = null;
    restaurantItem = null;
    massageItem = null;
    transportItem = null;
    passItem = null;
    currentProvider = null;
    errorMessage = null;
    isLoading = false;
    update();
  }
}
