import 'package:flutter_test/flutter_test.dart';
import 'package:harry_service_app/app/data/api/models/app_notification.dart';

void main() {
  test('ISO instants in text become local time', () {
    final utc = DateTime.utc(2026, 11, 16, 9, 45).toLocal();
    final h = utc.hour % 12 == 0 ? 12 : utc.hour % 12;
    final out = localizeTimestamps('Please return it by 2026-11-16T09:45:00.000Z.');
    expect(out, contains('$h:45 ${utc.hour < 12 ? 'AM' : 'PM'}'));
    expect(out, isNot(contains('T09:45')));
    expect(out, endsWith('.'));
  });

  test('text without timestamps is unchanged', () {
    expect(localizeTimestamps('Booking 2026-11-16 confirmed'), 'Booking 2026-11-16 confirmed');
  });
}
