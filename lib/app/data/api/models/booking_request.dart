import '../json_read.dart';
import 'service_kind.dart';

/// `bookingItems[]`: `{itemId, quantity}` (hire items or restaurant seat types).
class ItemQuantity {
  const ItemQuantity(this.itemId, this.quantity);
  final String itemId;
  final int quantity;

  Json toJson() => {'itemId': itemId, 'quantity': quantity};
}

/// Body of `POST /booking/intent` (and `/booking/create`).
///
/// Use the named constructor for the service; each sends only the fields the
/// guide lists for it.
class BookingRequest {
  BookingRequest._(this.kind, this.productId, this._fields);

  factory BookingRequest.skiPass({
    required String productId,
    required DateTime day,
    int persons = 1,
    String? phoneNumber,
    String? address,
  }) =>
      BookingRequest._(ServiceKind.skiPass, productId, {
        'date': formatDay(day),
        'personCount': persons,
        ..._contact(phoneNumber, address),
      });

  factory BookingRequest.massage({
    required String productId,
    required DateTime day,
    required String time,
    required String duration,
    int persons = 1,
    String? phoneNumber,
    String? address,
  }) =>
      BookingRequest._(ServiceKind.massage, productId, {
        'date': formatDay(day),
        'time': time,
        'duration': duration,
        'personCount': persons,
        ..._contact(phoneNumber, address),
      });

  factory BookingRequest.restaurant({
    required String productId,
    required DateTime day,
    required String slotId,
    required List<ItemQuantity> seats,
    String? phoneNumber,
    String? address,
  }) =>
      BookingRequest._(ServiceKind.restaurant, productId, {
        'date': formatDay(day),
        'slotId': slotId,
        'bookingItems': [
          for (final s in seats)
            if (s.quantity > 0) s.toJson(),
        ],
        ..._contact(phoneNumber, address),
      });

  factory BookingRequest.skiHire({
    required String productId,
    required DateTime start,
    required DateTime end,
    required List<ItemQuantity> items,
    String? phoneNumber,
    String? address,
  }) =>
      BookingRequest._(ServiceKind.skiHire, productId, {
        'startDateAndTime': formatInstant(start),
        'endDateAndTime': formatInstant(end),
        'bookingItems': [
          for (final i in items)
            if (i.quantity > 0) i.toJson(),
        ],
        ..._contact(phoneNumber, address),
      });

  factory BookingRequest.transport({
    required String productId,
    required DateTime start,
    required DateTime end,
    int passengers = 1,
    String? phoneNumber,
    String? pickupAddress,
    String? destination,
  }) =>
      BookingRequest._(ServiceKind.transport, productId, {
        'startDateAndTime': formatInstant(start),
        'endDateAndTime': formatInstant(end),
        'personCount': passengers,
        ..._contact(phoneNumber, pickupAddress),
        if (_clean(destination) != null) 'destination': _clean(destination),
      });

  final ServiceKind kind;
  final String productId;
  final Json _fields;

  Json toJson() => {'productId': productId, ..._fields};

  /// `/booking/create` body: the same fields plus the paid intent.
  Json toCreateJson(String paymentIntentId) => {'paymentIntentId': paymentIntentId, ...toJson()};

  /// Client-side checks before calling the server (the server checks again).
  /// Returns a message for the user, or null when it looks valid.
  String? validate({DateTime? now}) {
    final t = now ?? DateTime.now();
    final items = _fields['bookingItems'];
    if ((kind == ServiceKind.skiHire || kind == ServiceKind.restaurant) &&
        (items is! List || items.isEmpty)) {
      return kind == ServiceKind.skiHire ? 'Choose at least one item.' : 'Choose at least one seat.';
    }
    if (kind.isRental) {
      final s = DateTime.tryParse(_fields['startDateAndTime'] as String);
      final e = DateTime.tryParse(_fields['endDateAndTime'] as String);
      if (s == null || e == null) return 'Choose the pick-up and return times.';
      if (!e.isAfter(s)) return 'The return time must be after the pick-up time.';
      if (s.isBefore(t.subtract(const Duration(minutes: 1)))) return 'The pick-up time is in the past.';
    } else {
      final day = DateTime.tryParse(_fields['date'] as String);
      final today = DateTime(t.year, t.month, t.day);
      if (day == null) return 'Choose a date.';
      if (day.isBefore(today)) return 'The date is in the past.';
    }
    final persons = _fields['personCount'];
    if (persons is int && persons < 1) return 'At least one person is needed.';
    if (kind == ServiceKind.massage) {
      if ((_fields['time'] as String).isEmpty) return 'Choose a time.';
      if ((_fields['duration'] as String).isEmpty) return 'Choose a duration.';
    }
    if (kind == ServiceKind.restaurant && (_fields['slotId'] as String).isEmpty) {
      return 'Choose a time slot.';
    }
    return null;
  }

  static Json _contact(String? phone, String? address) => {
        if (_clean(phone) != null) 'phoneNumber': _clean(phone),
        if (_clean(address) != null) 'address': _clean(address),
      };

  static String? _clean(String? v) {
    final t = v?.trim();
    return (t == null || t.isEmpty) ? null : t;
  }
}

/// `YYYY-MM-DD` of the given calendar day (no time zone conversion).
String formatDay(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${_pad2(d.month)}-${_pad2(d.day)}';

/// ISO 8601 with the device's offset, e.g. `2026-12-20T09:00:00+01:00`.
/// The server rejects date-times without a zone.
String formatInstant(DateTime d) {
  if (d.isUtc) {
    return '${formatDay(d)}T${_pad2(d.hour)}:${_pad2(d.minute)}:${_pad2(d.second)}Z';
  }
  final off = d.timeZoneOffset;
  final sign = off.isNegative ? '-' : '+';
  final a = off.abs();
  return '${formatDay(d)}T${_pad2(d.hour)}:${_pad2(d.minute)}:${_pad2(d.second)}'
      '$sign${_pad2(a.inHours)}:${_pad2(a.inMinutes % 60)}';
}

String _pad2(int v) => v.toString().padLeft(2, '0');

/// `/booking/intent` and `/booking/:id/late-fee/intent` response.
class PaymentIntentData {
  const PaymentIntentData({
    required this.paymentIntentId,
    required this.clientSecret,
    required this.publishableKey,
    required this.amount,
    required this.currency,
    this.kind,
    this.breakdown,
  });

  factory PaymentIntentData.fromJson(Json json) => PaymentIntentData(
        paymentIntentId: readString(json['paymentIntentId']) ?? '',
        clientSecret: readString(json['clientSecret']) ?? '',
        publishableKey: readString(json['publishableKey']) ?? '',
        amount: readNum(json['amount']) ?? 0,
        currency: readString(json['currency']) ?? 'eur',
        kind: ServiceKind.parse(json['category']),
        breakdown: PriceBreakdown.maybe(json['breakdown']),
      );

  final String paymentIntentId;
  final String clientSecret;
  final String publishableKey;
  final num amount;
  final String currency;
  final ServiceKind? kind;
  final PriceBreakdown? breakdown;

  /// Usable for the Stripe sheet.
  bool get isComplete => paymentIntentId.isNotEmpty && clientSecret.isNotEmpty;
}

/// `breakdown: {items: [{itemId, name, quantity, price}], priceUnit, units}`.
class PriceBreakdown {
  const PriceBreakdown({required this.items, this.priceUnit, this.units});

  static PriceBreakdown? maybe(dynamic json) {
    final m = readMap(json);
    if (m == null) return null;
    return PriceBreakdown(
      items: readList(
        m['items'],
        (e) => BreakdownLine(
          itemId: readString(e['itemId']) ?? '',
          name: readText(e['name']) ?? 'Item',
          quantity: readInt(e['quantity']) ?? 1,
          price: readNum(e['price']) ?? 0,
        ),
      ),
      priceUnit: readString(m['priceUnit']),
      units: readNum(m['units']),
    );
  }

  final List<BreakdownLine> items;
  final String? priceUnit;

  /// Days/hours charged (1 for per_rental).
  final num? units;
}

class BreakdownLine {
  const BreakdownLine({required this.itemId, required this.name, required this.quantity, required this.price});
  final String itemId;
  final String name;
  final int quantity;
  final num price;
}
