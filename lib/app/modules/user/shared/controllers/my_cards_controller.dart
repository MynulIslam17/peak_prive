import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/api_urls.dart';
import 'package:harry_service_app/app/data/models/network_response.dart';
import '../../../../data/services/network/network_caller.dart';
import '../models/my_card_model.dart';


class MyCardsController extends GetxController {
  // -----------------------------
  // STATE
  // -----------------------------
  bool _isLoading = false;
  String? _errorMessage;
  List<WalletAccount> _cards = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<WalletAccount> get cards => _cards;

  // -----------------------------
  // FETCH CARDS FUNCTION
  // -----------------------------
  Future<void> fetchMyCards() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      update();

      // API CALL
      NetworkResponse response = await Get.find<NetworkCaller>().getRequest(
        url: AppUrls.myCards,
      );

      if (response.isSuccess && response.body != null) {
        MyCardsModel myCards = MyCardsModel.fromJson(response.body!);

        _cards = myCards.data.walletAccounts;

      } else {
        _errorMessage = response.errorMessage ?? "Failed to fetch cards";
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      update();
    }
  }




}