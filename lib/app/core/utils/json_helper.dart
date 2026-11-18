/// Defensive JSON accessors.
///
/// The backend is Mongo/Express based and is inconsistent about types: numbers
/// arrive as strings, optional objects arrive as bare id strings instead of
/// populated documents, and absent fields are omitted rather than sent as null.
/// Every model should read through these helpers so a single unexpected value
/// degrades one field instead of throwing and killing the whole screen.
class JsonHelper {
  static String getString(dynamic value) {
    if (value == null) return "";
    return value.toString();
  }

  /// Returns null for absent/empty values so callers can distinguish
  /// "not provided" from "provided as empty string".
  static String? getStringOrNull(dynamic value) {
    if (value == null) return null;
    final result = value.toString();
    return result.isEmpty ? null : result;
  }

  static int getInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is double) return value.isFinite ? value.toInt() : fallback;
    if (value is bool) return value ? 1 : 0;
    return int.tryParse(value.toString()) ??
        double.tryParse(value.toString())?.toInt() ??
        fallback;
  }

  static double getDouble(dynamic value, {double fallback = 0.0}) {
    if (value == null) return fallback;
    if (value is double) return value.isFinite ? value : fallback;
    if (value is int) return value.toDouble();
    if (value is bool) return value ? 1.0 : 0.0;
    return double.tryParse(value.toString()) ?? fallback;
  }

  static num getNum(dynamic value, {num fallback = 0}) {
    if (value == null) return fallback;
    if (value is num) return value.isFinite ? value : fallback;
    return num.tryParse(value.toString()) ?? fallback;
  }

  static bool getBool(dynamic value, {bool fallback = false}) {
    if (value == null) return fallback;
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalized = value.toString().toLowerCase();
    if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
      return true;
    }
    if (normalized == 'false' || normalized == '0' || normalized == 'no') {
      return false;
    }
    return fallback;
  }

  static Map<String, dynamic>? getMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.cast<String, dynamic>();
    return null;
  }

  /// Use when a non-nullable `fromJson(Map)` has to be called. Converts both
  /// null and the "unpopulated reference arrived as an id string" case into an
  /// empty map, which every defensive model can parse.
  static Map<String, dynamic> getMapOrEmpty(dynamic value) =>
      getMap(value) ?? const <String, dynamic>{};

  static List<dynamic> getList(dynamic value) {
    if (value is List) return value;
    return const <dynamic>[];
  }

  /// Maps a JSON list into models, skipping any element that is not an object
  /// or that fails to parse. A single malformed row can no longer take out the
  /// entire list.
  static List<T> mapList<T>(
    dynamic value,
    T Function(Map<String, dynamic> json) builder,
  ) {
    final result = <T>[];
    for (final element in getList(value)) {
      final map = getMap(element);
      if (map == null) continue;
      try {
        result.add(builder(map));
      } catch (_) {
        // Skip the malformed entry rather than failing the whole response.
      }
    }
    return result;
  }

  /// Maps a JSON list of scalars (commonly strings) defensively.
  static List<String> getStringList(dynamic value) =>
      getList(value).where((e) => e != null).map((e) => e.toString()).toList();

  static DateTime? getDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is num) {
      // Epoch values: treat >1e11 as milliseconds, otherwise seconds.
      final asInt = value.toInt();
      return DateTime.fromMillisecondsSinceEpoch(
        value.abs() > 100000000000 ? asInt : asInt * 1000,
      );
    }
    return DateTime.tryParse(value.toString());
  }

  /// Non-null variant for models whose field is declared non-nullable.
  static DateTime getDateOr(dynamic value, {DateTime? fallback}) =>
      getDate(value) ?? fallback ?? DateTime.fromMillisecondsSinceEpoch(0);

  /// Mongo documents use `_id`, but some endpoints project it as `id`.
  static String getId(dynamic json) {
    final map = getMap(json);
    if (map == null) return getString(json);
    return getStringOrNull(map['_id']) ?? getString(map['id']);
  }

  /// Unwraps the standard `{success, message, data}` envelope. Returns an empty
  /// map when `data` is absent or is not an object.
  static Map<String, dynamic> unwrapData(dynamic body) =>
      getMapOrEmpty(getMapOrEmpty(body)['data']);
}
