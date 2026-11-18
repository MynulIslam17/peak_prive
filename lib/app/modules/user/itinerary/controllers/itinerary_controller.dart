import 'dart:async';

import 'package:get/get.dart';

import '../../../../data/api/peak_api.dart';
import '../../../../data/services/socket/live_events.dart';
import '../../../booking/booking_text.dart';

/// One day of the itinerary.
class ItineraryDay {
  const ItineraryDay(this.day, this.bookings);

  /// Null = date unknown.
  final DateTime? day;
  final List<Booking> bookings;
}

/// Itinerary: what's running now and what's coming, every service, by day.
/// Active bookings (one request) + upcoming ones (paged).
class ItineraryController extends GetxController {
  ItineraryController({PeakApi? api, this.pageSize = 20}) : _api = api;

  PeakApi? _api;
  PeakApi get api => _api ??= Get.find<PeakApi>();
  final int pageSize;

  final List<Booking> _active = [];
  final List<Booking> _upcoming = [];
  int _page = 0;
  bool hasMore = true;
  bool isLoading = false;
  bool isLoadingMore = false;
  String? errorMessage;
  int _seq = 0;
  StreamSubscription<BookingUpdate>? _liveSub;
  Timer? _liveDebounce;

  @override
  void onInit() {
    super.onInit();
    // Any change to the customer's bookings can add, move or remove a day
    // (a booking made on another device isn't listed yet), so reload quietly.
    // Bursts of events become one request.
    _liveSub = LiveEvents.bookingUpdates.listen((_) {
      _liveDebounce?.cancel();
      _liveDebounce = Timer(const Duration(milliseconds: 400), () => load(quiet: true));
    });
  }

  @override
  void onClose() {
    _liveSub?.cancel();
    _liveDebounce?.cancel();
    super.onClose();
  }

  /// Active first, then upcoming, sorted by start; no duplicates.
  List<Booking> get all {
    final seen = <String>{};
    final list = [..._active, ..._upcoming].where((b) => seen.add(b.id)).toList();
    list.sort((a, b) {
      final x = a.schedule.startAt ?? bookingDayOf(a);
      final y = b.schedule.startAt ?? bookingDayOf(b);
      if (x == null && y == null) return 0;
      if (x == null) return 1;
      if (y == null) return -1;
      return x.compareTo(y);
    });
    return list;
  }

  List<ItineraryDay> get days {
    final groups = <DateTime?, List<Booking>>{};
    for (final b in all) {
      groups.putIfAbsent(bookingDayOf(b), () => []).add(b);
    }
    return [for (final e in groups.entries) ItineraryDay(e.key, List.unmodifiable(e.value))];
  }

  Future<void> load({bool quiet = false}) async {
    final seq = ++_seq;
    if (!quiet) {
      isLoading = true;
      errorMessage = null;
      update();
    }
    final res = await Future.wait([
      api.bookings.mine(tab: BookingTab.active, limit: 50),
      api.bookings.mine(tab: BookingTab.upcoming, page: 1, limit: pageSize),
    ]);
    if (seq != _seq) return;
    isLoading = false;
    final active = res[0], upcoming = res[1];
    if (active.isSuccess || upcoming.isSuccess) {
      if (active.isSuccess) {
        _active
          ..clear()
          ..addAll(active.data!.items);
      }
      if (upcoming.isSuccess) {
        _upcoming
          ..clear()
          ..addAll(upcoming.data!.items);
        _page = 1;
        hasMore = upcoming.data!.hasMore;
      }
      errorMessage = null;
    } else if (!quiet || all.isEmpty) {
      errorMessage = upcoming.errorMessage;
    }
    update();
  }

  Future<void> loadMore() async {
    if (isLoading || isLoadingMore || !hasMore || _page == 0) return;
    final seq = _seq;
    isLoadingMore = true;
    update();
    final r = await api.bookings.mine(tab: BookingTab.upcoming, page: _page + 1, limit: pageSize);
    if (seq != _seq) return;
    isLoadingMore = false;
    if (r.isSuccess) {
      _upcoming.addAll(r.data!.items);
      _page++;
      hasMore = r.data!.hasMore;
    } else {
      hasMore = false;
    }
    update();
  }
}
