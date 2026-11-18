import 'package:intl/intl.dart';

final _whole = NumberFormat('#,##0', 'en');
final _cents = NumberFormat('#,##0.00', 'en');

/// Price labels that match how the backend charges each category.
/// "€1,250" for whole amounts, "€12,681.60" otherwise.
String euroLabel(num v) =>
    '€${v == v.roundToDouble() ? _whole.format(v) : _cents.format(v)}';

/// Lowest positive value, or null when none is set.
num? lowestPrice(Iterable<num?> values) {
  final real = values.whereType<num>().where((v) => v > 0);
  return real.isEmpty ? null : real.reduce((a, b) => a < b ? a : b);
}

/// "from €20 / day" style label; [empty] when no price is set.
String fromPriceLabel(Iterable<num?> values,
    {String suffix = '', String empty = 'No prices'}) {
  final from = lowestPrice(values);
  return from == null ? empty : 'from ${euroLabel(from)}$suffix';
}
