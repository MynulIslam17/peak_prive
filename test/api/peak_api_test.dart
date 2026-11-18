import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:harry_service_app/app/data/api/peak_api.dart';
import 'package:harry_service_app/app/data/services/network/network_caller.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:logger/logger.dart';

import 'fixtures.dart';
import 'harness.dart';

void main() {
  setUpAll(() => Logger.level = Level.off);

  group('listings', () {
    test('browse builds the query and parses cards + meta', () async {
      final h = Harness((_) => fixtureResponse('p_hire_my'));
      final r = await h.api.listings.browse(ServiceKind.skiHire, search: ' ski ', subCategory: 'Skis', page: 2, limit: 99);
      expect(r.isSuccess, isTrue);
      final uri = h.last.url;
      expect(uri.path, '/api/v1/ski-hire');
      expect(uri.queryParameters, {'search': 'ski', 'category': 'Skis', 'page': '2', 'limit': '50'});
      expect(h.last.headers['Authorization'], 'Bearer tok');
      expect(r.data!.items, hasLength(2));
      expect(r.data!.meta.total, 11);
      expect(r.data!.hasMore, isTrue);
    });

    test('ski pass browse ignores sub-category but sends passType', () async {
      final h = Harness((_) => json({'success': true, 'data': [], 'meta': {'page': 1, 'limit': 10, 'total': 0, 'totalPages': 0}}));
      final r = await h.api.listings.browse(ServiceKind.skiPass, subCategory: 'x', passType: PassType.vip);
      expect(h.last.url.queryParameters.containsKey('category'), isFalse);
      expect(h.last.url.queryParameters['passType'], 'Vip');
      expect(r.data!.items, isEmpty);
      expect(r.data!.hasMore, isFalse);
    });

    test('reads the old {result, pagination} list shape too', () async {
      final h = Harness((_) => json({
            'success': true,
            'data': {
              'result': [
                {'id': 'a', 'category': 'Massage', 'title': 'Old'}
              ],
              'pagination': {'page': 1, 'limit': 10, 'total': 1, 'totalPages': 1}
            }
          }));
      final r = await h.api.listings.browse(ServiceKind.massage);
      expect(r.data!.items.single.title, 'Old');
    });

    test('detail returns the right subclass; empty id fails without a call', () async {
      final h = Harness((_) => fixtureResponse('transport_detail'));
      final r = await h.api.listings.detail(ServiceKind.transport, '69366868c979bb40137064d9');
      expect(r.data, isA<TransportDetail>());
      expect(h.last.url.path, '/api/v1/transport/69366868c979bb40137064d9');

      final none = await h.api.listings.detail(ServiceKind.transport, '');
      expect(none.failure!.isNotFound, isTrue);
      expect(h.requests, hasLength(1));
    });

    test('reviews: list shape and massage wrapped shape', () async {
      final h1 = Harness((_) => fixtureResponse('hire_reviews'));
      final r1 = await h1.api.listings.reviews(ServiceKind.skiHire, 'x');
      expect(r1.data!.reviews.single.rating, 2);
      expect(r1.data!.rating.count, 1);
      expect(r1.data!.reviews.single.id, isNull);

      final h2 = Harness((_) => fixtureResponse('massage_reviews'));
      final r2 = await h2.api.listings.reviews(ServiceKind.massage, 'x');
      expect(r2.data!.reviews, isEmpty);
      expect(r2.data!.rating.average, 0);
    });

    test('add review validates locally and maps 409', () async {
      final h = Harness((_) => json({'success': false, 'message': 'You already reviewed this.'}, 409));
      final bad = await h.api.listings.addReview(ServiceKind.skiHire, 'x', rating: 0, comment: 'ok');
      expect(bad.isSuccess, isFalse);
      expect(h.requests, isEmpty);
      final blank = await h.api.listings.addReview(ServiceKind.skiHire, 'x', rating: 5, comment: '  ');
      expect(blank.errorMessage, 'Write a short comment.');
      final dup = await h.api.listings.addReview(ServiceKind.skiHire, 'x', rating: 5, comment: 'Great');
      expect(dup.failure!.isConflict, isTrue);
      expect(dup.errorMessage, 'You already reviewed this.');
      expect(h.last.url.path, '/api/v1/ski-hire/x/review');
    });

    test('categories; ski pass has none and makes no call', () async {
      final h = Harness((_) => fixtureResponse('cat_ski-hire'));
      final r = await h.api.listings.categories(ServiceKind.skiHire);
      expect(r.data, isNotEmpty);
      expect(h.last.url.path, '/api/v1/common/category/ski-hire');
      final pass = await h.api.listings.categories(ServiceKind.skiPass);
      expect(pass.data, isEmpty);
      expect(h.requests, hasLength(1));
    });

    test('allMine walks every page', () async {
      final h = Harness((req) {
        final p = int.parse(req.url.queryParameters['page']!);
        return json({
          'success': true,
          'data': [
            {'id': 'l$p', 'category': 'Ski_Hire'}
          ],
          'meta': {'page': p, 'limit': 50, 'total': 3, 'totalPages': 3}
        });
      });
      final r = await h.api.listings.allMine(ServiceKind.skiHire);
      expect(r.data!.map((l) => l.id), ['l1', 'l2', 'l3']);
      expect(h.requests.map((r) => r.url.path).toSet(), {'/api/v1/ski-hire/my'});
    });

    test('allMine keeps earlier pages when a later page fails', () async {
      final h = Harness((req) => req.url.queryParameters['page'] == '1'
          ? json({'success': true, 'data': [{'id': 'a'}], 'meta': {'page': 1, 'totalPages': 2}})
          : http.Response('<html>502</html>', 502));
      final r = await h.api.listings.allMine(ServiceKind.massage);
      expect(r.isSuccess, isTrue);
      expect(r.data!.single.id, 'a');
    });

    test('status and delete (409 when bookings are open)', () async {
      final h = Harness((req) => req.method == 'DELETE'
          ? json({'success': false, 'message': 'This listing has open bookings.'}, 409)
          : json({'success': true, 'data': {'id': 'x', 'isActive': false}}));
      final s = await h.api.listings.setActive(ServiceKind.massage, 'x', false);
      expect(s.data, isFalse);
      expect(h.lastBody, {'isActive': false});
      expect(h.last.url.path, '/api/v1/massage/x/status');
      final d = await h.api.listings.delete(ServiceKind.massage, 'x');
      expect(d.failure!.isConflict, isTrue);
      expect(d.errorMessage, 'This listing has open bookings.');
    });

    test('create sends multipart to /<service>, update PATCHes /<service>/:id', () async {
      final seen = <http.BaseRequest>[];
      final client = MockClient.streaming((req, body) async {
        seen.add(req);
        await body.drain<void>();
        return http.StreamedResponse(Stream.value(utf8.encode(fixtureText('hire_detail'))), 201);
      });
      final api = PeakApi(NetworkCaller(onUnAuthorize: () {}, accessToken: () => 't', client: client), baseUrl: base);
      final form = ListingForm.skiHire(title: 'X', items: const [HireItemInput(name: 'Skis', price: 1, quantity: 1)]);
      final c = await api.listings.create(form);
      expect(c.data, isA<SkiHireDetail>());
      expect(seen.last.method, 'POST');
      expect(seen.last.url.path, '/api/v1/ski-hire');
      expect((seen.last as http.MultipartRequest).fields['title'], 'X');
      await api.listings.update('abc', ListingForm.skiHire(extraChargePerHour: 5));
      expect(seen.last.method, 'PATCH');
      expect(seen.last.url.path, '/api/v1/ski-hire/abc');
      expect((seen.last as http.MultipartRequest).fields, {'extraChargePerHour': '5'});
    });
  });

  group('bookings', () {
    test('intent posts the request; 409 sold out comes back readable', () async {
      final h = Harness((_) => json({'success': false, 'message': 'Only 1 left.'}, 409));
      final req = BookingRequest.skiPass(productId: 'p', day: DateTime(2026, 12, 20));
      final r = await h.api.bookings.intent(req);
      expect(h.last.url.path, '/api/v1/booking/intent');
      expect(h.lastBody, {'productId': 'p', 'date': '2026-12-20', 'personCount': 1});
      expect(r.failure!.isConflict, isTrue);
      expect(r.errorMessage, 'Only 1 left.');
    });

    test('intent success', () async {
      final h = Harness((_) => fixtureResponse('intent_hire'));
      final r = await h.api.bookings.intent(BookingRequest.skiPass(productId: 'p', day: DateTime(2026, 12, 20)));
      expect(r.data!.isComplete, isTrue);
      expect(r.data!.amount, 100);
      expect(r.data!.breakdown!.units, 2);
    });

    test('create sends paymentIntentId with the same fields', () async {
      final h = Harness((_) => fixtureResponse('u_booking_detail', 201));
      final req = BookingRequest.skiPass(productId: 'p', day: DateTime(2026, 12, 20), persons: 2);
      final r = await h.api.bookings.create('pi_1', req);
      expect(h.lastBody['paymentIntentId'], 'pi_1');
      expect(h.lastBody['personCount'], 2);
      expect(r.data!.id, '6afa86679a13dd70cc0c8cb8');
    });

    test('400 field errors are exposed', () async {
      final h = Harness((_) => json({
            'success': false,
            'message': 'startDateAndTime must include a timezone.',
            'errors': [
              {'field': 'startDateAndTime', 'message': 'needs a zone'}
            ]
          }, 400));
      final r = await h.api.bookings.intent(BookingRequest.skiPass(productId: 'p', day: DateTime(2026, 12, 20)));
      expect(r.errorMessage, 'startDateAndTime must include a timezone.');
      expect(r.failure!.fieldMessage('startDateAndTime'), 'needs a zone');
      expect(r.failure!.fieldMessage('other'), isNull);
    });

    test('402 unpaid late fee', () async {
      final h = Harness((_) => json({'success': false, 'message': 'Please pay your outstanding late fee first.'}, 402));
      final r = await h.api.bookings.intent(BookingRequest.skiPass(productId: 'p', day: DateTime(2026, 12, 20)));
      expect(r.failure!.isPaymentRequired, isTrue);
      expect(r.errorMessage, contains('late fee'));
    });

    test('my bookings: tab, category, date; requests tab is provider-only', () async {
      final h = Harness((_) => fixtureResponse('u_all'));
      final r = await h.api.bookings.mine(tab: BookingTab.upcoming, kind: ServiceKind.skiHire, date: DateTime(2026, 11, 28));
      expect(h.last.url.path, '/api/v1/booking/my');
      expect(h.last.url.queryParameters, {'tab': 'upcoming', 'category': 'Ski_Hire', 'date': '2026-11-28', 'page': '1', 'limit': '10'});
      expect(r.data!.items, isNotEmpty);
      expect(r.data!.items.first.timer, isNull);

      await h.api.bookings.mine(tab: BookingTab.requests);
      expect(h.last.url.queryParameters.containsKey('tab'), isFalse);
    });

    test('provider bookings', () async {
      final h = Harness((_) => fixtureResponse('p_bookings'));
      final r = await h.api.bookings.forProvider(tab: BookingTab.requests);
      expect(h.last.url.path, '/api/v1/booking/provider');
      expect(h.last.url.queryParameters['tab'], 'requests');
      expect(r.data!.items.single.can(BookingAction.approve), isTrue);
      expect(r.data!.items.single.customer!.name, 'Azaan');
    });

    test('detail stamps the timer with the clock', () async {
      final h = Harness((_) => fixtureResponse('u_booking_detail'));
      final r = await h.api.bookings.detail('6afa86679a13dd70cc0c8cb8');
      expect(r.data!.timer!.receivedAt, DateTime(2026, 11, 16, 9));
    });

    test('actions hit /booking/:id/<action>; reason only for reject/cancel', () async {
      final h = Harness((_) => fixtureResponse('p_booking_detail'));
      await h.api.bookings.act('b1', BookingAction.handOver, reason: 'ignored');
      expect(h.last.method, 'PATCH');
      expect(h.last.url.path, '/api/v1/booking/b1/hand-over');
      expect(h.lastBody, isEmpty);

      await h.api.bookings.act('b1', BookingAction.reject, reason: '  Fully booked ');
      expect(h.last.url.path, '/api/v1/booking/b1/reject');
      expect(h.lastBody, {'reason': 'Fully booked'});

      await h.api.bookings.act('b1', BookingAction.cancel, reason: '   ');
      expect(h.lastBody, isEmpty);

      await h.api.bookings.act('b1', BookingAction.markReturned);
      expect(h.last.url.path, '/api/v1/booking/b1/return');

      final bad = await h.api.bookings.act('b1', BookingAction.review);
      expect(bad.isSuccess, isFalse);
      expect(h.requests, hasLength(4));
    });

    test('409 on a double tap', () async {
      final h = Harness((_) => json({'success': false, 'message': 'Booking already approved.'}, 409));
      final r = await h.api.bookings.act('b1', BookingAction.approve);
      expect(r.failure!.isConflict, isTrue);
      expect(r.errorMessage, 'Booking already approved.');
    });

    test('late fee intent and confirm', () async {
      final h = Harness((req) => req.url.path.endsWith('/intent')
          ? fixtureResponse('intent_hire')
          : json({
              'success': true,
              'data': {'id': 'b1', 'status': 'Completed', 'lateFee': {'hours': 1, 'amount': 44, 'status': 'paid'}}
            }));
      final i = await h.api.bookings.lateFeeIntent('b1');
      expect(h.last.url.path, '/api/v1/booking/b1/late-fee/intent');
      expect(i.data!.clientSecret, isNotEmpty);
      final c = await h.api.bookings.lateFeeConfirm('b1', 'pi_9');
      expect(h.last.url.path, '/api/v1/booking/b1/late-fee/confirm');
      expect(h.lastBody, {'paymentIntentId': 'pi_9'});
      expect(c.data!.lateFee!.status, LateFeeStatus.paid);
    });

    test('availability queries', () async {
      final h = Harness((req) => req.url.queryParameters.containsKey('date') ? fixtureResponse('rest_avail') : fixtureResponse('hire_avail'));
      final hire = await h.api.bookings.hireAvailability('l1', DateTime.utc(2026, 12, 1, 9), DateTime.utc(2026, 12, 2, 9));
      expect(h.last.url.queryParameters, {'start': '2026-12-01T09:00:00Z', 'end': '2026-12-02T09:00:00Z'});
      expect(hire.data!.items.single.available, 44);
      final rest = await h.api.bookings.restaurantAvailability('l1', DateTime(2026, 12, 1));
      expect(h.last.url.queryParameters, {'date': '2026-12-01'});
      expect(rest.data!.slots, isNotEmpty);
    });
  });

  group('transport-level failures', () {
    test('401 calls onUnAuthorize', () async {
      final h = Harness((_) => json({'success': false, 'message': 'Invalid or expired token.'}, 401));
      final r = await h.api.bookings.mine();
      expect(r.failure!.isUnauthorized, isTrue);
      expect(h.unauthorizedCalls, 1);
    });

    test('auth error wrapped as 500 with error.code 401', () async {
      final h = Harness((_) => json({'success': false, 'message': 'Please provide your token.', 'error': {'code': 401}}, 500));
      final r = await h.api.notifications.unreadCount();
      expect(r.failure!.statusCode, 401);
      expect(h.unauthorizedCalls, 1);
    });

    test('HTML gateway page (502) is a server error with a readable message', () async {
      final h = Harness((_) => http.Response('<html>Bad gateway</html>', 502));
      final r = await h.api.listings.browse(ServiceKind.transport);
      expect(r.failure!.isServerError, isTrue);
      expect(r.errorMessage, isNotEmpty);
      expect(h.unauthorizedCalls, 0);
    });

    test('200 with success:false is a failure', () async {
      final h = Harness((_) => json({'success': false, 'message': 'Nope'}));
      final r = await h.api.wallet.balance();
      expect(r.isSuccess, isFalse);
      expect(r.errorMessage, 'Nope');
    });

    test('200 with an unexpected shape is a bad-shape failure, not a crash', () async {
      final h = Harness((_) => json({'success': true, 'data': 'oops'}));
      final r = await h.api.bookings.detail('x');
      expect(r.failure!.statusCode, -2);
      final l = await h.api.bookings.mine();
      expect(l.failure!.statusCode, -2);
    });

    test('no connection', () async {
      final h = Harness((_) => throw const SocketException('down'));
      final r = await h.api.dashboard.provider();
      expect(r.failure!.isOffline, isTrue);
      expect(r.errorMessage, contains('internet'));
    });
  });

  group('notifications, wallet, dashboard', () {
    test('notifications list with unread meta and read endpoints', () async {
      final h = Harness((req) => req.method == 'GET'
          ? json({
              'success': true,
              'data': [
                {'id': 'n1', 'title': 'Hi', 'isRead': false, 'bookingId': 'b1', 'event': 'booking.approved'}
              ],
              'meta': {'page': 1, 'limit': 20, 'total': 1, 'totalPages': 1, 'unread': 1}
            })
          : json({'success': true, 'message': 'ok'}));
      final r = await h.api.notifications.list(unreadOnly: true);
      expect(h.last.url.queryParameters['unread'], 'true');
      expect(r.data!.meta.unread, 1);
      expect(r.data!.items.single.bookingId, 'b1');
      expect((await h.api.notifications.markRead('n1')).isSuccess, isTrue);
      expect(h.last.url.path, '/api/v1/notifications/n1/read');
      await h.api.notifications.markAllRead();
      expect(h.last.url.path, '/api/v1/notifications/read-all');
    });

    test('withdraw validates locally then sends the account id', () async {
      final h = Harness((_) => json({'success': true, 'message': 'Requested'}));
      expect((await h.api.wallet.withdraw(accountId: 'a', amount: 0)).isSuccess, isFalse);
      expect((await h.api.wallet.withdraw(accountId: 'a', amount: 50, balance: 10)).errorMessage, 'That is more than your balance.');
      expect(h.requests, isEmpty);
      final ok = await h.api.wallet.withdraw(accountId: 'a', amount: 10, balance: 10);
      expect(ok.isSuccess, isTrue);
      expect(h.last.url.path, '/api/v1/Withdraw/send-request');
      expect(h.lastBody, {'cardId': 'a', 'amount': 10});
    });

    test('add account strips spaces', () async {
      final h = Harness((_) => json({'success': true}));
      await h.api.wallet.addAccount(accountType: 'Bank Account', cardNumber: '4242 4242-4242 4242', cardHolderName: ' Ann ');
      expect(h.lastBody, {'accountType': 'Bank Account', 'cardNumber': '4242424242424242', 'cardHolderName': 'Ann'});
    });

    test('wallet account, withdrawals, dashboard from real responses', () async {
      final h = Harness((req) {
        final p = req.url.path;
        if (p.endsWith('get-my-account')) return fixtureResponse('p_account');
        if (p.endsWith('/Withdraw/my')) return fixtureResponse('p_withdraw');
        return fixtureResponse('p_dashboard');
      });
      expect((await h.api.wallet.account()).data!.accounts, hasLength(1));
      expect((await h.api.wallet.withdrawals()).data!.items, hasLength(2));
      final d = await h.api.dashboard.provider();
      expect(d.data!.bookings.requests, 1);
    });
  });
}
