import 'dart:async';

import 'package:get/get.dart';

import '../../../data/api/peak_api.dart';
import '../../../data/services/socket/live_events.dart';

/// Paging state of one tab.
class BookingTabState {
  final List<Booking> items = [];
  int page = 0;
  bool hasMore = true;
  bool isLoading = false;
  bool isLoadingMore = false;
  bool fetched = false;
  String? error;
}

/// Customer "My bookings": `/booking/my` per tab, filtered by the service the
/// user is browsing (or all).
class MyBookingsController extends GetxController {
  MyBookingsController({PeakApi? api, this.pageSize = 10, this.liveDebounce = const Duration(seconds: 1)}) : _api = api;

  static const tabs = [BookingTab.upcoming, BookingTab.active, BookingTab.past, BookingTab.cancelled];

  PeakApi? _api;
  PeakApi get api => _api ??= Get.find<PeakApi>();
  final int pageSize;
  final Duration liveDebounce;

  final Map<BookingTab, BookingTabState> _state = {for (final t in tabs) t: BookingTabState()};
  final Map<BookingTab, int> _seq = {for (final t in tabs) t: 0};

  ServiceKind? _kind;
  ServiceKind? get kind => _kind;

  /// Bookings that got a review in this session (hides "Rate & review").
  final Set<String> reviewed = {};

  StreamSubscription<BookingUpdate>? _liveSub;
  Timer? _liveTimer;

  BookingTabState stateOf(BookingTab tab) => _state[tab]!;

  @override
  void onInit() {
    super.onInit();
    _liveSub = LiveEvents.bookingUpdates.listen((_) {
      // Several events can arrive at once; refresh once.
      _liveTimer?.cancel();
      _liveTimer = Timer(liveDebounce, refreshFetched);
    });
  }

  @override
  void onClose() {
    _liveSub?.cancel();
    _liveTimer?.cancel();
    super.onClose();
  }

  /// Changes the service filter; clears every tab when it changes.
  void setKind(ServiceKind? kind) {
    if (kind == _kind) return;
    _kind = kind;
    for (final t in tabs) {
      _state[t] = BookingTabState();
      _seq[t] = _seq[t]! + 1;
    }
    update();
  }

  /// Loads page 1 (pull to refresh, first open, retry).
  Future<void> load(BookingTab tab, {bool quiet = false}) async {
    final s = _state[tab]!;
    final seq = _seq[tab] = _seq[tab]! + 1;
    if (!quiet) {
      s.isLoading = true;
      s.error = null;
      update();
    }
    final r = await api.bookings.mine(tab: tab, kind: _kind, page: 1, limit: pageSize);
    if (seq != _seq[tab]) return;
    s.isLoading = false;
    s.fetched = true;
    if (r.isSuccess) {
      s.items
        ..clear()
        ..addAll(r.data!.items);
      s.page = 1;
      s.hasMore = r.data!.hasMore;
      s.error = null;
    } else if (!quiet || s.items.isEmpty) {
      s.error = r.errorMessage;
    }
    update();
  }

  /// Loads the first page only if the tab was never fetched.
  Future<void> ensureLoaded(BookingTab tab) async {
    final s = _state[tab]!;
    if (!s.fetched && !s.isLoading) await load(tab);
  }

  Future<void> loadMore(BookingTab tab) async {
    final s = _state[tab]!;
    if (s.isLoading || s.isLoadingMore || !s.hasMore || !s.fetched) return;
    final seq = _seq[tab]!;
    s.isLoadingMore = true;
    update();
    final r = await api.bookings.mine(tab: tab, kind: _kind, page: s.page + 1, limit: pageSize);
    if (seq != _seq[tab]) return;
    s.isLoadingMore = false;
    if (r.isSuccess) {
      // A booking can move between pages while scrolling; skip duplicates.
      final ids = s.items.map((b) => b.id).toSet();
      s.items.addAll(r.data!.items.where((b) => ids.add(b.id)));
      s.page += 1;
      s.hasMore = r.data!.hasMore;
    } else {
      s.hasMore = false; // stop retrying on scroll; pull to refresh resets
    }
    update();
  }

  /// Quietly reloads the tabs already opened (after a live event).
  Future<void> refreshFetched() async {
    await Future.wait([
      for (final t in tabs)
        if (_state[t]!.fetched) load(t, quiet: true),
    ]);
  }

  bool canReview(Booking b) => b.can(BookingAction.review) && !reviewed.contains(b.id);

  /// Rate & review from the list. 409 = already reviewed.
  Future<({bool ok, String message})> review(Booking b, int rating, String comment) async {
    if (b.listing.id.isEmpty) return (ok: false, message: 'This service is no longer available to review.');
    final r = await api.listings.addReview(b.kind, b.listing.id, rating: rating, comment: comment);
    if (r.isSuccess) {
      reviewed.add(b.id);
      update();
      return (ok: true, message: 'Thanks for your review!');
    }
    if (r.failure!.isConflict) {
      reviewed.add(b.id);
      update();
      return (ok: false, message: "You've already reviewed this service.");
    }
    return (ok: false, message: r.errorMessage);
  }
}
