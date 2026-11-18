import 'dart:async';
import 'dart:convert';

import '../../api/json_read.dart';
import '../../api/models/app_notification.dart';

/// `booking:updated {id, status}` from the socket.
class BookingUpdate {
  const BookingUpdate(this.bookingId, this.status);

  /// "Anything may have changed": sent after the socket reconnects, since
  /// events during the outage were missed. Reload whatever is on screen.
  const BookingUpdate.any()
      : bookingId = '*',
        status = null;

  final String bookingId;
  final String? status;

  bool get isAny => bookingId == '*';

  /// True for an update of [id] or a reconnect.
  bool concerns(String id) => isAny || bookingId == id;
}

/// App-wide live events from the socket (`booking:updated`,
/// `notification:new`). Screens listen here instead of touching the socket:
///
/// ```dart
/// _sub = LiveEvents.bookingUpdates.listen((u) { if (u.bookingId == id) reload(); });
/// ```
/// Cancel the subscription in `onClose`/`dispose`.
abstract final class LiveEvents {
  static final _bookings = StreamController<BookingUpdate>.broadcast();
  static final _notifications = StreamController<AppNotification>.broadcast();

  /// Any booking of this user changed (status, actions, late fee…).
  static Stream<BookingUpdate> get bookingUpdates => _bookings.stream;

  /// A new notification arrived.
  static Stream<AppNotification> get notifications => _notifications.stream;

  static void emitBookingUpdate(BookingUpdate u) {
    if (u.bookingId.isNotEmpty) _bookings.add(u);
  }

  static void emitNotification(AppNotification n) => _notifications.add(n);

  /// A chat message arrived (`message-new`), in any conversation.
  static final _chatMessages = StreamController<void>.broadcast();
  static Stream<void> get chatMessages => _chatMessages.stream;
  static void emitChatMessage() => _chatMessages.add(null);

  /// The socket reconnected after a drop: events may have been missed.
  static final _reconnects = StreamController<void>.broadcast();
  static Stream<void> get reconnects => _reconnects.stream;

  static void emitReconnected() {
    _bookings.add(const BookingUpdate.any());
    _reconnects.add(null);
  }

  /// Socket payloads arrive as a map, a JSON string, or wrapped in a list
  /// (some Socket.IO servers send `[payload]`).
  static Json? _payload(dynamic data) {
    var d = data;
    if (d is List && d.isNotEmpty) d = d.first;
    if (d is String) {
      try {
        d = jsonDecode(d);
      } catch (_) {
        return null;
      }
    }
    return readMap(d);
  }

  /// `booking:updated {id, status}` (also accepts `bookingId`, `_id`).
  /// Null for anything without an id.
  static BookingUpdate? parseBookingUpdate(dynamic data) {
    final m = _payload(data);
    if (m == null) return null;
    final id = readString(m['id']) ?? readString(m['bookingId']) ?? readString(m['_id']);
    if (id == null) return null;
    return BookingUpdate(id, readString(m['status']));
  }

  /// `notification:new` payload (the notification object, possibly under
  /// `notification` or `data`). Null without an id or any text.
  ///
  /// A notification's own `data` field holds extras (`approveBy`,
  /// `returnBy`), so `data` is only unwrapped when the payload itself isn't
  /// a notification.
  static AppNotification? parseNotification(dynamic data) {
    var m = _payload(data);
    if (m == null) return null;
    final isNotification = (readText(m['id']) ?? readText(m['_id'])) != null;
    m = readMap(m['notification']) ?? (isNotification ? null : readMap(m['data'])) ?? m;
    final n = AppNotification.fromJson(m);
    if (n.id.isEmpty) return null;
    if (readText(m['title']) == null && readText(m['description']) == null) return null;
    return n;
  }
}
