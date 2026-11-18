/// The resorts are in the French Alps: session times, opening hours and
/// "today" are Paris wall-clock time, whatever the phone's time zone is.
///
/// Returns the current Paris time as a plain (zone-less) [DateTime] whose
/// fields are the Paris clock, to compare with resort times like "10:30 AM".
/// Paris is UTC+1, and UTC+2 from the last Sunday of March 01:00 UTC to the
/// last Sunday of October 01:00 UTC (EU summer time).
DateTime resortNow([DateTime? now]) {
  final u = (now ?? DateTime.now()).toUtc();
  final p = u.add(Duration(hours: _isSummerTime(u) ? 2 : 1));
  return DateTime(p.year, p.month, p.day, p.hour, p.minute, p.second);
}

/// Today's date at the resort (time fields zero).
DateTime resortToday([DateTime? now]) {
  final n = resortNow(now);
  return DateTime(n.year, n.month, n.day);
}

bool _isSummerTime(DateTime utc) {
  final start = _lastSunday(utc.year, 3);
  final end = _lastSunday(utc.year, 10);
  return !utc.isBefore(start) && utc.isBefore(end);
}

/// 01:00 UTC on the last Sunday of [month].
DateTime _lastSunday(int year, int month) {
  final last = DateTime.utc(year, month + 1, 0, 1);
  return last.subtract(Duration(days: last.weekday % 7));
}
