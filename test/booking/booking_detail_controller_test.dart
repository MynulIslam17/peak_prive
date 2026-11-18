import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/data/api/peak_api.dart';
import 'package:harry_service_app/app/data/services/socket/live_events.dart';
import 'package:harry_service_app/app/modules/booking/controllers/booking_detail_controller.dart';
import 'package:harry_service_app/app/modules/booking/services/payment_sheet.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../api/fixtures.dart';
import '../api/harness.dart';

const id = '6afa86679a13dd70cc0c8cb8';

Map<String, dynamic> withData(String fixtureName, Map<String, dynamic> patch) {
  final f = fixture(fixtureName);
  return {...f, 'data': {...f['data'] as Map<String, dynamic>, ...patch}};
}

Future<BookingDetailController> start(Harness h, {PaymentSheet? sheet, bool providerHint = false, String bookingId = id}) async {
  registerHarness(h);
  final c = Get.put(BookingDetailController(
    bookingId: bookingId,
    paymentSheet: sheet ?? (_) async => const SheetOutcome.paid(),
    viewerIsProviderHint: providerHint,
    enableTimers: false,
  ));
  await pumpEventQueue();
  return c;
}

int gets(Harness h) => h.requests.where((r) => r.method == 'GET').length;

void main() {
  setUpAll(() => Logger.level = Level.off);
  tearDown(Get.reset);

  group('loading and role', () {
    test('customer view: provider card, only cancel', () async {
      final h = Harness((_) => fixtureResponse('u_booking_detail'));
      final c = await start(h);
      expect(h.last.url.path, '/api/v1/booking/$id');
      expect(c.isLoading, isFalse);
      expect(c.booking!.id, id);
      expect(c.isProviderView, isFalse);
      expect(c.primaryActions, isEmpty);
      expect(c.secondaryActions, [BookingAction.cancel]);
    });

    test('provider view: customer card, hand over + reject', () async {
      final h = Harness((_) => fixtureResponse('p_booking_detail'));
      final c = await start(h);
      expect(c.isProviderView, isTrue);
      expect(c.primaryActions, [BookingAction.handOver]);
      expect(c.secondaryActions, [BookingAction.reject]);
      expect(c.shows(BookingAction.approve), isFalse);
    });

    test('neither party in the payload falls back to the role hint', () async {
      final h = Harness((_) => json({'success': true, 'data': {'id': id, 'status': 'Pending', 'contact': {}}}));
      expect((await start(h, providerHint: true)).isProviderView, isTrue);
      final h2 = Harness((_) => json({'success': true, 'data': {'id': id, 'status': 'Pending', 'contact': {}}}));
      expect((await start(h2)).isProviderView, isFalse);
    });

    test('button order puts payment and approval first', () async {
      final h = Harness((_) => json({
            'success': true,
            'data': {'id': id, 'status': 'Pending', 'actions': ['reject', 'review', 'approve', 'pay_late_fee', 'cancel']}
          }));
      final c = await start(h);
      expect(c.primaryActions, [BookingAction.payLateFee, BookingAction.approve, BookingAction.review]);
      expect(c.secondaryActions, [BookingAction.reject, BookingAction.cancel]);
    });

    test('load error, retry, empty id', () async {
      var fail = true;
      final h = Harness((_) => fail ? json({'success': false, 'message': 'Booking not found.'}, 404) : fixtureResponse('u_booking_detail'));
      final c = await start(h);
      expect(c.booking, isNull);
      expect(c.errorMessage, 'Booking not found.');
      fail = false;
      await c.load();
      expect(c.errorMessage, isNull);
      expect(c.booking, isNotNull);

      final h2 = Harness((_) => fixtureResponse('u_booking_detail'));
      final c2 = await start(h2, bookingId: '');
      expect(c2.errorMessage, 'Booking not found.');
      expect(h2.requests, isEmpty);
    });

    test('a quiet refresh failure keeps the booking on screen', () async {
      var fail = false;
      final h = Harness((_) => fail ? http.Response('<html>502</html>', 502) : fixtureResponse('u_booking_detail'));
      final c = await start(h);
      fail = true;
      await c.refreshQuietly();
      expect(c.booking, isNotNull);
      expect(c.errorMessage, isNull);
    });
  });

  group('actions', () {
    test('success replaces the booking with the response', () async {
      final h = Harness((req) => req.method == 'PATCH'
          ? json(withData('p_booking_detail', {'status': 'InProgress', 'actions': ['return'], 'timeline': {'handedOverAt': '2026-11-19T03:05:00Z'}}))
          : fixtureResponse('p_booking_detail'));
      final c = await start(h);
      final o = await c.run(BookingAction.handOver);
      expect(o.ok, isTrue);
      expect(h.last.url.path, '/api/v1/booking/$id/hand-over');
      expect(c.booking!.status, BookingStatus.inProgress);
      expect(c.primaryActions, [BookingAction.markReturned]);
      expect(c.busyAction, isNull);
    });

    test('reject sends the reason', () async {
      final h = Harness((req) => req.method == 'PATCH'
          ? json(withData('p_booking_detail', {'status': 'Cancelled', 'actions': [], 'cancellation': {'by': 'provider', 'refundAmount': 175}}))
          : fixtureResponse('p_booking_detail'));
      final c = await start(h);
      final o = await c.run(BookingAction.reject, reason: 'Fully booked');
      expect(h.lastBody, {'reason': 'Fully booked'});
      expect(o.message, contains('full refund'));
      expect(c.primaryActions, isEmpty);
      expect(c.secondaryActions, isEmpty);
    });

    test('a 502 on an action re-reads the booking (the server may have done it)', () async {
      var cancelled = false;
      final h = Harness((req) {
        if (req.method == 'PATCH') {
          cancelled = true; // server did it, then the gateway failed
          return http.Response('error code: 502', 502);
        }
        return cancelled
            ? json(withData('u_booking_detail', {'status': 'Cancelled', 'actions': []}))
            : fixtureResponse('u_booking_detail');
      });
      final c = await start(h);
      final before = gets(h);
      final o = await c.run(BookingAction.cancel);
      expect(o.ok, isFalse);
      expect(o.message, contains("didn't answer"));
      await Future<void>.delayed(const Duration(seconds: 4));
      expect(gets(h), greaterThan(before));
      expect(c.booking!.status, BookingStatus.cancelled);
    });

    test('409 shows the server message and refetches', () async {
      final h = Harness((req) => req.method == 'PATCH'
          ? json({'success': false, 'message': 'Booking already cancelled.'}, 409)
          : fixtureResponse('p_booking_detail'));
      final c = await start(h);
      expect(gets(h), 1);
      final o = await c.run(BookingAction.handOver);
      await pumpEventQueue();
      expect(o.ok, isFalse);
      expect(o.message, 'Booking already cancelled.');
      expect(gets(h), 2);
    });

    test('a plain failure does not refetch', () async {
      final h = Harness((req) => req.method == 'PATCH'
          ? json({'success': false, 'message': 'Server error'}, 500)
          : fixtureResponse('p_booking_detail'));
      final c = await start(h);
      await c.run(BookingAction.handOver);
      await pumpEventQueue();
      expect(gets(h), 1);
    });

    test('double tap sends one request', () async {
      final gate = Completer<void>();
      final h = Harness((req) async {
        if (req.method == 'PATCH') {
          await gate.future;
          return json(withData('p_booking_detail', {'status': 'InProgress'}));
        }
        return fixtureResponse('p_booking_detail');
      });
      final c = await start(h);
      final first = c.run(BookingAction.handOver);
      await pumpEventQueue();
      expect(c.isBusy, isTrue);
      final second = await c.run(BookingAction.handOver);
      expect(second.silent, isTrue);
      expect((await c.payLateFee()).silent, isTrue);
      gate.complete();
      expect((await first).ok, isTrue);
      expect(h.requests.where((r) => r.method == 'PATCH'), hasLength(1));
    });

    test('cancel shows the refund from the response', () async {
      final h = Harness((req) => req.method == 'PATCH'
          ? json(withData('u_booking_detail', {'status': 'Cancelled', 'actions': [], 'refund': {'amount': 157.5, 'percent': 90}}))
          : fixtureResponse('u_booking_detail'));
      final c = await start(h);
      final o = await c.run(BookingAction.cancel);
      expect(h.last.url.path, '/api/v1/booking/$id/cancel');
      expect(o.message, 'Booking cancelled. €157.50 (90%) will be refunded to your card within a few minutes.');
    });

    for (final (status, text) in [
      ('refunded', 'Booking cancelled. €175.00 (100%) has been refunded to your card.'),
      ('pending', 'Booking cancelled. €175.00 (100%) will be refunded to your card within a few minutes.'),
    ]) {
      test('cancel with refund.status $status', () async {
        final h = Harness((req) => req.method == 'PATCH'
            ? json(withData('u_booking_detail', {
                'status': 'Cancelled',
                'actions': [],
                'refund': {'amount': 175, 'percent': 100, 'status': status},
              }))
            : fixtureResponse('u_booking_detail'));
        final c = await start(h);
        expect((await c.run(BookingAction.cancel)).message, text);
      });
    }

    test('return reports the late fee', () async {
      final h = Harness((req) => req.method == 'PATCH'
          ? json(withData('p_booking_detail', {'status': 'Completed', 'lateFee': {'hours': 2, 'amount': 88, 'status': 'due'}}))
          : fixtureResponse('p_booking_detail'));
      final c = await start(h);
      expect((await c.run(BookingAction.markReturned)).message, 'Marked as returned. Late fee: €88.00 (2 h).');
    });

    test('pay_late_fee and review are not PATCH actions', () async {
      final h = Harness((_) => fixtureResponse('u_booking_detail'));
      final c = await start(h);
      expect((await c.run(BookingAction.review)).silent, isTrue);
      expect(h.requests.where((r) => r.method != 'GET'), isEmpty);
    });
  });

  group('late fee payment', () {
    Harness lateFeeHarness({bool confirmFails = false}) => Harness((req) {
          final p = req.url.path;
          if (p.endsWith('/late-fee/intent')) return fixtureResponse('intent_hire');
          if (p.endsWith('/late-fee/confirm')) {
            return confirmFails
                ? json({'success': false, 'message': 'Not yet'}, 500)
                : json(withData('u_booking_detail', {'status': 'Completed', 'actions': ['review'], 'lateFee': {'hours': 1, 'amount': 44, 'status': 'paid'}}));
          }
          return json(withData('u_booking_detail', {'status': 'Completed', 'actions': ['pay_late_fee'], 'lateFee': {'hours': 1, 'amount': 44, 'status': 'due'}}));
        });

    test('success: intent → sheet → confirm', () async {
      final h = lateFeeHarness();
      PaymentIntentData? shown;
      final c = await start(h, sheet: (i) async {
        shown = i;
        return const SheetOutcome.paid();
      });
      expect(c.primaryActions.first, BookingAction.payLateFee);
      final o = await c.payLateFee();
      expect(shown!.clientSecret, isNotEmpty);
      expect(h.lastBody, {'paymentIntentId': 'pi_fixture'});
      expect(o.ok, isTrue);
      expect(c.booking!.lateFee!.status, LateFeeStatus.paid);
      expect(c.primaryActions, [BookingAction.review]);
    });

    test('sheet closed: nothing confirmed, silent', () async {
      final h = lateFeeHarness();
      final c = await start(h, sheet: (_) async => const SheetOutcome.canceled());
      final o = await c.payLateFee();
      expect(o.ok, isFalse);
      expect(o.silent, isTrue);
      expect(h.requests.where((r) => r.url.path.endsWith('/confirm')), isEmpty);
    });

    test('sheet failed: message, nothing confirmed', () async {
      final h = lateFeeHarness();
      final c = await start(h, sheet: (_) async => const SheetOutcome.failed('Card declined'));
      final o = await c.payLateFee();
      expect(o.message, 'Card declined');
      expect(h.requests.where((r) => r.url.path.endsWith('/confirm')), isEmpty);
    });

    test('paid but confirm failed: reassure and refetch', () async {
      final h = lateFeeHarness(confirmFails: true);
      final c = await start(h);
      final before = gets(h);
      final o = await c.payLateFee();
      await pumpEventQueue();
      expect(o.ok, isTrue);
      expect(o.message, contains('can take a minute'));
      expect(gets(h), before + 1);
    });

    test('intent refused (409) refetches', () async {
      final h = Harness((req) => req.url.path.endsWith('/intent')
          ? json({'success': false, 'message': 'Late fee already paid.'}, 409)
          : fixtureResponse('u_booking_detail'));
      final c = await start(h);
      final o = await c.payLateFee();
      await pumpEventQueue();
      expect(o.message, 'Late fee already paid.');
      expect(gets(h), 2);
    });
  });

  group('review', () {
    Harness reviewHarness(int status) => Harness((req) => req.method == 'POST'
        ? json(status == 201
            ? {'success': true, 'data': {'review': {'id': 'r'}, 'rating': {'average': 4, 'count': 2}}}
            : {'success': false, 'message': 'Already reviewed.'}, status)
        : json(withData('u_booking_detail', {'status': 'Completed', 'actions': ['review']})));

    test('saved review hides the button', () async {
      final h = reviewHarness(201);
      final c = await start(h);
      expect(c.primaryActions, [BookingAction.review]);
      final o = await c.submitReview(5, 'Great');
      expect(o.ok, isTrue);
      expect(h.last.url.path, '/api/v1/ski-hire/6939508f6fd3cd7f26c29698/review');
      expect(c.primaryActions, isEmpty);
    });

    test('409 means already reviewed: hide the button and say so', () async {
      final h = reviewHarness(409);
      final c = await start(h);
      final o = await c.submitReview(4, 'Nice');
      expect(o.ok, isFalse);
      expect(o.message, contains('already reviewed'));
      expect(c.shows(BookingAction.review), isFalse);
    });

    test('other errors keep the button', () async {
      final h = reviewHarness(500);
      final c = await start(h);
      await c.submitReview(4, 'Nice');
      expect(c.shows(BookingAction.review), isTrue);
    });
  });

  test('live updates refetch only the matching booking', () async {
    final h = Harness((_) => fixtureResponse('u_booking_detail'));
    await start(h);
    expect(gets(h), 1);
    LiveEvents.emitBookingUpdate(const BookingUpdate('someone-else', 'Completed'));
    await pumpEventQueue();
    expect(gets(h), 1);
    LiveEvents.emitBookingUpdate(const BookingUpdate(id, 'Completed'));
    await pumpEventQueue();
    expect(gets(h), 2);
    Get.delete<BookingDetailController>();
    LiveEvents.emitBookingUpdate(const BookingUpdate(id, 'Completed'));
    await pumpEventQueue();
    expect(gets(h), 2); // closed controller stopped listening
  });

  test('resolvePublishableKey never uses a secret key', () {
    expect(resolvePublishableKey('pk_test_abc'), 'pk_test_abc');
    expect(resolvePublishableKey('sk_test_abc', fallback: 'pk_test_x'), 'pk_test_x');
    expect(resolvePublishableKey('sk_live_abc', fallback: 'pk_test_x'), '');
    expect(resolvePublishableKey('sk_test_abc', fallback: ''), '');
  });
}
