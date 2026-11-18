/// Tolerant readers for API JSON.
///
/// The server is the source of truth, but old records still carry odd shapes
/// (numbers as strings, `"N/A"` phones, missing objects). Every model reads
/// through these helpers so a single bad field never crashes a screen.
library;

typedef Json = Map<String, dynamic>;

Json? readMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.map((k, v) => MapEntry(k.toString(), v));
  return null;
}

/// Trimmed string, or null when missing/blank. Numbers are stringified.
String? readString(dynamic value) {
  if (value == null) return null;
  if (value is String) {
    final t = value.trim();
    return t.isEmpty ? null : t;
  }
  if (value is num || value is bool) return value.toString();
  return null;
}

/// Like [readString] but also drops placeholder values such as `"N/A"`.
String? readText(dynamic value) {
  final s = readString(value);
  if (s == null) return null;
  const placeholders = {'n/a', 'na', 'null', 'undefined', 'none', '-'};
  return placeholders.contains(s.toLowerCase()) ? null : s;
}

num? readNum(dynamic value) {
  if (value is num) return value.isFinite ? value : null;
  if (value is String) {
    final n = num.tryParse(value.trim());
    return (n != null && n.isFinite) ? n : null;
  }
  return null;
}

int? readInt(dynamic value) {
  final n = readNum(value);
  return n?.round();
}

double? readDouble(dynamic value) => readNum(value)?.toDouble();

bool? readBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    switch (value.trim().toLowerCase()) {
      case 'true':
      case '1':
      case 'yes':
        return true;
      case 'false':
      case '0':
      case 'no':
        return false;
    }
  }
  return null;
}

/// Instant from an ISO string, converted to the device's local time.
DateTime? readDate(dynamic value) {
  final s = readString(value);
  if (s == null) return null;
  return DateTime.tryParse(s)?.toLocal();
}

/// Maps every map element of [value] with [parse]; skips anything else and
/// any element whose parse throws.
List<T> readList<T>(dynamic value, T Function(Json json) parse) {
  if (value is! List) return const [];
  final out = <T>[];
  for (final e in value) {
    final m = readMap(e);
    if (m == null) continue;
    try {
      out.add(parse(m));
    } catch (_) {
      // One malformed element must not hide the rest of the list.
    }
  }
  return List.unmodifiable(out);
}

List<String> readStringList(dynamic value) {
  if (value is! List) return const [];
  return List.unmodifiable(value.map(readString).whereType<String>());
}

/// `id`, falling back to Mongo's `_id`.
String readId(Json json) =>
    readString(json['id']) ?? readString(json['_id']) ?? '';
