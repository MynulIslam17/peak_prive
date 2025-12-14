import 'package:get/get.dart';
import 'package:harry_service_app/app/data/services/network_caller.dart';

class BookingStatusController extends GetxController {
  bool? _isPermitted;
  bool isLoading = false; // button loading
  String? errorMessage;

  bool? get isPermitted => _isPermitted;

  void setInitialStatus(bool status) {
    _isPermitted = status;
    update();
  }

  /// Set button loading
  void setLoading(bool value) {
    isLoading = value;
    update(); // only refresh button
  }

  Future<void> changeStatus({
    required String apiUrl,
    required bool status,
  }) async {
    try {
      final response = await Get.find<NetworkCaller>().patchRequest(
        url: apiUrl,
        body: {'isPermitted': status},
      );

      if (response.isSuccess) {
        _isPermitted = status;
      } else {
        errorMessage = response.errorMessage;
      }
    } catch (e) {
      errorMessage = e.toString();
    }
  }
}

