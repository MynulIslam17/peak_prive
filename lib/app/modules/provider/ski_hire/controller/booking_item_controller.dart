import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/api_urls.dart';
import 'package:harry_service_app/app/data/services/network_caller.dart';

import '../models/hire_item_model.dart';


class ItemController extends GetxController {
  HireItemModel? hireItem;
  bool isLoading = false;
  String? errorMessage;

  // Getter shortcuts
  User? get user => hireItem?.data?.user;
  Product? get product => hireItem?.data?.product;
  List<BookingItems>? get bookingItems => hireItem?.data?.bookingItems;
  String? get bookingStatus => hireItem?.data?.bookingStatus;
  int? get totalPrice => hireItem?.data?.totalPrice;

  Future<void> fetchBookingById(String bookingId) async {
    isLoading = true;
    update();

    try {
      final response = await Get.find<NetworkCaller>().getRequest(
        url: AppUrls.bookingSingleItem(bookingId),
      );

      if (response.statusCode == 200 && response.body?['data'] != null) {
        hireItem = HireItemModel.fromJson(response.body!);
      } else {
        errorMessage = "Failed to load booking: ${response.statusCode}";
      }
    } catch (e) {
      errorMessage = "Something went wrong: $e";
    } finally {
      isLoading = false;
      update();
    }
  }
}
