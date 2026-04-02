import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/api_urls.dart';
import 'package:harry_service_app/app/data/models/network_response.dart';

import '../../../../data/services/network/network_caller.dart';

class AddAccountController extends GetxController {

  // -----------------------------
  // STATE
  // -----------------------------
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // -----------------------------
  // ADD ACCOUNT FUNCTION
  // -----------------------------
  Future<bool> addAccount(
      String accountType,
      String cardHolderName,
      int cardNumber,
      ) async {

    try {
      _isLoading = true;
      _errorMessage = null;
      update();

      // -----------------------------
      // REQUEST BODY
      // -----------------------------
      Map<String, dynamic> body = {
        "accountType": accountType,
        "cardHolderName": cardHolderName,
        "cardNumber": cardNumber,
      };

      // -----------------------------
      // API CALL
      // -----------------------------
      NetworkResponse response =
      await Get.find<NetworkCaller>().postRequest(
        url: AppUrls.addCard,
        body: body,
      );

      // -----------------------------
      // RESPONSE HANDLE
      // -----------------------------
      if (response.isSuccess) {
        return true;
      } else {
        _errorMessage = response.errorMessage ?? "Failed to add account";
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