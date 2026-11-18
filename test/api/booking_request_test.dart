import 'package:flutter_test/flutter_test.dart';
import 'package:harry_service_app/app/data/api/peak_api.dart';

void main() {
  final now = DateTime(2026, 11, 16, 12);

  test('formatDay pads', () {
    expect(formatDay(DateTime(2026, 2, 3)), '2026-02-03');
  });

  test('formatInstant always has a zone', () {
    expect(formatInstant(DateTime.utc(2026, 12, 20, 8)), '2026-12-20T08:00:00Z');
    final local = formatInstant(DateTime(2026, 12, 20, 9));
    expect(local, matches(RegExp(r'^2026-12-20T09:00:00[+-]\d{2}:\d{2}$')));
    // Round-trips to the same instant.
    expect(DateTime.parse(local).toUtc(), DateTime(2026, 12, 20, 9).toUtc());
  });

  test('ski pass body', () {
    final r = BookingRequest.skiPass(productId: 'p', day: DateTime(2026, 12, 20), persons: 2, phoneNumber: '  ');
    expect(r.toJson(), {'productId': 'p', 'date': '2026-12-20', 'personCount': 2});
    expect(r.validate(now: now), isNull);
  });

  test('massage body and checks', () {
    final r = BookingRequest.massage(productId: 'p', day: DateTime(2026, 12, 20), time: '10:30 AM', duration: '60 min');
    expect(r.toJson()['time'], '10:30 AM');
    expect(r.toJson()['duration'], '60 min');
    expect(r.validate(now: now), isNull);
    expect(BookingRequest.massage(productId: 'p', day: DateTime(2026, 12, 20), time: '', duration: '60 min').validate(now: now), 'Choose a time.');
    expect(BookingRequest.massage(productId: 'p', day: DateTime(2026, 11, 1), time: '1:00 PM', duration: '60 min').validate(now: now), 'The date is in the past.');
  });

  test('restaurant drops zero-quantity seats', () {
    final r = BookingRequest.restaurant(
      productId: 'p',
      day: DateTime(2026, 12, 20),
      slotId: 's',
      seats: const [ItemQuantity('vip', 2), ItemQuantity('normal', 0)],
    );
    expect(r.toJson()['bookingItems'], [
      {'itemId': 'vip', 'quantity': 2}
    ]);
    expect(r.validate(now: now), isNull);
    final empty = BookingRequest.restaurant(productId: 'p', day: DateTime(2026, 12, 20), slotId: 's', seats: const [ItemQuantity('a', 0)]);
    expect(empty.validate(now: now), 'Choose at least one seat.');
    final noSlot = BookingRequest.restaurant(productId: 'p', day: DateTime(2026, 12, 20), slotId: '', seats: const [ItemQuantity('a', 1)]);
    expect(noSlot.validate(now: now), 'Choose a time slot.');
  });

  test('ski hire body and period checks', () {
    final start = DateTime(2026, 12, 20, 9);
    final r = BookingRequest.skiHire(productId: 'p', start: start, end: start.add(const Duration(days: 2)), items: const [ItemQuantity('ski', 2)], address: ' Hotel ');
    final j = r.toJson();
    expect(j['startDateAndTime'], formatInstant(start));
    expect(j['address'], 'Hotel');
    expect(r.validate(now: now), isNull);
    expect(r.toCreateJson('pi_1')['paymentIntentId'], 'pi_1');

    expect(BookingRequest.skiHire(productId: 'p', start: start, end: start, items: const [ItemQuantity('ski', 1)]).validate(now: now),
        'The return time must be after the pick-up time.');
    expect(BookingRequest.skiHire(productId: 'p', start: DateTime(2026, 11, 1), end: start, items: const [ItemQuantity('ski', 1)]).validate(now: now),
        'The pick-up time is in the past.');
    expect(BookingRequest.skiHire(productId: 'p', start: start, end: start.add(const Duration(hours: 1)), items: const []).validate(now: now),
        'Choose at least one item.');
  });

  test('transport body', () {
    final start = DateTime(2026, 12, 20, 8);
    final r = BookingRequest.transport(productId: 'p', start: start, end: start.add(const Duration(hours: 2)), passengers: 3, pickupAddress: 'Hotel Alpina', destination: 'Geneva airport');
    final j = r.toJson();
    expect(j['personCount'], 3);
    expect(j['address'], 'Hotel Alpina');
    expect(j['destination'], 'Geneva airport');
    expect(r.validate(now: now), isNull);
    final zero = BookingRequest.transport(productId: 'p', start: start, end: start.add(const Duration(hours: 2)), passengers: 0);
    expect(zero.validate(now: now), 'At least one person is needed.');
  });

  test('payment intent response', () {
    final p = PaymentIntentData.fromJson({
      'paymentIntentId': 'pi_1',
      'clientSecret': 'pi_1_secret_x',
      'publishableKey': 'pk_test_x',
      'amount': 100,
      'currency': 'eur',
      'category': 'Ski_Hire',
      'breakdown': {
        'items': [
          {'itemId': 'a', 'name': 'aaa', 'quantity': 2, 'price': 25}
        ],
        'priceUnit': 'per_day',
        'units': 2
      }
    });
    expect(p.isComplete, isTrue);
    expect(p.kind, ServiceKind.skiHire);
    expect(p.breakdown!.units, 2);
    expect(p.breakdown!.items.single.quantity, 2);
    expect(PaymentIntentData.fromJson({}).isComplete, isFalse);
  });
}
