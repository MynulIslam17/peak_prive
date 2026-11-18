import 'dart:async';

import 'package:get/get.dart';

import '../../../../data/api/peak_api.dart';
import '../../../../data/services/socket/live_events.dart';

/// Filter chips on the provider Bookings tab, each one a server tab.
enum ProviderBookingFilter {
  all(null, 'All'),
  requests(BookingTab.requests, 'Needs approval'),
  upcoming(BookingTab.upcoming, 'Upcoming'),
  active(BookingTab.active, 'In progress'),
  past(BookingTab.past, 'Completed'),
  cancelled(BookingTab.cancelled, 'Cancelled');

  const ProviderBookingFilter(this.tab, this.label);

  /// `null` = every booking, newest first.
  final BookingTab? tab;
  final String label;
}

/// Outcome of a quick Accept / Reject from the list.
class QuickActionResult {
  const QuickActionResult(this.ok, this.message, {this.conflict = false});
  final bool ok;
  final String message;

  /// The booking changed meanwhile; the list was reloaded.
  final bool conflict;
}

/// One filter's loaded pages (kept while the provider switches filters).
class _FilterPage {
  List<Booking> items = const [];
  int total = 0;
  int page = 1;
  bool hasMore = false;
  bool fetched = false;
  int request = 0;
}

/// Provider → Bookings (`GET /booking/provider?tab=…`), a page at a time.
///
/// Each filter keeps what it loaded: switching filters (or coming back to the
/// tab) shows the cached list at once and refreshes it quietly. The skeleton
/// is shown only while a filter has never loaded.
class ProviderBookingsController extends GetxController {
  ProviderBookingsController({this.pageSize = 20, Duration liveDebounce = const Duration(milliseconds: 800)})
      : _liveDebounce = liveDebounce;

  final int pageSize;
  final Duration _liveDebounce;

  ProviderBookingFilter filter = ProviderBookingFilter.all;
  final Map<ProviderBookingFilter, _FilterPage> _pages = {for (final f in ProviderBookingFilter.values) f: _FilterPage()};
  _FilterPage get _cur => _pages[filter]!;

  List<Booking> get bookings => _cur.items;

  /// Total for the current filter (all pages).
  int get total => _cur.total;

  /// First load of the current filter (nothing to show yet).
  bool get isLoading => _loading.contains(filter) && !_cur.fetched;
  final Set<ProviderBookingFilter> _loading = {};
  bool isLoadingMore = false;
  String? errorMessage;

  /// Bookings with an Accept/Reject in flight (double-tap guard).
  final Set<String> busyIds = {};

  StreamSubscription<BookingUpdate>? _liveSub;
  Timer? _liveTimer;

  bool get hasMore => _cur.hasMore;
  PeakApi get _api => Get.find<PeakApi>();

  @override
  void onInit() {
    super.onInit();
    _liveSub = LiveEvents.bookingUpdates.listen((_) {
      _liveTimer?.cancel();
      _liveTimer = Timer(_liveDebounce, refreshBookings);
    });
  }

  @override
  void onClose() {
    _liveSub?.cancel();
    _liveTimer?.cancel();
    super.onClose();
  }

  Future<ApiResult<Paged<Booking>>> _fetch(ProviderBookingFilter f, int page) =>
      _api.bookings.forProvider(tab: f.tab, page: page, limit: pageSize);

  /// Preselects a filter before the Bookings tab opens or is revisited (the
  /// tab refreshes it).
  void preselect(ProviderBookingFilter f) {
    if (f == filter) return;
    filter = f;
    errorMessage = null;
    update();
  }

  /// Switches the filter: shows its cached list at once and refreshes it.
  Future<void> setFilter(ProviderBookingFilter f) async {
    if (f != filter) {
      filter = f;
      errorMessage = null;
      isLoadingMore = false;
      update();
    }
    await fetchBookings();
  }

  /// First page of the current filter. The skeleton shows only if the filter
  /// has nothing loaded yet; otherwise the list stays visible and is kept if
  /// the refresh fails. ([showLoader] is kept for callers; a loaded list never
  /// shows the loader again.)
  Future<void> fetchBookings({bool showLoader = true}) async {
    final f = filter;
    final p = _pages[f]!;
    final id = ++p.request;
    _loading.add(f);
    if (f == filter) {
      isLoadingMore = false;
      errorMessage = null;
      update();
    }

    final r = await _fetch(f, 1);
    if (id != p.request) return; // a newer refresh of this filter is running
    _loading.remove(f);
    if (r.isSuccess) {
      p
        ..page = 1
        ..items = r.data!.items
        ..fetched = true;
      p.total = r.data!.meta.total < p.items.length ? p.items.length : r.data!.meta.total;
      p.hasMore = r.data!.hasMore && p.items.isNotEmpty;
    } else if (f == filter) {
      errorMessage = r.errorMessage;
    }
    update();
  }

  Future<void> refreshBookings() => fetchBookings(showLoader: false);

  Future<void> loadMore() async {
    final f = filter;
    final p = _cur;
    if (!p.hasMore || isLoadingMore || isLoading) return;
    final id = p.request;
    isLoadingMore = true;
    update();
    final r = await _fetch(f, p.page + 1);
    if (id != p.request) return;
    if (r.isSuccess) {
      p.page++;
      final seen = p.items.map((b) => b.id).toSet();
      final fresh = r.data!.items.where((b) => !seen.contains(b.id)).toList();
      p.items = [...p.items, ...fresh];
      // Stop when the server says so or a page brings nothing new.
      p.hasMore = r.data!.hasMore && fresh.isNotEmpty;
    }
    // On failure keep what is loaded; scrolling again retries.
    if (f == filter) isLoadingMore = false;
    update();
  }

  /// Accept or reject straight from the list. Only offered when the booking
  /// lists the action. On "Needs approval" the card leaves the list at once
  /// and comes back if the server refuses. A 409 (changed meanwhile) reloads.
  Future<QuickActionResult> quickAction(Booking b, BookingAction action, {String? reason}) async {
    if (action != BookingAction.approve && action != BookingAction.reject) {
      return const QuickActionResult(false, 'Open the booking to do this.');
    }
    if (!b.can(action)) {
      return const QuickActionResult(false, 'This booking can no longer be changed here.');
    }
    if (!busyIds.add(b.id)) return const QuickActionResult(false, '');
    final f = filter;
    final p = _cur;
    final before = p.items;
    final beforeTotal = p.total;
    // Optimistic: an answered request no longer needs approval.
    if (f == ProviderBookingFilter.requests) {
      p.items = [for (final x in p.items) if (x.id != b.id) x];
      if (p.total > 0) p.total--;
    }
    update();
    try {
      final r = await _api.bookings.act(b.id, action, reason: reason);
      if (r.isSuccess) {
        final updated = r.data!;
        final stillFits = f == ProviderBookingFilter.all ||
            (f == ProviderBookingFilter.requests && updated.status == BookingStatus.pending);
        if (f != ProviderBookingFilter.requests || stillFits) {
          final had = p.items.any((x) => x.id == b.id);
          p.items = [
            for (final x in (had ? p.items : before))
              if (x.id != b.id) x else if (stillFits) updated,
          ];
          if (!stillFits && p.total > 0) p.total--;
        }
        // Other filters now hold a stale copy; they refresh when opened.
        return QuickActionResult(
          true,
          action == BookingAction.approve ? 'Booking accepted.' : 'Booking rejected. The guest gets a full refund.',
        );
      }
      // Refused: put the card back.
      p
        ..items = before
        ..total = beforeTotal;
      if (r.failure!.isConflict) {
        unawaited(refreshBookings());
        return QuickActionResult(false, r.errorMessage, conflict: true);
      }
      return QuickActionResult(false, r.errorMessage);
    } finally {
      busyIds.remove(b.id);
      update();
    }
  }
}
