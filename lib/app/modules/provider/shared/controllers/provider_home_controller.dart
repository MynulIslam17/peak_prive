import 'dart:async';

import 'package:get/get.dart';

import '../../../../core/controllers/auth_controller.dart';
import '../../../../data/api/peak_api.dart';
import '../../../../data/services/socket/live_events.dart';

/// Provider → Home: dashboard (`GET /dashboard/meta/provider`) plus a few of
/// the provider's own listings. Works for every provider type.
class ProviderHomeController extends GetxController {
  ProviderHomeController({ServiceKind? kind, Duration liveDebounce = const Duration(milliseconds: 800)})
      : _kindOverride = kind,
        _liveDebounce = liveDebounce;

  final ServiceKind? _kindOverride;
  final Duration _liveDebounce;

  ProviderDashboard? dashboard;

  /// Newest listings of this provider (up to [servicesShown]).
  List<ListingCard> services = const [];
  static const servicesShown = 6;

  bool isLoading = false;
  bool isRefreshing = false;
  String? errorMessage;

  StreamSubscription<BookingUpdate>? _liveSub;
  Timer? _liveTimer;
  int _request = 0;

  PeakApi get _api => Get.find<PeakApi>();

  /// The provider's service, from the logged-in account.
  ServiceKind? get kind {
    if (_kindOverride != null) return _kindOverride;
    if (!Get.isRegistered<AuthController>()) return null;
    return ServiceKind.parse(Get.find<AuthController>().userModel?.providerType);
  }

  /// Bookings waiting for approval (nav badge).
  int get requestCount => dashboard?.bookings.requests ?? 0;

  @override
  void onInit() {
    super.onInit();
    _liveSub = LiveEvents.bookingUpdates.listen((_) {
      _liveTimer?.cancel();
      _liveTimer = Timer(_liveDebounce, refreshData);
    });
  }

  @override
  void onClose() {
    _liveSub?.cancel();
    _liveTimer?.cancel();
    super.onClose();
  }

  /// Loads the dashboard and listings. With [showLoader] false the current
  /// data stays on screen (pull to refresh, live updates).
  /// Returns true when the dashboard loaded.
  Future<bool> fetchProviderHomeData({bool showLoader = true}) async {
    final id = ++_request;
    if (showLoader && dashboard == null) {
      isLoading = true;
    } else {
      isRefreshing = true;
    }
    errorMessage = null;
    update();

    final k = kind;
    final results = await Future.wait([
      _api.dashboard.provider(),
      if (k != null) _api.listings.mine(k, page: 1, limit: servicesShown),
    ]);
    if (id != _request) return false; // a newer load replaced this one

    final dash = results[0] as ApiResult<ProviderDashboard>;
    if (dash.isSuccess) {
      dashboard = dash.data;
    } else {
      // Keep old numbers on screen; show the error only when there are none.
      errorMessage = dash.errorMessage;
    }
    if (results.length > 1) {
      final list = results[1] as ApiResult<Paged<ListingCard>>;
      if (list.isSuccess) services = list.data!.items;
    }
    isLoading = false;
    isRefreshing = false;
    update();
    return dash.isSuccess;
  }

  Future<void> refreshData() => fetchProviderHomeData(showLoader: false);

  /// Deletes one of the listings shown on Home. On success it disappears at
  /// once; a 409 (open bookings) leaves it and returns the server's message.
  Future<ApiResult<void>> deleteListing(ListingCard card) async {
    final r = await _api.listings.delete(card.kind, card.id);
    if (r.isSuccess) {
      services = services.where((s) => s.id != card.id).toList();
      update();
      unawaited(refreshData());
    }
    return r;
  }
}
