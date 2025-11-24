import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/api_urls.dart';
import 'package:harry_service_app/app/data/services/network_caller.dart';
import '../models/massage_details_model.dart';

class MassageDetailsController extends GetxController {
  MassageDetails? massage;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetch a single massage detail by id
  Future<bool> fetchMassageDetails(String id) async {
    _isLoading = true;
    _errorMessage = null;
    update();

    bool success = false;

    try {
      final response = await Get.find<NetworkCaller>().getRequest(
        url: AppUrls.massageDetailsUrl(id), // implement this in AppUrls
      );

      if (response.isSuccess && response.body != null) {
        final data = response.body!['data'];
        massage = MassageDetails.fromJson(data as Map<String, dynamic>?);
        success = true;
      } else {
        _errorMessage = response.body?['message'] ?? "Failed to fetch massage details";
        success = false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      success = false;
    } finally {
      _isLoading = false;
      update();
    }

    return success;
  }

  /// Clear the current massage data
  void clearData() {
    massage = null;
    _errorMessage = null;
    _isLoading = false;
    update();
  }
}
