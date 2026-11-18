import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/data/api/peak_api.dart';
import 'package:harry_service_app/app/data/services/socket/live_events.dart';
import 'package:harry_service_app/app/modules/notification/controller/notification_controller.dart';
import 'package:harry_service_app/app/routes/app_routes.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../api/harness.dart';

Map<String, dynamic> n(String id, {bool read = false, String? bookingId}) => {
      'id': id,
      'title': 'Title $id',
      'description': 'Body',
      'isRead': read,
      'bookingId': bookingId,
      'event': bookingId == null ? null : 'booking.approved',
      'createdAt': '2026-11-16T06:00:00Z',
    };

/// Two pages of notifications; [failWrites] makes read endpoints fail.
Harness server({bool failWrites = false, int unread = 3}) => Harness((req) {
      final p = req.url.path;
      if (req.method == 'PATCH') {
        return failWrites
            ? json({'success': false, 'message': 'Nope'}, 500)
            : json({'success': true, 'message': 'ok'});
      }
      if (p.endsWith('/unread-count')) {
        return json({'success': true, 'data': {'unread': unread}});
      }
      final page = int.parse(req.url.queryParameters['page'] ?? '1');
      return json({
        'success': true,
        'data': page == 1
            ? [n('a', bookingId: 'b1'), n('b'), n('c', read: true)]
            : [n('c', read: true), n('d')],
        'meta': {'page': page, 'limit': 20, 'total': 5, 'totalPages': 2, 'unread': unread},
      });
    });

void main() {
  setUpAll(() => Logger.level = Level.off);
  tearDown(Get.reset);

  NotificationController make({String? session = 'tok', List<List<Object>>? nav, bool loggedIn = true}) {
    return NotificationController(
      isLoggedIn: () => loggedIn,
      sessionKey: () => session,
      navigate: (route, args) => nav?.add([route, args]),
    );
  }

  test('fetch first page, unread from meta, paging dedupes', () async {
    final h = server();
    registerHarness(h);
    final c = make();
    await c.fetch();
    expect(c.items.map((e) => e.id), ['a', 'b', 'c']);
    expect(c.unread, 3);
    expect(c.hasMore, isTrue);
    expect(h.last.url.queryParameters['page'], '1');
    await c.loadMore();
    expect(c.items.map((e) => e.id), ['a', 'b', 'c', 'd']);
    expect(c.hasMore, isFalse);
    await c.loadMore();
    expect(h.requests, hasLength(2));
  });

  test('nothing is requested while logged out', () async {
    final h = server();
    registerHarness(h);
    final c = make(loggedIn: false);
    await c.fetch();
    await c.refreshUnread();
    expect(h.requests, isEmpty);
  });

  test('unread count for the bell', () async {
    registerHarness(server(unread: 7));
    final c = make();
    await c.refreshUnread();
    expect(c.unread, 7);
  });

  test('mark read is optimistic and calls the endpoint', () async {
    final h = server();
    registerHarness(h);
    final c = make();
    await c.fetch();
    final future = c.markRead(c.items.first);
    expect(c.items.first.isRead, isTrue, reason: 'updated before the server answers');
    expect(c.unread, 2);
    expect(await future, isTrue);
    expect(h.last.url.path, '/api/v1/notifications/a/read');
    // Already read: no call.
    final calls = h.requests.length;
    expect(await c.markRead(c.items.first), isTrue);
    expect(h.requests.length, calls);
  });

  test('mark read rolls back on failure', () async {
    registerHarness(server(failWrites: true));
    final c = make();
    await c.fetch();
    expect(await c.markRead(c.items.first), isFalse);
    expect(c.items.first.isRead, isFalse);
    expect(c.unread, 3);
  });

  test('mark all read, and rollback on failure', () async {
    final h = server();
    registerHarness(h);
    final c = make();
    await c.fetch();
    expect(await c.markAllRead(), isTrue);
    expect(c.items.every((e) => e.isRead), isTrue);
    expect(c.unread, 0);
    expect(h.last.url.path, '/api/v1/notifications/read-all');

    Get.reset();
    registerHarness(server(failWrites: true));
    final d = make();
    await d.fetch();
    expect(await d.markAllRead(), isFalse);
    expect(d.items.where((e) => !e.isRead).map((e) => e.id), ['a', 'b']);
    expect(d.unread, 3);
  });

  test('tap: booking notifications open the booking, others only mark read', () async {
    registerHarness(server());
    final nav = <List<Object>>[];
    final c = make(nav: nav);
    await c.fetch();
    c.open(c.items[0]);
    c.open(c.items[1]);
    expect(nav, [
      [Routes.bookingDetails, {'bookingId': 'b1'}]
    ]);
    expect(NotificationController.routeFor(c.items[1]), isNull);
    await Future<void>.delayed(Duration.zero);
    expect(c.items[0].isRead && c.items[1].isRead, isTrue);
  });

  test('booking.completed: canReview from data, review opens the booking with the review', () async {
    final yes = AppNotification.fromJson({
      ...n('r', bookingId: 'b9'),
      'event': 'booking.completed',
      'data': {'canReview': true},
    });
    final no = AppNotification.fromJson({
      ...n('s', bookingId: 'b9'),
      'event': 'booking.completed',
      'data': {'canReview': false},
    });
    expect(yes.canReview, isTrue);
    expect(no.canReview, isFalse);
    expect(AppNotification.fromJson(n('t')).canReview, isFalse); // no data
    expect(yes.copyWith(isRead: true).canReview, isTrue);

    registerHarness(server());
    final nav = <List<Object>>[];
    make(nav: nav).review(yes);
    expect(nav, [
      [Routes.bookingDetails, {'bookingId': 'b9', 'openReview': true}]
    ]);
  });

  test('live notification is prepended once and bumps the badge', () async {
    registerHarness(server());
    final c = make();
    c.onInit();
    await c.fetch();
    LiveEvents.emitNotification(AppNotification.fromJson(n('z')));
    await Future<void>.delayed(Duration.zero);
    expect(c.items.first.id, 'z');
    expect(c.unread, 4);
    c.onLiveNotification(AppNotification.fromJson(n('z')));
    expect(c.items.where((e) => e.id == 'z'), hasLength(1));
    expect(c.unread, 4);
    c.onClose();
  });

  test('a different user never sees the previous list', () async {
    registerHarness(server());
    var session = 'tok-1';
    final c = NotificationController(isLoggedIn: () => true, sessionKey: () => session, navigate: (_, __) {});
    await c.fetch();
    expect(c.items, isNotEmpty);
    session = 'tok-2';
    Get.reset();
    registerHarness(Harness((_) => json({'success': false, 'message': 'down'}, 503)));
    await c.fetch();
    expect(c.items, isEmpty);
    expect(c.unread, 0);
    expect(c.errorMessage, isNotNull);
  });

  test('fetch error keeps a message', () async {
    registerHarness(Harness((_) => http.Response('<html>502</html>', 502)));
    final c = make();
    await c.fetch();
    expect(c.errorMessage, isNotEmpty);
    expect(c.isLoading, isFalse);
  });

  test('stale page-1 response is ignored when a newer fetch started', () async {
    final gate = Completer<void>();
    var calls = 0;
    registerHarness(Harness((req) async {
      calls++;
      if (calls == 1) await gate.future;
      return json({
        'success': true,
        'data': [n(calls == 1 ? 'old' : 'new')],
        'meta': {'page': 1, 'totalPages': 1, 'unread': 1},
      });
    }));
    final c = make();
    final first = c.fetch();
    await Future<void>.delayed(Duration.zero);
    await c.fetch();
    gate.complete();
    await first;
    expect(c.items.single.id, 'new');
  });
}
