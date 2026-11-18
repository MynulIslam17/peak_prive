import 'package:get/get.dart';

import '../../../../data/api/peak_api.dart';

/// Loads one listing (`GET /<service>/:id`) and its first page of reviews
/// (`GET /<service>/:id/reviews`). Subclasses add the service's own state
/// (e.g. the hire equipment selection).
class ListingDetailController<T extends ListingDetail> extends GetxController {
  ListingDetailController(this.kind);

  final ServiceKind kind;

  PeakApi get _api => Get.find<PeakApi>();

  T? listing;
  bool isLoading = false;
  String? errorMessage;

  static const int reviewPreviewLimit = 3;

  List<Review> reviews = const [];
  RatingSummary? reviewRating;
  bool reviewsLoading = false;
  bool reviewsHasMore = false;

  /// Set when reviews failed; the listing still shows.
  String? reviewsError;

  /// The listing shows three reviews. More than that opens the full list.
  bool get canSeeAllReviews {
    if (reviewsError != null && reviews.isEmpty) return false;
    return reviewsHasMore ||
        reviews.length > reviewPreviewLimit ||
        rating.count > reviewPreviewLimit;
  }

  String? _loadingId;

  /// Rating to show: the reviews endpoint's figure when loaded, else the card's.
  RatingSummary get rating => reviewRating ?? listing?.rating ?? RatingSummary.empty;

  /// Inactive listings stay visible but can't be booked.
  bool get canBook => listing?.isActive ?? false;

  Future<bool> fetch(String id) async {
    if (id.isEmpty) {
      errorMessage = 'This listing link is invalid.';
      update();
      return false;
    }
    if (listing?.id != id) {
      listing = null;
      reviews = const [];
      reviewRating = null;
      reviewsHasMore = false;
      onListingChanged();
    }
    _loadingId = id;
    isLoading = true;
    errorMessage = null;
    update();

    _loadReviews(id);
    final r = await _api.listings.detail(kind, id);
    if (_loadingId != id) return false; // another listing was opened
    isLoading = false;
    final data = r.data;
    if (r.isSuccess && data is T) {
      listing = data;
      onListingLoaded(data);
      update();
      return true;
    }
    errorMessage = r.isSuccess
        ? "We couldn't load this listing. Please try again."
        : r.failure!.isNotFound
            ? 'This listing is no longer available.'
            : r.errorMessage;
    update();
    return false;
  }

  Future<void> _loadReviews(String id) async {
    reviewsLoading = true;
    reviewsError = null;
    final r = await _api.listings.reviews(kind, id, limit: reviewPreviewLimit);
    if (_loadingId != id) return;
    reviewsLoading = false;
    if (r.isSuccess) {
      reviews = r.data!.reviews;
      reviewRating = r.data!.rating;
      final total = r.meta?.total ?? reviews.length;
      reviewsHasMore = r.meta?.hasMore == true || total > reviewPreviewLimit;
    } else {
      reviewsError = r.errorMessage;
      reviewsHasMore = false;
    }
    update();
  }

  /// Called when a different listing starts loading.
  void onListingChanged() {}

  /// Called after a successful load.
  void onListingLoaded(T listing) {}
}
