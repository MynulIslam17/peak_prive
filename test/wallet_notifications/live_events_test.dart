import 'package:flutter_test/flutter_test.dart';
import 'package:harry_service_app/app/data/services/socket/live_events.dart';

void main() {
  group('booking:updated', () {
    test('map, JSON string, list-wrapped and bookingId alias', () {
      expect(LiveEvents.parseBookingUpdate({'id': 'b1', 'status': 'Confirmed'})!.bookingId, 'b1');
      expect(LiveEvents.parseBookingUpdate({'id': 'b1', 'status': 'Confirmed'})!.status, 'Confirmed');
      expect(LiveEvents.parseBookingUpdate('{"id":"b2","status":"Cancelled"}')!.bookingId, 'b2');
      expect(LiveEvents.parseBookingUpdate([{'id': 'b3'}])!.status, isNull);
      expect(LiveEvents.parseBookingUpdate({'bookingId': 'b4'})!.bookingId, 'b4');
    });

    test('malformed payloads are ignored', () {
      expect(LiveEvents.parseBookingUpdate(null), isNull);
      expect(LiveEvents.parseBookingUpdate('not json'), isNull);
      expect(LiveEvents.parseBookingUpdate(42), isNull);
      expect(LiveEvents.parseBookingUpdate([]), isNull);
      expect(LiveEvents.parseBookingUpdate({'status': 'Confirmed'}), isNull);
      expect(LiveEvents.parseBookingUpdate({'id': '  '}), isNull);
    });

    test('emitted updates reach listeners; empty ids are dropped', () async {
      final got = <String>[];
      final sub = LiveEvents.bookingUpdates.listen((u) => got.add(u.bookingId));
      LiveEvents.emitBookingUpdate(const BookingUpdate('b1', 'Confirmed'));
      LiveEvents.emitBookingUpdate(const BookingUpdate('', null));
      await Future<void>.delayed(Duration.zero);
      expect(got, ['b1']);
      await sub.cancel();
    });
  });

  group('notification:new', () {
    final payload = {
      'id': 'n1',
      'title': 'Booking approved',
      'description': 'Your booking was approved.',
      'event': 'booking.approved',
      'bookingId': 'b1',
      'isRead': false,
      'createdAt': '2026-11-16T06:00:00Z',
    };

    test('plain, wrapped in notification/data, JSON string', () {
      expect(LiveEvents.parseNotification(payload)!.bookingId, 'b1');
      expect(LiveEvents.parseNotification({'notification': payload})!.id, 'n1');
      expect(LiveEvents.parseNotification({'data': payload})!.event, 'booking.approved');
      expect(LiveEvents.parseNotification('{"_id":"n2","title":"Hi"}')!.id, 'n2');
      // The notification's own `data` (extras) must not be mistaken for a wrapper.
      final withExtras = {'id': 'n4', 'title': 'New booking request', 'event': 'booking.new', 'data': {'approveBy': '2026-11-18T05:04:15Z'}};
      expect(LiveEvents.parseNotification(withExtras)!.id, 'n4');
      expect(LiveEvents.parseNotification({'notification': withExtras})!.id, 'n4');
    });

    test('malformed payloads are ignored', () {
      expect(LiveEvents.parseNotification(null), isNull);
      expect(LiveEvents.parseNotification('oops'), isNull);
      expect(LiveEvents.parseNotification({'title': 'no id'}), isNull);
      expect(LiveEvents.parseNotification({'id': 'n3'}), isNull, reason: 'no text to show');
    });
  });
}
