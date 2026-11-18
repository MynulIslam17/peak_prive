import 'package:intl/intl.dart';

import '../../core/widgets/booking_details_parts.dart' show euro;
import '../../data/api/peak_api.dart';

/// Wording shared by the booking screens. Pure functions, so they're tested.

/// "45 min", "3 h 12 min", "2 d 5 h".
String durationText(int minutes) {
  if (minutes < 1) return 'less than a minute';
  if (minutes < 60) return '$minutes min';
  final days = minutes ~/ (60 * 24);
  final hours = (minutes % (60 * 24)) ~/ 60;
  final mins = minutes % 60;
  if (days > 0) return hours > 0 ? '$days d $hours h' : '$days d';
  return mins > 0 ? '$hours h $mins min' : '$hours h';
}

/// Live banner line for a rental timer, or null when there is none.
String? timerText(BookingTimer? timer, {DateTime? now, bool forProvider = false}) {
  if (timer == null) return null;
  if (timer.hasRunOut(now)) {
    return switch (timer.state) {
      TimerState.startsIn => 'Pick-up due now',
      _ => 'Return due now',
    };
  }
  final m = durationText(timer.minutesNow(now));
  return switch (timer.state) {
    TimerState.startsIn => 'Pick-up in $m',
    TimerState.pickupDue => forProvider
        ? 'Pick-up time passed $m ago. Tap Hand over when the guest collects it.'
        : 'Pick-up time passed $m ago',
    TimerState.returnIn => 'Return in $m',
    // The first 15 minutes are free: say so instead of "€0.00 so far".
    TimerState.overdue => timer.lateFee > 0
        ? 'Late by $m · ${euro(timer.lateFee)} late fee so far'
        : 'Late by $m · late fee starts after 15 min',
  };
}

/// Refund the customer would get if they cancelled now: 100 % while Pending
/// or more than 24 h before the start, else 90 %. The server decides; this is
/// only the preview in the confirm dialog.
({int percent, num amount}) cancelRefundPreview(Booking b, {DateTime? now}) {
  final t = now ?? DateTime.now();
  final start = b.schedule.startAt;
  final full = b.status == BookingStatus.pending ||
      start == null ||
      start.difference(t) > const Duration(hours: 24);
  final percent = full ? 100 : 90;
  final amount = (b.total * percent / 100 * 100).roundToDouble() / 100;
  return (percent: percent, amount: amount);
}

/// One-line "when" for list cards, by service.
String scheduleLine(Booking b) {
  final s = b.schedule;
  final dayFmt = DateFormat('EEE, d MMM yyyy');
  final short = DateFormat('d MMM · h:mm a');
  final day = s.date == null ? null : DateTime.tryParse(s.date!);
  switch (b.kind) {
    case ServiceKind.skiHire:
    case ServiceKind.transport:
      if (s.startAt != null && s.endAt != null) {
        return '${short.format(s.startAt!)} → ${short.format(s.endAt!)}';
      }
    case ServiceKind.massage:
      if (day != null) {
        return [dayFmt.format(day), if (s.time != null) s.time!, if (s.duration != null) s.duration!].join(' · ');
      }
    case ServiceKind.restaurant:
      if (day != null) return [dayFmt.format(day), if (s.slot != null) s.slot!.label].join(' · ');
    case ServiceKind.skiPass:
      if (day != null) return dayFmt.format(day);
  }
  if (s.startAt != null) return DateFormat('EEE, d MMM yyyy · h:mm a').format(s.startAt!);
  return '';
}

/// "2 people", "1 person"; null when unknown.
String? peopleText(int? n, {String one = 'person', String many = 'people'}) =>
    (n == null || n <= 0) ? null : '$n ${n == 1 ? one : many}';

/// Calendar day of a booking for grouping (local), or null.
DateTime? bookingDayOf(Booking b) {
  final d = b.schedule.date == null ? null : DateTime.tryParse(b.schedule.date!);
  if (d != null) return DateTime(d.year, d.month, d.day);
  final s = b.schedule.startAt;
  return s == null ? null : DateTime(s.year, s.month, s.day);
}
