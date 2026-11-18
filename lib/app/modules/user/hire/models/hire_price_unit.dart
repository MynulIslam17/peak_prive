/// How a ski hire item's `price` is charged (`priceUnit`).
///
/// Mirrors the server: total = Σ(price × quantity) × rental units, where
/// started units round up (1 day 2 h = 2 days for [perDay]).
enum HirePriceUnit {
  perDay('per_day', 'day', 'days'),
  perHour('per_hour', 'hour', 'hours'),
  perRental('per_rental', 'rental', 'rental');

  const HirePriceUnit(this.apiValue, this.singular, this.plural);

  final String apiValue;
  final String singular;
  final String plural;

  /// Missing/unknown values are treated as per day, like the server.
  static HirePriceUnit parse(dynamic raw) => values.firstWhere(
        (u) => u.apiValue == raw?.toString(),
        orElse: () => perDay,
      );

  /// "/ day", "/ hour", "per rental".
  String get suffix => this == perRental ? 'per rental' : '/ $singular';

  /// Units charged for a rental from [start] to [end] (at least 1).
  int unitsFor(DateTime start, DateTime end) {
    final minutes = end.difference(start).inMinutes;
    if (minutes <= 0) return 1;
    return switch (this) {
      perDay => (minutes / (24 * 60)).ceil(),
      perHour => (minutes / 60).ceil(),
      perRental => 1,
    };
  }

  /// "3 days", "1 hour", "whole rental".
  String label(int units) =>
      this == perRental ? 'whole rental' : '$units ${units == 1 ? singular : plural}';
}
