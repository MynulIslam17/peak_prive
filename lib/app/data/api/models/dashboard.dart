import '../json_read.dart';
import 'booking.dart';

/// `GET /dashboard/meta/provider`.
class ProviderDashboard {
  const ProviderDashboard({
    required this.bookings,
    required this.earnings,
    required this.listings,
    required this.today,
    required this.recent,
  });

  factory ProviderDashboard.fromJson(Json json, {DateTime? receivedAt}) {
    final b = readMap(json['bookings']);
    final e = readMap(json['earnings']);
    return ProviderDashboard(
      bookings: BookingCounts(
        total: readInt(b?['total']) ?? 0,
        requests: readInt(b?['requests']) ?? 0,
        upcoming: readInt(b?['upcoming']) ?? 0,
        inProgress: readInt(b?['inProgress']) ?? 0,
        completed: readInt(b?['completed']) ?? 0,
        cancelled: readInt(b?['cancelled']) ?? 0,
      ),
      earnings: Earnings(
        balance: readNum(e?['balance']) ?? 0,
        earned: readNum(e?['earned']) ?? 0,
        platformFees: readNum(e?['platformFees']) ?? 0,
        pending: readNum(e?['pending']) ?? 0,
        lateFeesDue: readNum(e?['lateFeesDue']) ?? 0,
      ),
      listings: readInt(json['listings']) ?? 0,
      today: readList(json['today'], (j) => Booking.fromJson(j, receivedAt: receivedAt)),
      recent: readList(json['recent'], (j) => Booking.fromJson(j, receivedAt: receivedAt)),
    );
  }

  final BookingCounts bookings;
  final Earnings earnings;

  /// Number of listings.
  final int listings;

  /// Bookings running today.
  final List<Booking> today;

  /// Five newest bookings.
  final List<Booking> recent;
}

class BookingCounts {
  const BookingCounts({required this.total, required this.requests, required this.upcoming, required this.inProgress, required this.completed, required this.cancelled});
  final int total;

  /// Waiting for approval (badge).
  final int requests;
  final int upcoming;
  final int inProgress;
  final int completed;
  final int cancelled;
}

class Earnings {
  const Earnings({required this.balance, required this.earned, required this.platformFees, required this.pending, required this.lateFeesDue});

  /// Withdrawable.
  final num balance;
  final num earned;
  final num platformFees;

  /// Open bookings not yet paid out.
  final num pending;
  final num lateFeesDue;
}
