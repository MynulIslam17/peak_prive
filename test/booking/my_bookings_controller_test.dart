import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/data/api/peak_api.dart';
import 'package:harry_service_app/app/data/services/socket/live_events.dart';
import 'package:harry_service_app/app/modules/booking/controllers/my_bookings_controller.dart';
import 'package:harry_service_app/app/modules/user/itinerary/controllers/itinerary_controller.dart';
import 'package:logger/logger.dart';

import '../api/harness.dart';

Map<String, dynamic> page(List<Map<String, dynamic>> items, {int page = 1, int totalPages = 1}) => {
      'success': true,
      'data': items,
      'meta': {'page': page, 'limit': 10, 'total': items.length, 'totalPages': totalPages},
    };

Map<String, dynamic> booking(String id, {String category = 'Ski_Hire', String status = 'Confirmed', List<String> actions = const [], String? start, String? date}) => {
      'id': id,
      'category': category,
      'status': status,
      'actions': actions,
      'listing': {'id': 'l-$id', 'title': 'Listing $id'},
      'schedule': {'startAt': start, 'date': date},
      'price': {'total': 10},
    };

void main() {
  setUpAll(() => Logger.level = Level.off);
  tearDown(Get.reset);

  group('MyBookingsController', () {
    test('loads a tab with the service filter', () async {
      final h = Harness((_) => json(page([booking('a'), booking('b')], totalPages: 2)));
      registerHarness(h);
      final c = Get.put(MyBookingsController(liveDebounce: Duration.zero));
      c.setKind(ServiceKind.skiHire);
      await c.load(BookingTab.upcoming);
      expect(h.last.url.queryParameters, {'tab': 'upcoming', 'category': 'Ski_Hire', 'page': '1', 'limit': '10'});
      final s = c.stateOf(BookingTab.upcoming);
      expect(s.items.map((b) => b.id), ['a', 'b']);
      expect(s.hasMore, isTrue);
      expect(s.fetched, isTrue);
      expect(c.stateOf(BookingTab.past).fetched, isFalse);
    });

    test('load more skips duplicates and stops at the last page', () async {
      final h = Harness((req) => req.url.queryParameters['page'] == '1'
          ? json(page([booking('a'), booking('b')], totalPages: 2))
          : json(page([booking('b'), booking('c')], page: 2, totalPages: 2)));
      registerHarness(h);
      final c = Get.put(MyBookingsController());
      await c.load(BookingTab.past);
      await c.loadMore(BookingTab.past);
      final s = c.stateOf(BookingTab.past);
      expect(s.items.map((b) => b.id), ['a', 'b', 'c']);
      expect(s.hasMore, isFalse);
      final n = h.requests.length;
      await c.loadMore(BookingTab.past);
      expect(h.requests.length, n);
    });

    test('load more before the first load does nothing', () async {
      final h = Harness((_) => json(page([])));
      registerHarness(h);
      final c = Get.put(MyBookingsController());
      await c.loadMore(BookingTab.active);
      expect(h.requests, isEmpty);
    });

    test('errors show on an empty tab; ensureLoaded loads once', () async {
      var fail = true;
      final h = Harness((_) => fail ? json({'success': false, 'message': 'Down'}, 503) : json(page([booking('a')])));
      registerHarness(h);
      final c = Get.put(MyBookingsController());
      await c.ensureLoaded(BookingTab.cancelled);
      expect(c.stateOf(BookingTab.cancelled).error, 'Down');
      fail = false;
      await c.load(BookingTab.cancelled);
      expect(c.stateOf(BookingTab.cancelled).error, isNull);
      final n = h.requests.length;
      await c.ensureLoaded(BookingTab.cancelled);
      expect(h.requests.length, n);
    });

    test('changing the service clears tabs; same service keeps them', () async {
      final h = Harness((_) => json(page([booking('a')])));
      registerHarness(h);
      final c = Get.put(MyBookingsController());
      c.setKind(ServiceKind.massage);
      await c.load(BookingTab.upcoming);
      c.setKind(ServiceKind.massage);
      expect(c.stateOf(BookingTab.upcoming).items, hasLength(1));
      c.setKind(ServiceKind.transport);
      expect(c.stateOf(BookingTab.upcoming).items, isEmpty);
      expect(c.stateOf(BookingTab.upcoming).fetched, isFalse);
    });

    test('a slow old response does not overwrite a newer filter', () async {
      final h = Harness((req) async {
        if (req.url.queryParameters['category'] == 'Massage') {
          await Future<void>.delayed(const Duration(milliseconds: 30));
          return json(page([booking('old', category: 'Massage')]));
        }
        return json(page([booking('new', category: 'Transport')]));
      });
      registerHarness(h);
      final c = Get.put(MyBookingsController());
      c.setKind(ServiceKind.massage);
      final slow = c.load(BookingTab.upcoming);
      c.setKind(ServiceKind.transport);
      await c.load(BookingTab.upcoming);
      await slow;
      expect(c.stateOf(BookingTab.upcoming).items.map((b) => b.id), ['new']);
    });

    test('live events refresh only tabs already opened, once', () async {
      final h = Harness((_) => json(page([booking('a')])));
      registerHarness(h);
      final c = Get.put(MyBookingsController(liveDebounce: const Duration(milliseconds: 5)));
      await c.load(BookingTab.upcoming);
      final n = h.requests.length;
      LiveEvents.emitBookingUpdate(const BookingUpdate('x', 'Confirmed'));
      LiveEvents.emitBookingUpdate(const BookingUpdate('y', 'Confirmed'));
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(h.requests.length, n + 1);
      expect(h.last.url.queryParameters['tab'], 'upcoming');
    });

    test('review from the list; 409 hides the button too', () async {
      final h = Harness((req) => req.method == 'POST'
          ? json({'success': false, 'message': 'Already reviewed.'}, 409)
          : json(page([booking('a', status: 'Completed', actions: ['review'])])));
      registerHarness(h);
      final c = Get.put(MyBookingsController());
      await c.load(BookingTab.past);
      final b = c.stateOf(BookingTab.past).items.single;
      expect(c.canReview(b), isTrue);
      final r = await c.review(b, 5, 'Great');
      expect(r.ok, isFalse);
      expect(r.message, contains('already reviewed'));
      expect(c.canReview(b), isFalse);
      expect(h.last.url.path, '/api/v1/ski-hire/l-a/review');
    });
  });

  group('ItineraryController', () {
    test('merges active and upcoming, sorted and grouped by day', () async {
      final h = Harness((req) => req.url.queryParameters['tab'] == 'active'
          ? json(page([booking('run', start: '2026-11-16T08:00:00Z', date: '2026-11-16')]))
          : json(page([
              booking('late', start: '2026-11-20T09:00:00Z', date: '2026-11-20'),
              booking('soon', start: '2026-11-18T09:00:00Z', date: '2026-11-18'),
              booking('run', start: '2026-11-16T08:00:00Z', date: '2026-11-16'),
              booking('soon2', category: 'Massage', date: '2026-11-18'),
            ])));
      registerHarness(h);
      final c = Get.put(ItineraryController());
      await c.load();
      expect(c.all.map((b) => b.id), ['run', 'soon2', 'soon', 'late']);
      final days = c.days;
      expect(days.map((d) => d.day), [DateTime(2026, 11, 16), DateTime(2026, 11, 18), DateTime(2026, 11, 20)]);
      expect(days[1].bookings, hasLength(2));
    });

    test('one list failing still shows the other; both failing shows an error', () async {
      var both = false;
      final h = Harness((req) => req.url.queryParameters['tab'] == 'active' || both
          ? json({'success': false, 'message': 'Down'}, 503)
          : json(page([booking('a', date: '2026-11-20')])));
      registerHarness(h);
      final c = Get.put(ItineraryController());
      await c.load();
      expect(c.errorMessage, isNull);
      expect(c.all, hasLength(1));
      both = true;
      Get.delete<ItineraryController>();
      final c2 = Get.put(ItineraryController());
      await c2.load();
      expect(c2.errorMessage, 'Down');
    });

    test('a live update for a booking not listed yet reloads quietly', () async {
      var round = 0;
      final h = Harness((req) {
        if (req.url.queryParameters['tab'] == 'active') return json(page([]));
        return json(page([
          booking('a', date: '2026-11-20'),
          if (round > 0) booking('new', date: '2026-11-21'),
        ]));
      });
      registerHarness(h);
      final c = Get.put(ItineraryController());
      await c.load();
      expect(c.all.map((b) => b.id), ['a']);
      round = 1;
      LiveEvents.emitBookingUpdate(const BookingUpdate('new', 'Confirmed'));
      LiveEvents.emitBookingUpdate(const BookingUpdate('new', 'Confirmed'));
      await Future<void>.delayed(const Duration(milliseconds: 600));
      expect(c.all.map((b) => b.id), ['a', 'new']);
      expect(c.isLoading, isFalse);
      expect(h.requests.where((r) => r.url.queryParameters['tab'] == 'upcoming'), hasLength(2)); // one reload for the burst
    });

    test('load more pages upcoming only', () async {
      final h = Harness((req) {
        final q = req.url.queryParameters;
        if (q['tab'] == 'active') return json(page([]));
        return q['page'] == '1'
            ? json(page([booking('a', date: '2026-11-20')], totalPages: 2))
            : json(page([booking('b', date: '2026-11-21')], page: 2, totalPages: 2));
      });
      registerHarness(h);
      final c = Get.put(ItineraryController());
      await c.load();
      await c.loadMore();
      expect(c.all.map((b) => b.id), ['a', 'b']);
      expect(c.hasMore, isFalse);
    });
  });
}
