import '../json_read.dart';

/// `GET /notifications` item.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.description,
    required this.isRead,
    this.type,
    this.event,
    this.bookingId,
    this.createdAt,
    this.canReview = false,
  });

  factory AppNotification.fromJson(Json json) => AppNotification(
        id: readId(json),
        title: readText(json['title']) ?? 'Notification',
        description: localizeTimestamps(readText(json['description']) ?? ''),
        type: readText(json['type']),
        event: readText(json['event']),
        bookingId: readText(json['bookingId']),
        isRead: readBool(json['isRead']) ?? false,
        createdAt: readDate(json['createdAt']),
        canReview: readBool(readMap(json['data'])?['canReview']) ?? false,
      );

  final String id;
  final String title;
  final String description;

  /// e.g. `booking`, `payment`.
  final String? type;

  /// e.g. `booking.approved`, `booking.late_fee_due`, `withdraw.paid`.
  final String? event;

  /// Opens `GET /booking/:bookingId` when set.
  final String? bookingId;
  final bool isRead;
  final DateTime? createdAt;

  /// `data.canReview` on `booking.completed`: the customer can still review
  /// this listing, so the notification offers a "Leave a review" button.
  final bool canReview;

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        title: title,
        description: description,
        type: type,
        event: event,
        bookingId: bookingId,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
        canReview: canReview,
      );
}


final _isoInstant = RegExp(r'\d{4}-\d{2}-\d{2}T\d{2}:\d{2}(?::\d{2}(?:\.\d+)?)?(?:Z|[+-]\d{2}:?\d{2})');
const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

/// Replaces ISO instants the server puts in text ("return it by
/// 2026-11-16T09:45:00.000Z") with local time: "16 Nov, 3:45 PM".
String localizeTimestamps(String text) => text.replaceAllMapped(_isoInstant, (m) {
      final d = DateTime.tryParse(m[0]!)?.toLocal();
      if (d == null) return m[0]!;
      final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
      final min = d.minute.toString().padLeft(2, '0');
      return '${d.day} ${_months[d.month - 1]}, $h:$min ${d.hour < 12 ? 'AM' : 'PM'}';
    });
