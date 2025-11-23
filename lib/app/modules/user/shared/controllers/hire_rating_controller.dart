import 'package:get/get.dart';
import '../../../../core/constants/api_urls.dart';
import '../../../../data/models/network_response.dart';
import '../../../../data/services/network_caller.dart';

class HireRatingController extends GetxController {
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<bool> sendRating(String productId, Map<String, dynamic> body) async {
    bool success = false;

    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    update();

    try {
      NetworkResponse response = await Get.find<NetworkCaller>().postRequest(
        url: AppUrls.hireBookingReviewUrl(productId),
        body: body,
      );

      if (response.isSuccess) {
        // Success message from server
        _successMessage = response.body?['message'] ?? "Review submitted successfully!";
        success = true;
      } else {
        // Error message from server
        _errorMessage = response.body?["message"] ?? "Review submission failed!";
      }
    } catch (e) {
      _errorMessage = "Something went wrong. Please try again.";
    } finally {
      _isLoading = false;
      update();
    }

    return success;
  }
}
