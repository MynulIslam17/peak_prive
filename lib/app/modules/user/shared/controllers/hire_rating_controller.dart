import 'package:get/get.dart';
import 'package:harry_service_app/app/core/controllers/auth_controller.dart';
import 'package:harry_service_app/app/core/controllers/nav_controller.dart';
import '../../../../core/constants/api_urls.dart';
import '../../../../data/models/network_response.dart';
import '../../../../data/services/network_caller.dart';

class HireRatingController extends GetxController {
  final navController=Get.find<NavController>();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;


  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;


  String findServiceType() {
    final type = navController.getServiceType;

    switch (type) {
      case "ski_pass":
        return "ski-pass";
      case "ski_hire":
        return "ski-hire";
      case "transport":
        return "transport";
      case "massage":
        return "massage";
      default:
        return "restaurant";
    }
  }



  Future<bool> sendRating(String productId, Map<String, dynamic> body) async {
    bool success = false;

    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    update();

    try {
      NetworkResponse response = await Get.find<NetworkCaller>().postRequest(
        url: AppUrls.bookingReviewUrl(productId: productId ,serviceType: findServiceType()),
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
