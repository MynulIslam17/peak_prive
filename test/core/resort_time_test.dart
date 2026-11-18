import 'package:flutter_test/flutter_test.dart';
import 'package:harry_service_app/app/core/utils/resort_time.dart';
import 'package:harry_service_app/app/core/widgets/booking_details_parts.dart';
import 'package:harry_service_app/app/data/api/models/service_kind.dart';

void main() {
  test('winter: Paris is UTC+1', () {
    // 15:00 in Bangladesh (UTC+6) = 09:00 UTC = 10:00 in Paris.
    final n = resortNow(DateTime.utc(2026, 11, 17, 9, 0));
    expect([n.hour, n.minute], [10, 0]);
    expect(n.isUtc, isFalse);
  });

  test('summer: Paris is UTC+2, switching on the last Sundays', () {
    expect(resortNow(DateTime.utc(2026, 7, 1, 9)).hour, 11);
    // 2026: summer time 29 Mar 01:00 UTC → 25 Oct 01:00 UTC.
    expect(resortNow(DateTime.utc(2026, 3, 29, 0, 59)).hour, 1);
    expect(resortNow(DateTime.utc(2026, 3, 29, 1, 0)).hour, 3);
    expect(resortNow(DateTime.utc(2026, 10, 25, 0, 59)).hour, 2);
    expect(resortNow(DateTime.utc(2026, 10, 25, 1, 0)).hour, 2);
  });

  test('resort today can differ from the phone day', () {
    // 23:30 UTC on 17 Nov is already 18 Nov in Paris.
    expect(resortToday(DateTime.utc(2026, 11, 17, 23, 30)), DateTime(2026, 11, 18));
  });

  test('booking times use Paris time for resort-clock services', () {
    // Approval deadline for an 11:00 AM Paris massage = 10:00 UTC.
    final deadline = DateTime.utc(2026, 11, 17, 10);
    expect(bookingDateTime(deadline, kind: ServiceKind.massage), '17 Nov 2026 · 11:00 AM');
    expect(bookingDateTime(deadline, kind: ServiceKind.restaurant), '17 Nov 2026 · 11:00 AM');
    expect(bookingClock(deadline, ServiceKind.transport), deadline.toLocal());
  });
}
