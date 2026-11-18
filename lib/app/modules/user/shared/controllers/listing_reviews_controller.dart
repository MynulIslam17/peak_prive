import 'package:get/get.dart';

import '../../../../data/api/peak_api.dart';

/// Every review for one listing (`GET /<service>/:id/reviews`), page by page.
class ListingReviewsController extends GetxController {
  ListingReviewsController({required this.kind, required this.listingId});

  final ServiceKind kind;
  final String listingId;

  final reviews = <Review>[];
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMore = false;
  String? errorMessage;
  int _page = 1;

  static const int pageSize = 20;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    _page = 1;
    isLoading = true;
    errorMessage = null;
    update();
    final result = await Get.find<PeakApi>().listings.reviews(kind, listingId, page: 1, limit: pageSize);
    isLoading = false;
    if (result.isSuccess) {
      reviews
        ..clear()
        ..addAll(result.data!.reviews);
      hasMore = result.meta?.hasMore ?? false;
    } else {
      errorMessage = result.errorMessage;
      hasMore = false;
    }
    update();
  }

  Future<void> loadMore() async {
    if (!hasMore || isLoadingMore || isLoading) return;
    isLoadingMore = true;
    update();
    final next = _page + 1;
    final result = await Get.find<PeakApi>().listings.reviews(kind, listingId, page: next, limit: pageSize);
    isLoadingMore = false;
    if (result.isSuccess) {
      _page = next;
      reviews.addAll(result.data!.reviews);
      hasMore = result.meta?.hasMore ?? false;
    }
    update();
  }
}
