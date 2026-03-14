import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/api_urls.dart';
import 'package:harry_service_app/app/data/models/network_response.dart';
import 'package:harry_service_app/app/data/services/network_caller.dart';
import 'package:harry_service_app/app/modules/user/itinerary/models/my_itineraray_model.dart';

class GetAllItineraryController extends GetxController {

  MyItinerary? myItinerary;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> getMyItinerary() async {

    _isLoading = true;
    _errorMessage = null;
    update();

    try {

      NetworkResponse response =
      await Get.find<NetworkCaller>().getRequest(
        url: AppUrls.myItineraryUrl,
      );

      if (response.statusCode == 200 && response.body != null) {

        myItinerary = MyItinerary.fromJson(response.body!);
        return true;

      } else {

        _errorMessage = response.errorMessage ?? "Failed to fetch itinerary";
        return false;

      }

    } catch (e) {

      _errorMessage = e.toString();
      return false;

    } finally {

      // This will always run
      _isLoading = false;
      update();

    }
  }


}