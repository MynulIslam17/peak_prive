import 'package:flutter_test/flutter_test.dart';
import 'package:harry_service_app/app/data/api/peak_api.dart';
import 'package:harry_service_app/app/modules/booking/booking_text.dart';

void main() {
  test('durationText', () {
    expect(durationText(0), 'less than a minute');
    expect(durationText(45), '45 min');
    expect(durationText(60), '1 h');
    expect(durationText(192), '3 h 12 min');
    expect(durationText(60 * 24 * 2 + 300), '2 d 5 h');
    expect(durationText(60 * 24), '1 d');
  });

  group('timerText', () {
    final at = DateTime(2026, 11, 16, 10);
    BookingTimer t(TimerState s, int m, [num fee = 0]) => BookingTimer(state: s, minutes: m, lateFee: fee, receivedAt: at);

    test('every state', () {
      expect(timerText(t(TimerState.startsIn, 90), now: at), 'Pick-up in 1 h 30 min');
      expect(timerText(t(TimerState.returnIn, 30), now: at), 'Return in 30 min');
      expect(timerText(t(TimerState.pickupDue, 5), now: at), 'Pick-up time passed 5 min ago');
      expect(timerText(t(TimerState.pickupDue, 5), now: at, forProvider: true), contains('Tap Hand over'));
      expect(timerText(t(TimerState.overdue, 70, 50), now: at), 'Late by 1 h 10 min · €50.00 late fee so far');
      expect(timerText(t(TimerState.overdue, 5, 0), now: at), 'Late by 5 min · late fee starts after 15 min');
      expect(timerText(null), isNull);
    });

    test('counts locally: down for starts_in, up for overdue', () {
      final later = at.add(const Duration(minutes: 10));
      expect(timerText(t(TimerState.startsIn, 30), now: later), 'Pick-up in 20 min');
      expect(timerText(t(TimerState.overdue, 30), now: later), startsWith('Late by 40 min'));
      expect(timerText(t(TimerState.startsIn, 5), now: later), 'Pick-up due now');
    });

    test('a countdown that ran out says "due now" and asks for a reload', () {
      final t1 = t(TimerState.returnIn, 2);
      expect(t1.hasRunOut(at.add(const Duration(seconds: 90))), isFalse);
      expect(timerText(t1, now: at.add(const Duration(seconds: 90))), 'Return in 1 min');
      expect(t1.hasRunOut(at.add(const Duration(minutes: 2))), isTrue);
      expect(timerText(t1, now: at.add(const Duration(minutes: 3))), 'Return due now');
      expect(t(TimerState.returnIn, 0).hasRunOut(at), isTrue);
      // Count-up states never run out.
      expect(t(TimerState.overdue, 0).hasRunOut(at.add(const Duration(hours: 1))), isFalse);
      expect(t(TimerState.pickupDue, 0).hasRunOut(at.add(const Duration(hours: 1))), isFalse);
    });
  });

  group('cancelRefundPreview', () {
    final now = DateTime(2026, 11, 16, 12);
    Booking b(String status, DateTime start, num total) => Booking.fromJson({
          'id': 'b',
          'status': status,
          'price': {'total': total},
          'schedule': {'startAt': start.toUtc().toIso8601String()},
        });

    test('pending is always 100%', () {
      final p = cancelRefundPreview(b('Pending', now.add(const Duration(hours: 1)), 25), now: now);
      expect(p.percent, 100);
      expect(p.amount, 25);
    });
    test('more than 24 h before the start: 100%', () {
      expect(cancelRefundPreview(b('Confirmed', now.add(const Duration(hours: 25)), 25), now: now).percent, 100);
    });
    test('within 24 h: 90%, rounded to cents', () {
      final p = cancelRefundPreview(b('Confirmed', now.add(const Duration(hours: 5)), 33.33), now: now);
      expect(p.percent, 90);
      expect(p.amount, 30.0);
    });
  });

  test('scheduleLine per service', () {
    final hire = Booking.fromJson({
      'id': 'a',
      'category': 'Ski_Hire',
      'schedule': {'startAt': '2026-11-19T03:00:00.000Z', 'endAt': '2026-11-26T03:00:00.000Z'},
    });
    expect(scheduleLine(hire), contains('→'));
    final massage = Booking.fromJson({
      'id': 'a',
      'category': 'Massage',
      'schedule': {'date': '2026-05-03', 'time': '09:48', 'duration': '60 min'},
    });
    expect(scheduleLine(massage), 'Sun, 3 May 2026 · 09:48 · 60 min');
    final rest = Booking.fromJson({
      'id': 'a',
      'category': 'Restaurant',
      'schedule': {'date': '2026-05-31', 'slot': {'startTime': '7:00 PM', 'endTime': '9:00 PM'}},
    });
    expect(scheduleLine(rest), 'Sun, 31 May 2026 · 7:00 PM – 9:00 PM');
    final pass = Booking.fromJson({'id': 'a', 'category': 'Ski_Pass', 'schedule': {'date': '2026-11-18'}});
    expect(scheduleLine(pass), 'Wed, 18 Nov 2026');
    expect(scheduleLine(Booking.fromJson({'id': 'a'})), '');
  });

  test('peopleText and bookingDayOf', () {
    expect(peopleText(1), '1 person');
    expect(peopleText(3, one: 'passenger', many: 'passengers'), '3 passengers');
    expect(peopleText(null), isNull);
    expect(peopleText(0), isNull);
    final b = Booking.fromJson({'id': 'a', 'schedule': {'date': '2026-11-18', 'startAt': '2026-11-17T23:00:00.000Z'}});
    expect(bookingDayOf(b), DateTime(2026, 11, 18)); // calendar day wins over the instant
    expect(bookingDayOf(Booking.fromJson({'id': 'a'})), isNull);
  });
}
