import 'package:get/get.dart';
import 'package:harry_service_app/app/data/services/network_caller.dart';

class BookingStatusController extends GetxController {
  bool? _isPermitted;
  bool isLoading = false;
  String? errorMessage;

  bool? get isPermitted => _isPermitted;

  /// Initialize controller with existing status
  void setInitialStatus(bool status) {
    _isPermitted = status;
    update();
  }

  /// Change booking status (approve)
  Future<void> changeStatus({
    required String apiUrl,
    required bool status,
  }) async {
    isLoading = true;
    update();

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
    } finally {
      isLoading = false;
      update();
    }
  }
}
