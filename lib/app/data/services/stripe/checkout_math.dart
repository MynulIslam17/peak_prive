/// Pure checkout helpers (no Flutter), unit-tested in test/checkout.
library;

/// Started units the server charges for a ski hire period:
/// `per_day` = started 24 h blocks, `per_hour` = started hours,
/// `per_rental` = 1. Never less than 1.
int rentalUnits(String priceUnit, DateTime start, DateTime end) {
  if (priceUnit == 'per_rental') return 1;
  final minutes = end.difference(start).inMinutes;
  if (minutes <= 0) return 1;
  final block = priceUnit == 'per_hour' ? 60 : 24 * 60;
  return ((minutes + block - 1) ~/ block).clamp(1, 1 << 20);
}

/// Keeps each quantity within `0..max[id]` (missing max = 0) and drops zeros.
Map<String, int> clampQuantities(Map<String, int> wanted, Map<String, int> max) {
  final out = <String, int>{};
  wanted.forEach((id, q) {
    final m = max[id] ?? 0;
    final v = q.clamp(0, m < 0 ? 0 : m);
    if (v > 0) out[id] = v;
  });
  return out;
}

/// Minutes after midnight for "7:00 PM", "07:00 pm", "19:00", "9 AM".
/// Null when unreadable.
int? parseClock(String? text) {
  if (text == null) return null;
  final m = RegExp(r'^\s*(\d{1,2})(?::(\d{2}))?\s*([AaPp][Mm])?\s*$').firstMatch(text);
  if (m == null) return null;
  var h = int.parse(m.group(1)!);
  final min = int.parse(m.group(2) ?? '0');
  final ap = m.group(3)?.toLowerCase();
  if (min > 59) return null;
  if (ap != null) {
    if (h < 1 || h > 12) return null;
    if (ap == 'am' && h == 12) h = 0;
    if (ap == 'pm' && h != 12) h += 12;
  } else if (h > 23) {
    return null;
  }
  return h * 60 + min;
}

/// "7:00 PM" for minutes after midnight (wraps past 24 h).
String formatClock(int minutes) {
  final m = minutes % (24 * 60);
  final h = m ~/ 60, mm = m % 60;
  final h12 = h % 12 == 0 ? 12 : h % 12;
  return '$h12:${mm.toString().padLeft(2, '0')} ${h < 12 ? 'AM' : 'PM'}';
}

/// Start times (minutes after midnight, may exceed 1440 when the place
/// closes after midnight) every [step] minutes, such that a session of
/// [durationMinutes] ends by closing time. On [day] == today, times before
/// [now] (+[leadMinutes]) are left out.
List<int> sessionStartTimes({
  required String? openTime,
  required String? closeTime,
  required int durationMinutes,
  required DateTime day,
  DateTime? now,
  int step = 30,
  int leadMinutes = 30,
}) {
  final open = parseClock(openTime);
  var close = parseClock(closeTime);
  if (open == null || close == null) return const [];
  if (close <= open) close += 24 * 60; // closes after midnight (or 24 h)
  final n = now ?? DateTime.now();
  final isToday = day.year == n.year && day.month == n.month && day.day == n.day;
  final earliest = isToday ? n.hour * 60 + n.minute + leadMinutes : 0;
  final out = <int>[];
  for (var t = open; t + durationMinutes <= close; t += step) {
    if (t >= earliest) out.add(t);
  }
  return out;
}
