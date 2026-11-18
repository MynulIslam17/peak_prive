import 'package:flutter_test/flutter_test.dart';
import 'package:harry_service_app/app/data/services/socket/live_events.dart';

void main() {
  test('a reconnect concerns every booking', () async {
    final got = <BookingUpdate>[];
    final sub = LiveEvents.bookingUpdates.listen(got.add);
    LiveEvents.emitReconnected();
    LiveEvents.emitBookingUpdate(const BookingUpdate('b1', 'Confirmed'));
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();
    expect(got.first.isAny, isTrue);
    expect(got.first.concerns('anything'), isTrue);
    expect(got.last.concerns('b1'), isTrue);
    expect(got.last.concerns('b2'), isFalse);
  });
}
