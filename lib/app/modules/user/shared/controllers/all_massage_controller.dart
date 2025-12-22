import 'dart:async';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/api_urls.dart';
import 'package:harry_service_app/app/data/services/network_caller.dart';
import '../models/all_massage_model.dart';
import '../models/category_model.dart';

class MassageController extends GetxController {
  /// Data
  final List<Massage> massageList = [];
  final List<ServiceCategory> categoryList = [];

  bool _isLoading = false;
  String? _errorMessage;
  String? selectedCategoryName;

  /// Search control
  Timer? _debounceTimer;
  int _requestCounter = 0;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Public search trigger (call this from UI)
  void searchMassage({String? category, String? search}) {
    _debounceTimer?.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      fetchAllMassageAndCategory(category, search);
    });
  }

  /// Core fetch method
  Future<bool> fetchAllMassageAndCategory([
    String? category,
    String? search,
  ]) async {

    final int requestId = ++_requestCounter;

    _isLoading = true;
    _errorMessage = null;
    update();

    try {
      selectedCategoryName = category;

      /// Build URL safely
      String url = AppUrls.massageServiceUrl(category);

      if (search != null && search.trim().isNotEmpty) {
        final encodedSearch = Uri.encodeQueryComponent(search.trim());
        url += url.contains('?')
            ? '&search=$encodedSearch'
            : '?search=$encodedSearch';
      }

      /// Fetch massage services
      final massageResponse =
      await Get.find<NetworkCaller>().getRequest(url: url);

      /// Ignore outdated responses
      if (requestId != _requestCounter) return false;

      if (!massageResponse.isSuccess || massageResponse.body == null) {
        _errorMessage = 'Failed to load massage services';
        massageList.clear();
        return false;
      }

      final data = massageResponse.body!['data']?['result'] as List<dynamic>? ?? [];

      massageList
        ..clear()
        ..addAll(
          data.map(
                (e) => Massage.fromJson(e as Map<String, dynamic>),
          ),
        );

      /// Fetch categories only once
      if (categoryList.isEmpty) {
        final categoryResponse =
        await Get.find<NetworkCaller>().getRequest(
          url: AppUrls.massageCategoryUrl,
        );

        if (categoryResponse.isSuccess && categoryResponse.body != null) {
          final list = categoryResponse.body!['data'] as List<dynamic>? ?? [];
          categoryList.addAll(
            list.map(
                  (e) => ServiceCategory.fromJson(e as Map<String, dynamic>),
            ),
          );
        }
      }

      return true;
    } catch (e) {
      if (requestId == _requestCounter) {
        _errorMessage = e.toString();
      }
      return false;
    } finally {
      if (requestId == _requestCounter) {
        _isLoading = false;
        update();
      }
    }
  }

  /// Clear all data
  void clearData() {
    _debounceTimer?.cancel();
    massageList.clear();
    categoryList.clear();
    selectedCategoryName = null;
    _errorMessage = null;
    update();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }
}
