import 'package:flutter_test/flutter_test.dart';
import 'package:harry_service_app/app/data/services/stripe/checkout_math.dart';

void main() {
  final s = DateTime(2026, 12, 20, 9);

  test('rentalUnits counts started units', () {
    expect(rentalUnits('per_day', s, s.add(const Duration(hours: 1))), 1);
    expect(rentalUnits('per_day', s, s.add(const Duration(days: 2))), 2);
    expect(rentalUnits('per_day', s, s.add(const Duration(days: 2, minutes: 1))), 3);
    expect(rentalUnits('per_hour', s, s.add(const Duration(minutes: 61))), 2);
    expect(rentalUnits('per_rental', s, s.add(const Duration(days: 9))), 1);
    expect(rentalUnits('per_day', s, s), 1);
    expect(rentalUnits('unknown', s, s.add(const Duration(days: 1))), 1);
  });

  test('clampQuantities caps to availability and drops zeros', () {
    expect(clampQuantities({'a': 5, 'b': 2, 'c': 1}, {'a': 3, 'b': 0}), {'a': 3});
    expect(clampQuantities({'a': -1}, {'a': 3}), isEmpty);
  });

  test('parseClock', () {
    expect(parseClock('7:00 PM'), 19 * 60);
    expect(parseClock('12:21 AM'), 21);
    expect(parseClock('12:00 PM'), 12 * 60);
    expect(parseClock('21:30'), 21 * 60 + 30);
    expect(parseClock('9 am'), 9 * 60);
    expect(parseClock('25:00'), isNull);
    expect(parseClock('13:00 PM'), isNull);
    expect(parseClock('soon'), isNull);
    expect(parseClock(null), isNull);
  });

  test('formatClock', () {
    expect(formatClock(0), '12:00 AM');
    expect(formatClock(19 * 60 + 5), '7:05 PM');
    expect(formatClock(24 * 60 + 30), '12:30 AM');
  });

  group('sessionStartTimes', () {
    final day = DateTime(2026, 12, 20);
    test('fits the session before closing', () {
      final t = sessionStartTimes(openTime: '9:00 AM', closeTime: '11:00 AM', durationMinutes: 60, day: day, now: DateTime(2026, 12, 1));
      expect(t.map(formatClock), ['9:00 AM', '9:30 AM', '10:00 AM']);
    });
    test('closing after midnight', () {
      final t = sessionStartTimes(openTime: '10:00 PM', closeTime: '1:00 AM', durationMinutes: 90, day: day, now: DateTime(2026, 12, 1));
      expect(t.map(formatClock), ['10:00 PM', '10:30 PM', '11:00 PM', '11:30 PM']);
    });
    test('today skips past times (with lead time)', () {
      final t = sessionStartTimes(openTime: '9:00 AM', closeTime: '12:00 PM', durationMinutes: 60, day: day, now: DateTime(2026, 12, 20, 9, 40));
      expect(t.map(formatClock), ['10:30 AM', '11:00 AM']);
    });
    test('session longer than opening hours or bad times → none', () {
      expect(sessionStartTimes(openTime: '12:21 AM', closeTime: '2:21 AM', durationMinutes: 682, day: day, now: DateTime(2026)), isEmpty);
      expect(sessionStartTimes(openTime: 'x', closeTime: '2:21 AM', durationMinutes: 60, day: day), isEmpty);
    });
  });
}
