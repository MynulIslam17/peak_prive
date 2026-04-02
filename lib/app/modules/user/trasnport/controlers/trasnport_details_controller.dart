import 'package:get/get.dart';
import 'package:harry_service_app/app/modules/user/trasnport/model/transport_details_model.dart';

import '../../../../core/constants/api_urls.dart';
import '../../../../data/services/network/network_caller.dart';

class TransportDetailsController extends GetxController {

  TransportDetailsModel? transportDetails;

  bool _fetchProgress = false;
  String? _errorMessage;

  bool get fetchProgress => _fetchProgress;
  String? get errorMessage => _errorMessage;

  Future<bool> fetchTransportDetails(String id) async {
    _fetchProgress = true;
    update();

    try {
      final response = await Get.find<NetworkCaller>().getRequest(
        url: AppUrls.transportDetailsUrl(id),
      );

      if (response.isSuccess && response.body != null) {

        /// Extract "data" from the response
        final data = response.body!['data'];

        /// Parse into model
        transportDetails = TransportDetailsModel.fromJson(data);

        _errorMessage = null;
        return true;

      } else {
        _errorMessage = response.errorMessage ?? "Can't fetch transport details";
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _fetchProgress = false;
      update();
    }
  }
}
