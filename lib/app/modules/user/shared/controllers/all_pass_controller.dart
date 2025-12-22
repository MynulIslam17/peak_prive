import 'dart:async';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/api_urls.dart';
import 'package:harry_service_app/app/data/models/network_response.dart';
import 'package:harry_service_app/app/data/services/network_caller.dart';
import '../models/ski_pass_model.dart';

class AllPassController extends GetxController {
  List<SkiPass> skiPassList = [];

  bool _fetchProgress = false;
  String? _errorMessage;

  /// Search control
  Timer? _debounceTimer;
  int _requestCounter = 0;

  bool get fetchProgress => _fetchProgress;
  String? get errorMessage => _errorMessage;

  /// 🔹 Debounced search entry point (optional use)
  void searchPass(String? search) {
    _debounceTimer?.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      fetchAllPass(search);
    });
  }

  /// 🔹 Backward-compatible fetch
  Future<bool> fetchAllPass([String? search]) async {
    final int requestId = ++_requestCounter;
    bool success = false;

    _fetchProgress = true;
    _errorMessage = null;
    update();

    try {
      String url = AppUrls.passAllServiceUrl;

      if (search != null && search.trim().isNotEmpty) {
        final encodedSearch = Uri.encodeQueryComponent(search.trim());
        url += url.contains('?')
            ? '&search=$encodedSearch'
            : '?search=$encodedSearch';
      }

      NetworkResponse response =
      await Get.find<NetworkCaller>().getRequest(url: url);

      /// Ignore outdated responses
      if (requestId != _requestCounter) return false;

      if (response.isSuccess && response.body != null) {
        final data = response.body!['data'];
        final List<dynamic> resultList = data['result'] ?? [];

        skiPassList = resultList
            .map((item) => SkiPass.fromJson(item))
            .toList();

        success = true;
      } else {
        _errorMessage = response.errorMessage ?? "Can't fetch data";
      }
    } finally {
      if (requestId == _requestCounter) {
        _fetchProgress = false;
        update();
      }
    }

    return success;
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }
}
