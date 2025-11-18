import 'package:get/get.dart';
import '../../../../core/constants/api_urls.dart';
import '../../../../data/models/network_response.dart';
import '../../../../data/services/network_caller.dart';
import '../models/pass_details_model.dart';

class PassDetailsController extends GetxController {

  PassDetails? passDetails;

  bool _fetchProgress = false;
  String? _errorMessage;

  bool get fetchProgress => _fetchProgress;
  String? get errorMessage => _errorMessage;

  Future<bool> fetchPass(String id) async {
    _fetchProgress = true;
    update();

    try {
      final response = await Get.find<NetworkCaller>().getRequest(
        url: AppUrls.singlePassDetails(id),
      );

      if (response.isSuccess && response.body != null) {
        final data = response.body!['data'];
        passDetails = PassDetails.fromJson(data); /// pass value to the model
        _errorMessage = null;
        return true;
      } else {
        _errorMessage = response.errorMessage ?? "Can't fetch pass details";
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
