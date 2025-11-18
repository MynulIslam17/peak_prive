import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/api_urls.dart';
import 'package:harry_service_app/app/data/models/network_response.dart';

import 'package:harry_service_app/app/data/services/network_caller.dart';

import '../models/ski_pass_model.dart';


class AllPassController extends GetxController {
  List<SkiPass> skiPassList = [];

  bool _fetchProgress = false;
  String? _errorMessage;

  bool get fetchProgress => _fetchProgress;
  String? get errorMessage => _errorMessage;

  Future<bool> fetchAllPass() async {
    bool success = false;

    _fetchProgress = true;
    update();

    try {
      NetworkResponse response = await Get.find<NetworkCaller>().getRequest(
        url: AppUrls.passAllServiceUrl,
      );

      if (response.isSuccess) {
        final data = response.body!['data'];
         List<dynamic> resultList = data['result'];
         skiPassList = resultList.map((item) => SkiPass.fromJson(item)).toList();



        success = true;
        _errorMessage = null;
      } else {
        _errorMessage = response.errorMessage ?? "Can't fetch data";
      }
    } finally {
      _fetchProgress = false;
      update();
    }

    return success;
  }
}
