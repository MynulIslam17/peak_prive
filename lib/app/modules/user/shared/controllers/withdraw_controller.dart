import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/api_urls.dart';
import 'package:harry_service_app/app/data/models/network_response.dart';
import '../../../../data/services/network/network_caller.dart';

class WithdrawRequestController extends GetxController {
  // -----------------------------
  // STATE
  // -----------------------------
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // -----------------------------
  // WITHDRAW FUNCTION
  // -----------------------------
  Future<bool> withdrawAmount({
    required String cardId,
    required double amount,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      update();

      // -----------------------------
      // REQUEST BODY
      // -----------------------------
      Map<String, dynamic> body = {
        "cardId": cardId,
        "amount": amount,
      };

      // -----------------------------
      // API CALL
      // -----------------------------
      NetworkResponse response =
      await Get.find<NetworkCaller>().postRequest(
        url: AppUrls.withdrawRequest,
        body: body,
      );

      // -----------------------------
      // RESPONSE HANDLE
      // -----------------------------
      if (response.isSuccess) {
        return true;
      } else {
        _errorMessage = response.errorMessage ?? "Failed to withdraw";
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      update();
    }
  }
}