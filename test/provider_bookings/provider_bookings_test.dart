import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/data/api/peak_api.dart';
import 'package:harry_service_app/app/data/services/socket/live_events.dart';
import 'package:harry_service_app/app/modules/provider/shared/controllers/all_booking_controller.dart';
import 'package:harry_service_app/app/modules/provider/shared/controllers/provider_home_controller.dart';
import 'package:harry_service_app/app/modules/provider/shared/widgets/provider_ui.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../api/fixtures.dart';
import '../api/harness.dart';

Map<String, dynamic> _booking(String id, {String status = 'Pending', List<String> actions = const ['approve', 'reject']}) => {
      'id': id,
      'category': 'Ski_Hire',
      'status': status,
      'actions': actions,
      'listing': {'id': 'l', 'title': 'Shop'},
      'price': {'total': 25, 'currency': 'eur'},
      'customer': {'id': 'c', 'name': 'Ann'},
    };

http.Response _page(List<Map<String, dynamic>> items, {int page = 1, int totalPages = 1, int? total}) => json({
      'success': true,
      'data': items,
      'meta': {'page': page, 'limit': 20, 'total': total ?? items.length, 'totalPages': totalPages},
    });

void main() {
  setUpAll(() => Logger.level = Level.off);
  tearDown(() async {
    // Delete (not just reset) so onClose cancels the live-event listeners.
    await Get.delete<ProviderBookingsController>(force: true);
    await Get.delete<ProviderHomeController>(force: true);
    Get.reset();
  });

  ProviderBookingsController putList() =>
      Get.put(ProviderBookingsController(liveDebounce: const Duration(milliseconds: 10)));

  group('ProviderBookingsController', () {
    test('each filter maps to its server tab', () async {
      final h = Harness((_) => _page([]));
      registerHarness(h);
      final c = putList();
      await c.fetchBookings();
      expect(h.last.url.path, '/api/v1/booking/provider');
      expect(h.last.url.queryParameters.containsKey('tab'), isFalse); // All
      final expected = {
        ProviderBookingFilter.requests: 'requests',
        ProviderBookingFilter.upcoming: 'upcoming',
        ProviderBookingFilter.active: 'active',
        ProviderBookingFilter.past: 'past',
        ProviderBookingFilter.cancelled: 'cancelled',
      };
      for (final e in expected.entries) {
        await c.setFilter(e.key);
        expect(h.last.url.queryParameters['tab'], e.value);
        expect(h.last.url.queryParameters['page'], '1');
      }
    });

    test('real provider list parses; paging stops at the last page', () async {
      final h = Harness((req) {
        final p = req.url.queryParameters['page'];
        if (p == '1') return _page([_booking('a'), _booking('b')], page: 1, totalPages: 2, total: 3);
        return _page([_booking('b'), _booking('c')], page: 2, totalPages: 2, total: 3);
      });
      registerHarness(h);
      final c = putList();
      await c.fetchBookings();
      expect(c.bookings.map((b) => b.id), ['a', 'b']);
      expect(c.total, 3);
      expect(c.hasMore, isTrue);
      await c.loadMore();
      expect(c.bookings.map((b) => b.id), ['a', 'b', 'c']); // duplicate b skipped
      expect(c.hasMore, isFalse);
      await c.loadMore(); // no extra call
      expect(h.requests, hasLength(2));
    });

    test('fixture list', () async {
      final h = Harness((_) => fixtureResponse('p_bookings'));
      registerHarness(h);
      final c = putList();
      await c.setFilter(ProviderBookingFilter.requests);
      expect(c.bookings.single.customer!.name, 'Azaan');
      expect(c.hasMore, isFalse);
      expect(c.errorMessage, isNull);
    });

    test('empty list', () async {
      registerHarness(Harness((_) => _page([])));
      final c = putList();
      await c.fetchBookings();
      expect(c.bookings, isEmpty);
      expect(c.total, 0);
      expect(c.errorMessage, isNull);
      expect(c.isLoading, isFalse);
    });

    test('server error shows a message; a failed refresh keeps the list', () async {
      var fail = false;
      registerHarness(Harness((_) => fail ? http.Response('<html>502</html>', 502) : _page([_booking('a')])));
      final c = putList();
      await c.fetchBookings();
      expect(c.bookings, hasLength(1));
      fail = true;
      await c.refreshBookings();
      expect(c.bookings, hasLength(1));
      expect(c.errorMessage, isNotNull);
    });

    test('offline on first load', () async {
      registerHarness(Harness((_) => throw const SocketException('down')));
      final c = putList();
      await c.fetchBookings();
      expect(c.bookings, isEmpty);
      expect(c.errorMessage, contains('internet'));
    });

    test('a slow response for an old filter is ignored', () async {
      final h = Harness((req) async {
        if (req.url.queryParameters['tab'] == null) {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return _page([_booking('old')]);
        }
        return _page([_booking('new')]);
      });
      registerHarness(h);
      final c = putList();
      final first = c.fetchBookings();
      await c.setFilter(ProviderBookingFilter.requests);
      await first;
      expect(c.bookings.single.id, 'new');
    });

    test('switching back to a filter shows its cached list at once, then refreshes', () async {
      final gate = Completer<void>();
      var slow = false;
      final h = Harness((req) async {
        if (slow) await gate.future;
        return req.url.queryParameters['tab'] == 'requests' ? _page([_booking('r')]) : _page([_booking('a'), _booking('b')]);
      });
      registerHarness(h);
      final c = putList();
      await c.fetchBookings();
      await c.setFilter(ProviderBookingFilter.requests);
      slow = true;
      final back = c.setFilter(ProviderBookingFilter.all);
      // Cached list, no skeleton, while the refresh runs.
      expect(c.bookings.map((b) => b.id), ['a', 'b']);
      expect(c.isLoading, isFalse);
      gate.complete();
      await back;
      expect(h.requests, hasLength(3));
    });

    test('a never-loaded filter shows the skeleton', () async {
      final gate = Completer<void>();
      registerHarness(Harness((_) async {
        await gate.future;
        return _page([_booking('a')]);
      }));
      final c = putList();
      final f = c.fetchBookings();
      expect(c.isLoading, isTrue);
      gate.complete();
      await f;
      expect(c.isLoading, isFalse);
    });

    test('quick accept on Needs approval: card leaves at once, comes back if refused', () async {
      final gate = Completer<void>();
      var ok = false;
      registerHarness(Harness((req) async {
        if (req.method != 'PATCH') return _page([_booking('a'), _booking('b')]);
        await gate.future;
        return ok
            ? json({'success': true, 'data': _booking('a', status: 'Confirmed', actions: [])})
            : json({'success': false, 'message': 'Payment problem.'}, 400);
      }));
      final c = putList();
      await c.setFilter(ProviderBookingFilter.requests);
      final pending = c.quickAction(c.bookings.first, BookingAction.approve);
      expect(c.bookings.map((b) => b.id), ['b']); // optimistic
      expect(c.total, 1);
      gate.complete();
      final r = await pending;
      expect(r.ok, isFalse);
      expect(c.bookings.map((b) => b.id), ['a', 'b']); // restored
      expect(c.total, 2);
    });

    test('quick accept updates the card in place', () async {
      final h = Harness((req) => req.method == 'PATCH'
          ? json({'success': true, 'data': _booking('a', status: 'Confirmed', actions: ['reject', 'hand_over'])})
          : _page([_booking('a'), _booking('b')]));
      registerHarness(h);
      final c = putList();
      await c.fetchBookings();
      final r = await c.quickAction(c.bookings.first, BookingAction.approve);
      expect(r.ok, isTrue);
      expect(h.last.url.path, '/api/v1/booking/a/approve');
      expect(c.bookings.first.status, BookingStatus.confirmed);
      expect(c.busyIds, isEmpty);
    });

    test('accepting on the Requests filter removes it from the list', () async {
      registerHarness(Harness((req) => req.method == 'PATCH'
          ? json({'success': true, 'data': _booking('a', status: 'Confirmed', actions: [])})
          : _page([_booking('a'), _booking('b')])));
      final c = putList();
      await c.setFilter(ProviderBookingFilter.requests);
      await c.quickAction(c.bookings.first, BookingAction.approve);
      expect(c.bookings.map((b) => b.id), ['b']);
      expect(c.total, 1);
    });

    test('reject sends the reason', () async {
      final h = Harness((req) => req.method == 'PATCH'
          ? json({'success': true, 'data': _booking('a', status: 'Cancelled', actions: [])})
          : _page([_booking('a')]));
      registerHarness(h);
      final c = putList();
      await c.fetchBookings();
      final r = await c.quickAction(c.bookings.first, BookingAction.reject, reason: 'Sold out');
      expect(r.ok, isTrue);
      expect(h.lastBody, {'reason': 'Sold out'});
    });

    test('409 reloads the list and reports a conflict', () async {
      var listCalls = 0;
      final h = Harness((req) {
        if (req.method == 'PATCH') return json({'success': false, 'message': 'Booking already approved.'}, 409);
        listCalls++;
        return _page([_booking('a', status: listCalls > 1 ? 'Confirmed' : 'Pending')]);
      });
      registerHarness(h);
      final c = putList();
      await c.fetchBookings();
      final r = await c.quickAction(c.bookings.first, BookingAction.approve);
      expect(r.ok, isFalse);
      expect(r.conflict, isTrue);
      expect(r.message, 'Booking already approved.');
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(listCalls, 2);
      expect(c.bookings.first.status, BookingStatus.confirmed);
    });

    test('double tap sends one request; disallowed actions send none', () async {
      final h = Harness((req) async {
        if (req.method == 'PATCH') {
          await Future<void>.delayed(const Duration(milliseconds: 20));
          return json({'success': true, 'data': _booking('a', status: 'Confirmed', actions: [])});
        }
        return _page([_booking('a'), _booking('x', status: 'Confirmed', actions: ['hand_over'])]);
      });
      registerHarness(h);
      final c = putList();
      await c.fetchBookings();
      final b = c.bookings.first;
      final results = await Future.wait([c.quickAction(b, BookingAction.approve), c.quickAction(b, BookingAction.approve)]);
      expect(results.where((r) => r.ok), hasLength(1));
      expect(h.requests.where((r) => r.method == 'PATCH'), hasLength(1));
      final no = await c.quickAction(c.bookings.last, BookingAction.approve);
      expect(no.ok, isFalse);
      final notQuick = await c.quickAction(c.bookings.last, BookingAction.handOver);
      expect(notQuick.ok, isFalse);
      expect(h.requests.where((r) => r.method == 'PATCH'), hasLength(1));
    });

    test('a live booking update refreshes the list (debounced)', () async {
      final h = Harness((_) => _page([_booking('a')]));
      registerHarness(h);
      final c = putList();
      await c.fetchBookings();
      LiveEvents.emitBookingUpdate(const BookingUpdate('a', 'Confirmed'));
      LiveEvents.emitBookingUpdate(const BookingUpdate('a', 'Confirmed'));
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(h.requests, hasLength(2)); // one initial + one debounced refresh
    });
  });

  group('ProviderHomeController', () {
    ProviderHomeController putHome({ServiceKind? kind = ServiceKind.skiHire}) =>
        Get.put(ProviderHomeController(kind: kind, liveDebounce: const Duration(milliseconds: 10)));

    test('loads the dashboard and own listings', () async {
      final h = Harness((req) => req.url.path.endsWith('/dashboard/meta/provider')
          ? fixtureResponse('p_dashboard')
          : fixtureResponse('p_hire_my'));
      registerHarness(h);
      final c = putHome();
      expect(await c.fetchProviderHomeData(), isTrue);
      expect(c.dashboard!.bookings.requests, 1);
      expect(c.requestCount, 1);
      expect(c.services, hasLength(2));
      expect(h.requests.map((r) => r.url.path), containsAll(['/api/v1/dashboard/meta/provider', '/api/v1/ski-hire/my']));
    });

    test('dashboard with missing fields shows zeros', () async {
      registerHarness(Harness((req) => req.url.path.endsWith('/provider') ? json({'success': true, 'data': {}}) : _page([])));
      final c = putHome();
      await c.fetchProviderHomeData();
      expect(c.dashboard!.bookings.total, 0);
      expect(c.dashboard!.earnings.balance, 0);
      expect(c.dashboard!.today, isEmpty);
      expect(c.services, isEmpty);
    });

    test('error without data; a failed refresh keeps the old numbers', () async {
      var fail = true;
      registerHarness(Harness((req) => fail ? http.Response('down', 503) : fixtureResponse('p_dashboard')));
      final c = putHome(kind: null);
      expect(await c.fetchProviderHomeData(), isFalse);
      expect(c.dashboard, isNull);
      expect(c.errorMessage, isNotNull);
      fail = false;
      await c.refreshData();
      expect(c.dashboard, isNotNull);
      fail = true;
      await c.refreshData();
      expect(c.dashboard, isNotNull);
    });

    test('listings failing does not hide the dashboard', () async {
      registerHarness(Harness((req) => req.url.path.endsWith('/provider') ? fixtureResponse('p_dashboard') : http.Response('x', 500)));
      final c = putHome();
      expect(await c.fetchProviderHomeData(), isTrue);
      expect(c.services, isEmpty);
    });

    test('delete: 409 keeps the listing, success removes it', () async {
      var conflict = true;
      registerHarness(Harness((req) {
        if (req.method == 'DELETE') {
          return conflict
              ? json({'success': false, 'message': 'This listing has open bookings.'}, 409)
              : json({'success': true, 'data': {'id': 'x', 'deleted': true}});
        }
        return req.url.path.endsWith('/provider') ? fixtureResponse('p_dashboard') : fixtureResponse('p_hire_my');
      }));
      final c = putHome();
      await c.fetchProviderHomeData();
      final card = c.services.first;
      final r = await c.deleteListing(card);
      expect(r.failure!.isConflict, isTrue);
      expect(c.services, hasLength(2));
      conflict = false;
      expect((await c.deleteListing(card)).isSuccess, isTrue);
      expect(c.services.any((s) => s.id == card.id), isFalse);
    });

    test('live booking update refreshes the dashboard', () async {
      final h = Harness((req) => fixtureResponse('p_dashboard'));
      registerHarness(h);
      final c = putHome(kind: null);
      await c.fetchProviderHomeData();
      LiveEvents.emitBookingUpdate(const BookingUpdate('b', null));
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(h.requests, hasLength(2));
    });
  });

  group('card text', () {
    Booking b(Map<String, dynamic> j) => Booking.fromJson({'id': 'x', ...j}, receivedAt: DateTime(2026, 11, 16, 9));

    test('status chip', () {
      expect(ProviderStatusStyle.of(b({'status': 'Pending'})).label, 'Needs approval');
      expect(ProviderStatusStyle.of(b({'status': 'InProgress', 'category': 'Transport'})).label, 'Handed over');
      expect(ProviderStatusStyle.of(b({'status': 'InProgress', 'category': 'Massage'})).label, 'In progress');
      expect(ProviderStatusStyle.of(b({'status': 'InProgress', 'category': 'Ski_Hire', 'timer': {'state': 'overdue', 'minutes': 5}})).label, 'Overdue');
      expect(ProviderStatusStyle.of(b({'status': 'Completed', 'noShow': true})).label, 'No-show');
      expect(ProviderStatusStyle.of(b({'status': '???'})).label, 'Unknown');
    });

    test('massage card shows the resort day with the resort time', () {
      final m = Booking.fromJson({
        'id': 'm1',
        'category': 'Massage',
        'status': 'Pending',
        'schedule': {
          'date': '2026-11-17',
          'startAt': '2026-11-17T23:15:00.000Z', // the next day in most zones east of UTC
          'time': '9:15 PM',
          'duration': '60 min',
        },
      });
      expect(ProviderBookingText.schedule(m), '17 Nov · 9:15 PM');
    });

    test('schedule and detail per service', () {
      final list = (fixture('u_all')['data'] as List).cast<Map<String, dynamic>>().map(Booking.fromJson);
      for (final k in ServiceKind.values) {
        final x = list.where((e) => e.kind == k);
        if (x.isEmpty) continue;
        expect(ProviderBookingText.schedule(x.first), isNotEmpty, reason: k.name);
      }
      final pass = list.firstWhere((e) => e.kind == ServiceKind.skiPass);
      expect(ProviderBookingText.detail(pass), '3 guests');
      final rest = list.firstWhere((e) => e.kind == ServiceKind.restaurant);
      expect(ProviderBookingText.detail(rest), '2 seats · Normal');
      final hire = list.firstWhere((e) => e.kind == ServiceKind.skiHire);
      expect(ProviderBookingText.detail(hire), '1 × aaa');
      expect(ProviderBookingText.customerName(hire), 'Guest'); // customer list has no customer
    });

    test('notice lines', () {
      expect(ProviderBookingText.notice(b({'status': 'Pending', 'approvalDeadline': '2026-11-17T06:06:53Z'})), startsWith('Respond by'));
      expect(
        ProviderBookingText.notice(b({'status': 'InProgress', 'timer': {'state': 'overdue', 'minutes': 75, 'lateFee': 44}}),
            now: DateTime(2026, 11, 16, 9)),
        'Late by 1 h 15 min · €44 so far',
      );
      expect(ProviderBookingText.notice(b({'status': 'Confirmed', 'timer': {'state': 'starts_in', 'minutes': 5}})), isNull);
      expect(ProviderBookingText.notice(b({'status': 'Completed', 'timer': {'state': 'overdue', 'minutes': 5}})), isNull);
      expect(ProviderBookingText.duration(3000), '2 d 2 h');
      expect(ProviderBookingText.duration(120), '2 h');
    });
  });
}
