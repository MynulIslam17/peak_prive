import 'dart:async';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/api_urls.dart';
import 'package:harry_service_app/app/data/models/network_response.dart';
import 'package:harry_service_app/app/data/services/network/network_caller.dart';
import '../models/ski_pass_model.dart';


class AllPassController extends GetxController {
  List<SkiPass> skiPassList = [];
  bool _isLoading = false;        // initial load
  bool _isMoreLoading = false;    // pagination load
  bool _hasMore = true;
  String? _errorMessage;

  int _page = 1;
  final int _limit = 10;

  /// Debounce search
  Timer? _debounceTimer;
  int _requestCounter = 0;

  // Getters for UI
  bool get isLoading => _isLoading;
  bool get isMoreLoading => _isMoreLoading;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;

  /// 🔹 Debounced search
  void searchPass(String? search) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      fetchAllPass(search: search);
    });
  }

  /// 🔹 Fetch passes with pagination
  Future<void> fetchAllPass({String? search, bool isLoadMore = false}) async {
    // guard clauses
    if (_isLoading || _isMoreLoading) return;
    if (isLoadMore && !_hasMore) return;

    _errorMessage = null;
    if (isLoadMore) {
      _isMoreLoading = true;
    } else {
      _isLoading = true;
      _page = 1;
      _hasMore = true;
      skiPassList.clear();
    }
    update();

    final int requestId = ++_requestCounter;

    try {
      String url = "${AppUrls.passAllServiceUrl}?page=$_page&limit=$_limit";

      if (search != null && search.trim().isNotEmpty) {
        final encodedSearch = Uri.encodeQueryComponent(search.trim());
        url += "&search=$encodedSearch";
      }

      NetworkResponse response = await Get.find<NetworkCaller>().getRequest(url: url);

      // Ignore outdated requests
      if (requestId != _requestCounter) return;

      if (response.isSuccess && response.body != null) {
        final SkiPassResponse responseData = SkiPassResponse.fromJson(response.body!);

        final List<SkiPass> newItems = responseData.data.result;
        skiPassList.addAll(newItems);

        // pagination logic
        if (_page >= responseData.data.pagination.totalPages || newItems.length < _limit) {
          _hasMore = false;
        } else {
          _page++;
        }
      } else {
        _errorMessage = response.errorMessage ?? "Can't fetch data";
      }
    } catch (e) {
      _errorMessage = "An unexpected error occurred: $e";
    } finally {
      _isLoading = false;
      _isMoreLoading = false;
      update();
    }
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }
}