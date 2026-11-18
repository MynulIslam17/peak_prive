import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:harry_service_app/app/data/api/peak_api.dart';
import 'package:harry_service_app/app/data/services/stripe/checkout_controller.dart';
import 'package:harry_service_app/app/data/services/stripe/payment_sheet.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../api/fixtures.dart';
import '../api/harness.dart';

/// Scripted payment sheet.
class FakeSheet implements PaymentSheet {
  FakeSheet(this.outcomes);
  final List<SheetOutcome> outcomes;
  final presented = <(String, String)>[];

  @override
  Future<SheetOutcome> present({required String publishableKey, required String clientSecret}) async {
    presented.add((publishableKey, clientSecret));
    return outcomes.removeAt(0);
  }
}

const ok = SheetOutcome(SheetStatus.succeeded);

Map<String, dynamic> intentJson({num amount = 100, String key = 'pk_test_fixture', String pi = 'pi_abc'}) {
  final j = fixture('intent_hire');
  final d = Map<String, dynamic>.from(j['data'] as Map);
  d['amount'] = amount;
  d['publishableKey'] = key;
  d['paymentIntentId'] = pi;
  return {...j, 'data': d};
}

BookingRequest hireRequest() {
  final start = DateTime.now().add(const Duration(days: 10));
  return BookingRequest.skiHire(
    productId: 'p',
    start: start,
    end: start.add(const Duration(days: 2)),
    items: const [ItemQuantity('i', 2)],
  );
}

void main() {
  setUpAll(() => Logger.level = Level.off);

  late List<http.Response Function(http.Request)> script;
  late Harness h;

  void serve(List<http.Response Function(http.Request)> s) {
    script = s;
    h = Harness((req) => script.removeAt(0)(req));
    registerHarness(h);
  }

  http.Response intentOk(_) => json(intentJson());
  http.Response created(_) => fixtureResponse('u_booking_detail', 201);

  test('happy path: intent → sheet → create', () async {
    serve([intentOk, created]);
    final sheet = FakeSheet([ok]);
    final c = CheckoutController(sheet: sheet);
    final out = await c.pay(hireRequest(), shownAmount: 100);
    expect(out, CheckoutOutcome.booked);
    expect(c.phase, CheckoutPhase.done);
    expect(c.booking!.id, '6afa86679a13dd70cc0c8cb8');
    expect(sheet.presented.single.$1, 'pk_test_fixture');
    expect(h.requests.map((r) => r.url.path), ['/api/v1/booking/intent', '/api/v1/booking/create']);
    final createBody = jsonDecode(h.requests.last.body) as Map;
    expect(createBody['paymentIntentId'], 'pi_abc');
    expect(createBody['bookingItems'], [
      {'itemId': 'i', 'quantity': 2}
    ]);
    expect(c.isLocked, isTrue);
    // A further tap does nothing.
    expect(await c.pay(hireRequest()), CheckoutOutcome.problem);
    expect(h.requests, hasLength(2));
  });

  test('invalid request never reaches the server', () async {
    serve([]);
    final c = CheckoutController(sheet: FakeSheet([]));
    final start = DateTime.now().add(const Duration(days: 1));
    final out = await c.pay(BookingRequest.skiHire(productId: 'p', start: start, end: start, items: const [ItemQuantity('i', 1)]));
    expect(out, CheckoutOutcome.problem);
    expect(c.problem!.kind, CheckoutProblemKind.invalid);
    expect(c.problem!.message, 'The return time must be after the pick-up time.');
    expect(h.requests, isEmpty);
  });

  test('409 before payment: unavailable, nothing charged', () async {
    serve([(_) => json({'success': false, 'message': 'Only 1 VIP seat(s) left.'}, 409)]);
    final sheet = FakeSheet([]);
    final c = CheckoutController(sheet: sheet);
    expect(await c.pay(hireRequest()), CheckoutOutcome.problem);
    expect(c.problem!.kind, CheckoutProblemKind.unavailable);
    expect(c.problem!.message, 'Only 1 VIP seat(s) left.');
    expect(sheet.presented, isEmpty);
  });

  test('402 unpaid late fee', () async {
    serve([(_) => json({'success': false, 'message': 'Please pay your outstanding late fee first.'}, 402)]);
    final c = CheckoutController(sheet: FakeSheet([]));
    await c.pay(hireRequest());
    expect(c.problem!.kind, CheckoutProblemKind.lateFeeDue);
    expect(c.problem!.message, contains('late fee'));
  });

  test('400 shows server message and field errors', () async {
    serve([
      (_) => json({
            'success': false,
            'message': 'Invalid booking.',
            'errors': [
              {'field': 'date', 'message': 'date is closed'}
            ]
          }, 400)
    ]);
    final c = CheckoutController(sheet: FakeSheet([]));
    await c.pay(hireRequest());
    expect(c.problem!.kind, CheckoutProblemKind.invalid);
    expect(c.problem!.message, 'Invalid booking.\ndate is closed');
  });

  test('price changed: no sheet; second tap reuses the same intent', () async {
    serve([(_) => json(intentJson(amount: 120)), created]);
    final sheet = FakeSheet([ok]);
    final c = CheckoutController(sheet: sheet);
    final req = hireRequest();
    expect(await c.pay(req, shownAmount: 100), CheckoutOutcome.problem);
    expect(c.problem!.kind, CheckoutProblemKind.priceChanged);
    expect(c.problem!.message, contains('€120'));
    expect(c.quotedAmountFor(req), 120);
    expect(sheet.presented, isEmpty);

    expect(await c.pay(req, shownAmount: c.quotedAmountFor(req)), CheckoutOutcome.booked);
    expect(h.requests.where((r) => r.url.path.endsWith('/intent')), hasLength(1));
  });

  test('cancelled sheet: no booking; paying again reuses the intent', () async {
    serve([intentOk, created]);
    final sheet = FakeSheet([const SheetOutcome(SheetStatus.canceled), ok]);
    final c = CheckoutController(sheet: sheet);
    final req = hireRequest();
    expect(await c.pay(req), CheckoutOutcome.canceled);
    expect(c.problem, isNull);
    expect(c.phase, CheckoutPhase.idle);
    expect(c.isLocked, isFalse);
    expect(await c.pay(req), CheckoutOutcome.booked);
    expect(sheet.presented, hasLength(2));
    expect(h.requests.where((r) => r.url.path.endsWith('/intent')), hasLength(1));
  });

  test('changed request after cancel creates a new intent', () async {
    serve([intentOk, intentOk]);
    final c = CheckoutController(sheet: FakeSheet([const SheetOutcome(SheetStatus.canceled), const SheetOutcome(SheetStatus.canceled)]));
    await c.pay(hireRequest());
    final start = DateTime.now().add(const Duration(days: 20));
    await c.pay(BookingRequest.skiHire(productId: 'p', start: start, end: start.add(const Duration(days: 1)), items: const [ItemQuantity('i', 1)]));
    expect(h.requests.where((r) => r.url.path.endsWith('/intent')), hasLength(2));
  });

  test('card declined', () async {
    serve([intentOk]);
    final c = CheckoutController(sheet: FakeSheet([const SheetOutcome(SheetStatus.failed, 'Your card was declined.')]));
    await c.pay(hireRequest());
    expect(c.problem!.kind, CheckoutProblemKind.paymentFailed);
    expect(c.problem!.message, 'Your card was declined.');
    expect(c.paidIntentId, isNull);
  });

  test('processing payment is not paid twice', () async {
    serve([intentOk, intentOk]);
    final sheet = FakeSheet([const SheetOutcome(SheetStatus.processing), const SheetOutcome(SheetStatus.canceled)]);
    final c = CheckoutController(sheet: sheet);
    final req = hireRequest();
    await c.pay(req);
    expect(c.problem!.kind, CheckoutProblemKind.paymentProcessing);
    expect(c.quotedAmountFor(req), isNull); // old intent forgotten
  });

  test('network error after payment: retry create with the same paymentIntentId, no new sheet', () async {
    serve([
      intentOk,
      (_) => throw const SocketException('down'),
      created,
    ]);
    final sheet = FakeSheet([ok]);
    final c = CheckoutController(sheet: sheet);
    final req = hireRequest();
    expect(await c.pay(req), CheckoutOutcome.problem);
    expect(c.problem!.kind, CheckoutProblemKind.confirmRetry);
    expect(c.problem!.message, contains('pi_abc'));
    expect(c.needsConfirmRetry, isTrue);
    expect(c.isLocked, isTrue);

    // Even a changed request retries what was paid for.
    expect(await c.pay(BookingRequest.skiPass(productId: 'x', day: DateTime.now())), CheckoutOutcome.booked);
    expect(sheet.presented, hasLength(1));
    final creates = h.requests.where((r) => r.url.path.endsWith('/create')).toList();
    expect(creates, hasLength(2));
    for (final r in creates) {
      final b = jsonDecode(r.body) as Map;
      expect(b['paymentIntentId'], 'pi_abc');
      expect(b['productId'], 'p');
    }
  });

  test('5xx after payment is retryable too', () async {
    serve([intentOk, (_) => http.Response('<html>502</html>', 502)]);
    final c = CheckoutController(sheet: FakeSheet([ok]));
    await c.pay(hireRequest());
    expect(c.problem!.kind, CheckoutProblemKind.confirmRetry);
  });

  test('409 after payment with refund message: not retryable, message kept', () async {
    serve([intentOk, (_) => json({'success': false, 'message': 'The last unit was just booked. Your payment has been refunded.'}, 409)]);
    final c = CheckoutController(sheet: FakeSheet([ok]));
    await c.pay(hireRequest());
    expect(c.problem!.kind, CheckoutProblemKind.rejectedAfterPayment);
    expect(c.problem!.message, 'The last unit was just booked. Your payment has been refunded.');
    expect(c.needsConfirmRetry, isFalse);
    expect(c.isLocked, isFalse);
  });

  test('rejection without refund wording adds a refund note', () async {
    serve([intentOk, (_) => json({'success': false, 'message': 'Listing inactive.'}, 400)]);
    final c = CheckoutController(sheet: FakeSheet([ok]));
    await c.pay(hireRequest());
    expect(c.problem!.message, contains('refunded automatically'));
  });

  test('sk_ key from the server is never used', () async {
    serve([(_) => json(intentJson(key: 'sk_test_LEAKED'))]);
    final sheet = FakeSheet([ok]);
    final c = CheckoutController(sheet: sheet);
    await c.pay(hireRequest());
    expect(c.problem!.kind, CheckoutProblemKind.paymentSetup);
    expect(sheet.presented, isEmpty);
  });

  test('sk_ key falls back to a same-mode build key', () async {
    serve([(_) => json(intentJson(key: 'sk_test_LEAKED')), created]);
    final sheet = FakeSheet([ok]);
    final c = CheckoutController(
      sheet: sheet,
      keyResolver: (k) => resolvePublishableKey(k, fallback: 'pk_test_build'),
    );
    expect(await c.pay(hireRequest()), CheckoutOutcome.booked);
    expect(sheet.presented.single.$1, 'pk_test_build');
  });

  test('offline before payment', () async {
    serve([(_) => throw const SocketException('down')]);
    final c = CheckoutController(sheet: FakeSheet([]));
    await c.pay(hireRequest());
    expect(c.problem!.kind, CheckoutProblemKind.offline);
  });

  group('resolvePublishableKey', () {
    test('pk_ from server wins', () => expect(resolvePublishableKey(' pk_live_x ', fallback: 'pk_test_y'), 'pk_live_x'));
    test('secret key: fallback only in same mode', () {
      expect(resolvePublishableKey('sk_test_x', fallback: 'pk_test_y'), 'pk_test_y');
      expect(resolvePublishableKey('sk_live_x', fallback: 'pk_test_y'), '');
      expect(resolvePublishableKey('rk_live_x', fallback: 'pk_live_y'), 'pk_live_y');
      expect(resolvePublishableKey('sk_test_x', fallback: 'sk_test_z'), '');
      expect(resolvePublishableKey('', fallback: 'pk_test_y'), '');
    });
  });
}
