import '../json_read.dart';

/// Ski hire: `{items: [{itemId, name, price, quantity, available}]}`.
class ItemAvailability {
  const ItemAvailability({
    required this.itemId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.available,
  });

  factory ItemAvailability.fromJson(Json json) => ItemAvailability(
        itemId: readString(json['itemId']) ?? readId(json),
        name: readText(json['name']) ?? 'Item',
        price: readNum(json['price']) ?? 0,
        quantity: readInt(json['quantity']) ?? 0,
        available: (readInt(json['available']) ?? 0).clamp(0, 1 << 30),
      );

  final String itemId;
  final String name;
  final num price;
  final int quantity;

  /// Free units for the requested period.
  final int available;
}

/// Restaurant seat type free in one slot: `{itemId, type, price, available}`.
class SeatAvailability {
  const SeatAvailability({required this.itemId, required this.type, required this.price, required this.available});

  factory SeatAvailability.fromJson(Json json) => SeatAvailability(
        itemId: readString(json['itemId']) ?? readId(json),
        type: readText(json['type']) ?? 'Normal',
        price: readNum(json['price']) ?? 0,
        available: (readInt(json['available']) ?? 0).clamp(0, 1 << 30),
      );

  final String itemId;
  final String type;
  final num price;
  final int available;
}

/// Restaurant slot on a date: `{slotId, startTime, endTime, isPast, seats}`.
class SlotAvailability {
  const SlotAvailability({
    required this.slotId,
    required this.startTime,
    required this.endTime,
    required this.isPast,
    required this.seats,
  });

  factory SlotAvailability.fromJson(Json json) => SlotAvailability(
        slotId: readString(json['slotId']) ?? readId(json),
        startTime: readText(json['startTime']) ?? '',
        endTime: readText(json['endTime']) ?? '',
        isPast: readBool(json['isPast']) ?? false,
        seats: readList(json['seats'], SeatAvailability.fromJson),
      );

  final String slotId;
  final String startTime;
  final String endTime;
  final bool isPast;
  final List<SeatAvailability> seats;

  String get label => '$startTime – $endTime';

  int get freeSeats => seats.fold(0, (s, e) => s + e.available);

  /// Bookable: not past and at least one seat free.
  bool get isBookable => !isPast && freeSeats > 0;

  SeatAvailability? seat(String itemId) {
    for (final s in seats) {
      if (s.itemId == itemId) return s;
    }
    return null;
  }
}

/// Massage start time on a day:
/// `{time: '11:00 AM', startAt, endAt, left, available, isPast}`.
class SessionSlot {
  const SessionSlot({required this.time, required this.left, required this.available, required this.isPast});

  factory SessionSlot.fromJson(Json json) => SessionSlot(
        time: readText(json['time']) ?? '',
        left: readInt(json['left']) ?? 0,
        available: readBool(json['available']) ?? false,
        isPast: readBool(json['isPast']) ?? false,
      );

  final String time;

  /// Guests that can still book this time.
  final int left;
  final bool available;
  final bool isPast;
}

/// `GET /booking/availability/:listingId`.
class Availability {
  const Availability({
    this.available,
    this.reason,
    this.items = const [],
    this.slots = const [],
    this.sessions = const [],
    this.capacity,
  });

  factory Availability.fromJson(Json json) {
    final raw = json['slots'];
    // Massage slots carry `time`; restaurant slots carry `startTime`.
    final massage = raw is List && raw.isNotEmpty && raw.first is Map && (raw.first as Map).containsKey('time');
    return Availability(
      available: readBool(json['available']),
      reason: readText(json['reason']),
      items: readList(json['items'], ItemAvailability.fromJson),
      slots: massage ? const [] : readList(raw, SlotAvailability.fromJson),
      sessions: massage ? readList(raw, SessionSlot.fromJson) : const [],
      capacity: readInt(json['capacity']),
    );
  }

  /// Massage: every start time of the day.
  final List<SessionSlot> sessions;

  /// Massage: guests at the same time.
  final int? capacity;

  /// Transport / ski pass / massage.
  final bool? available;

  /// Why it isn't available, e.g. `not_returned` (the previous customer
  /// still has the vehicle).
  final String? reason;

  bool get notReturned => reason == 'not_returned';

  /// Ski hire.
  final List<ItemAvailability> items;

  /// Restaurant.
  final List<SlotAvailability> slots;

  int availableFor(String itemId) {
    for (final i in items) {
      if (i.itemId == itemId) return i.available;
    }
    return 0;
  }
}
