import 'package:get/get.dart';
import 'package:harry_service_app/app/data/services/network/network_caller.dart';
import 'package:harry_service_app/app/data/models/network_response.dart';

class DeleteController extends GetxController {
  bool isLoading = false;
  String? errorMessage;

  /// Delete ski pass by ID
  Future<bool> deleteItem({required String url}) async {
    isLoading = true;
    errorMessage = null;
    update();

    try {
      NetworkResponse response = await Get.find<NetworkCaller>().deleteRequest(url: url);

      if (response.statusCode == 200) {
        return true;
      } else {
        errorMessage = "Failed to delete pass: ${response.statusCode}";
        return false;
      }
    } catch (e) {
      errorMessage = "Error: $e";
      return false;
    } finally {
      isLoading = false;
      update(); // Ensure UI is updated regardless of success/error
    }
  }
}
