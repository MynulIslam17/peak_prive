import 'package:get/get.dart';
import 'package:harry_service_app/app/modules/user/restaurant/models/restaurant_details_model.dart';
import '../../../../core/constants/api_urls.dart';
import '../../../../data/services/network/network_caller.dart';

class RestaurantDetailsController extends GetxController {
  RestaurantDetailsModel? restaurantDetails;

  bool _fetchProgress = false;
  String? _errorMessage;

  bool get fetchProgress => _fetchProgress;
  String? get errorMessage => _errorMessage;

  /// Fetch restaurant details by ID
  Future<bool> fetchRestaurantDetails(String id) async {
    _fetchProgress = true;
    update();

    try {
      final response = await Get.find<NetworkCaller>().getRequest(
        url: AppUrls.restaurantDetailsUrl(id),
      );

      if (response.isSuccess && response.body != null) {
        /// Extract "data" from the response
        final data = response.body!['data'];

        /// Parse into model
        restaurantDetails = RestaurantDetailsModel.fromJson({'data': data});

        _errorMessage = null;
        return true;
      } else {
        _errorMessage = response.errorMessage ?? "Can't fetch restaurant details";
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _fetchProgress = false;
      update();
    }
  }
}
