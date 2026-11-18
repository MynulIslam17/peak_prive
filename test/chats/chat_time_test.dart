import 'package:flutter_test/flutter_test.dart';
import 'package:harry_service_app/app/core/utils/date_parser.dart';

void main() {
  final now = DateTime(2026, 11, 17, 11, 30);

  test('chat list time: today shows the time, then Yesterday, then dates', () {
    expect(DateParserHelper.chatListTime(DateTime(2026, 11, 17, 11, 10), now: now), '11:10 AM');
    expect(DateParserHelper.chatListTime(DateTime(2026, 11, 16, 23, 0), now: now), 'Yesterday');
    expect(DateParserHelper.chatListTime(DateTime(2026, 11, 3, 9, 0), now: now), '3 Nov');
    expect(DateParserHelper.chatListTime(DateTime(2025, 12, 3, 9, 0), now: now), '3 Dec 2025');
  });

  test('chat bubble time: time today, date and time otherwise', () {
    expect(DateParserHelper.chatBubbleTime(DateTime(2026, 11, 17, 9, 5), now: now), '9:05 AM');
    expect(DateParserHelper.chatBubbleTime(DateTime(2026, 11, 16, 21, 0), now: now), '16 Nov, 9:00 PM');
  });
}
