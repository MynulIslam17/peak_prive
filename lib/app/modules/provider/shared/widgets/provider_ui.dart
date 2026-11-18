import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text-style.dart';
import '../../../../core/utils/price_label.dart';
import '../../../../core/widgets/booking_details_parts.dart';
import '../../../../core/widgets/custom_image_container.dart';
import '../../../../routes/app_routes.dart';
import '../../../../data/api/peak_api.dart';

// ════════════════════════════════════════════════════════════════════════
//  Shared building blocks for the provider screens. They follow the same
//  look as the customer side: cream background, white cards with a soft
//  border, gold accents, pill status chips.
// ════════════════════════════════════════════════════════════════════════

/// "Ski_Hire" → "Ski Hire".
String providerTypeLabel(String? type) =>
    (type ?? '').replaceAll('_', ' ').trim();

String _euro(num v) => euroLabel(v);

// ─────────────────────────── Booking status ───────────────────────────

/// Chip text and colours for a booking, from the provider's side.
/// Rentals past their return time show "Overdue".
class ProviderStatusStyle {
  const ProviderStatusStyle(this.label, this.background, this.foreground);

  final String label;
  final Color background;
  final Color foreground;

  static const _amber = (Color(0xFFFFF4E0), Color(0xFFB45309));
  static const _gold = (Color(0xFFFBF3DC), Color(0xFF9A7A12));
  static const _green = (Color(0xFFE7F4EC), AppColors.success);
  static const _red = (Color(0xFFFBEAEA), AppColors.error);
  static const _grey = (Color(0xFFF1F1F1), AppColors.textSecondary);

  factory ProviderStatusStyle.of(Booking b) {
    if (b.isOverdue && b.status.isOpen) return _make('Overdue', _red);
    return switch (b.status) {
      BookingStatus.pending => _make('Needs approval', _amber),
      BookingStatus.confirmed => _make('Confirmed', _gold),
      BookingStatus.inProgress =>
        _make(b.kind.isRental ? 'Handed over' : 'In progress', _green),
      BookingStatus.completed =>
        _make(b.noShow ? 'No-show' : 'Completed', b.noShow ? _grey : _green),
      BookingStatus.cancelled => _make('Cancelled', _red),
      BookingStatus.unknown => _make('Unknown', _grey),
    };
  }

  static ProviderStatusStyle _make(String l, (Color, Color) c) =>
      ProviderStatusStyle(l, c.$1, c.$2);
}

class ProviderStatusChip extends StatelessWidget {
  const ProviderStatusChip(this.style, {super.key});

  final ProviderStatusStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        style.label,
        style: AppTextStyle.c_regular_10(color: style.foreground)
            .copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ─────────────────────────── Booking card text ───────────────────────────

/// Card lines for a booking, the same for every provider type
/// (the service comes from each booking's `category`).
abstract final class ProviderBookingText {
  static final _day = DateFormat('d MMM');
  static final _dayTime = DateFormat('d MMM · h:mm a');

  /// "Guest" when the customer has no usable name.
  static String customerName(Booking b) => b.customer?.name ?? 'Guest';

  /// When: rentals start → end, massage day + time, restaurant day + slot,
  /// ski pass day.
  static String schedule(Booking b) {
    final s = b.schedule;
    // The resort day, like the time text next to it. `startAt` is in the
    // device's zone and can fall on another day (9:15 PM Paris = 2:15 AM
    // the next day in Dhaka).
    DateTime? day = s.date == null ? null : DateTime.tryParse(s.date!);
    day ??= s.startAt;
    switch (b.kind) {
      case ServiceKind.skiHire:
      case ServiceKind.transport:
        if (s.startAt == null) return '';
        if (s.endAt == null) return _dayTime.format(s.startAt!);
        return '${_dayTime.format(s.startAt!)} → ${_dayTime.format(s.endAt!)}';
      case ServiceKind.massage:
        return [
          if (day != null) _day.format(day),
          if (s.time != null) s.time!,
        ].join(' · ');
      case ServiceKind.restaurant:
        return [
          if (day != null) _day.format(day),
          if (s.slot != null) s.slot!.label,
        ].join(' · ');
      case ServiceKind.skiPass:
        return day == null ? '' : _day.format(day);
    }
  }

  /// What: items, seats, duration, persons/passengers.
  static String detail(Booking b) {
    String plural(int n, String one, String many) => '$n ${n == 1 ? one : many}';
    final people = b.people ?? 0;
    switch (b.kind) {
      case ServiceKind.skiHire:
        return b.items.map((i) => '${i.quantity} × ${i.name}').join(', ');
      case ServiceKind.transport:
        return people > 0 ? plural(people, 'passenger', 'passengers') : '';
      case ServiceKind.massage:
        return [
          if (b.schedule.duration != null) b.schedule.duration!,
          if (people > 1) plural(people, 'person', 'people'),
        ].join(' · ');
      case ServiceKind.restaurant:
        return b.items
            .map((i) => '${plural(i.quantity, 'seat', 'seats')} · ${i.name}')
            .join(', ');
      case ServiceKind.skiPass:
        return people > 0 ? plural(people, 'guest', 'guests') : '';
    }
  }

  /// Extra line: approval deadline, overdue fee, return countdown.
  static String? notice(Booking b, {DateTime? now}) {
    if (b.status == BookingStatus.pending && b.approvalDeadline != null) {
      return 'Respond by ${_dayTime.format(bookingClock(b.approvalDeadline!, b.kind))}';
    }
    final t = b.timer;
    if (t == null || !b.status.isOpen) return null;
    final m = t.minutesNow(now);
    return switch (t.state) {
      TimerState.overdue => 'Late by ${duration(m)}'
          '${t.lateFee > 0 ? ' · ${_euro(t.lateFee)} so far' : ''}',
      TimerState.pickupDue => 'Pick-up was due ${duration(m)} ago',
      TimerState.returnIn => 'Return in ${duration(m)}',
      TimerState.startsIn => null,
    };
  }

  /// 75 → "1 h 15 min", 3000 → "2 d 2 h".
  static String duration(int minutes) {
    if (minutes < 60) return '$minutes min';
    final d = minutes ~/ 1440, h = (minutes % 1440) ~/ 60, m = minutes % 60;
    if (d > 0) return h > 0 ? '$d d $h h' : '$d d';
    return m > 0 ? '$h h $m min' : '$h h';
  }
}

/// Opens the shared booking screen (all actions live there).
Future<dynamic>? openProviderBooking(Booking b) => Get.toNamed(
      Routes.bookingDetails,
      arguments: {'bookingId': b.id, 'booking': b},
    );

// ─────────────────────────── Booking card ───────────────────────────

class ProviderBookingTile extends StatelessWidget {
  const ProviderBookingTile({
    super.key,
    required this.booking,
    this.onTap,
    this.onAccept,
    this.onReject,
    this.busy = false,
  });

  final Booking booking;

  /// Defaults to opening the booking details.
  final VoidCallback? onTap;

  /// Quick actions; shown only when the booking allows them.
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final b = booking;
    final tap = onTap ?? () => openProviderBooking(b);
    final needsAction = b.status == BookingStatus.pending;
    final style = ProviderStatusStyle.of(b);
    final schedule = ProviderBookingText.schedule(b);
    final detail = ProviderBookingText.detail(b);
    final notice = ProviderBookingText.notice(b);
    // Quick Accept/Reject on requests only. A confirmed booking's next step
    // (hand over, return…) is on the detail screen; a lone "Reject" here
    // would make the refund the most prominent action.
    final canAccept = needsAction && onAccept != null && b.can(BookingAction.approve);
    final canReject = needsAction && onReject != null && b.can(BookingAction.reject);

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: tap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: needsAction ? const Color(0xFFF5D9A8) : AppColors.border,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomCachedImage(
                    imageUrl: b.listing.thumbnail ?? '',
                    width: 72,
                    height: 72,
                    borderRadius: 12,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                b.listing.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyle.sub_h3_semibold_14(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ProviderStatusChip(style),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            ProviderAvatar(url: b.customer?.photo ?? '', size: 18),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                ProviderBookingText.customerName(b),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyle.p_medium_12(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (schedule.isNotEmpty)
                          _MetaRow(Icons.calendar_today_rounded, schedule),
                        if (detail.isNotEmpty)
                          _MetaRow(
                              // Items for rentals and tables; people otherwise.
                              b.kind == ServiceKind.skiHire || b.kind == ServiceKind.restaurant
                                  ? Icons.inventory_2_outlined
                                  : Icons.people_outline_rounded,
                              detail),
                        if (notice != null)
                          _MetaRow(
                            Icons.schedule_rounded,
                            notice,
                            color: b.isOverdue || needsAction
                                ? const Color(0xFFB45309)
                                : null,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(height: 1, color: AppColors.border),
              ),
              Row(
                children: [
                  Text(
                    'Total ',
                    style: AppTextStyle.p_regular_12(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _euro(b.total),
                        style: AppTextStyle.sub_h2_medium_16(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (busy)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary_1,
                      ),
                    )
                  else if (canAccept || canReject) ...[
                    if (canReject)
                      ProviderPillButton(label: 'Reject', onTap: onReject!),
                    if (canReject && canAccept) const SizedBox(width: 8),
                    if (canAccept)
                      ProviderPillButton(
                        label: 'Accept',
                        icon: Icons.check_rounded,
                        filled: true,
                        onTap: onAccept!,
                      ),
                  ] else
                    ProviderPillButton(
                      label: needsAction ? 'Review request' : 'View details',
                      icon: Icons.arrow_forward_rounded,
                      filled: needsAction,
                      onTap: tap,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow(this.icon, this.text, {this.color});

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 13, color: color ?? AppColors.textTertiary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.p_regular_12(
                color: color ?? AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small rounded action button (gold when [filled], soft gold otherwise).
class ProviderPillButton extends StatelessWidget {
  const ProviderPillButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.filled = false,
  });

  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final fg = filled ? AppColors.textOnPrimary : const Color(0xFF9A7A12);
    return Material(
      color: filled ? AppColors.primary_1 : const Color(0xFFFBF3DC),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTextStyle.p_medium_12(color: fg)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              if (icon != null) ...[
                const SizedBox(width: 4),
                Icon(icon, size: 15, color: fg),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────── Section header ───────────────────────────

class ProviderSectionHeader extends StatelessWidget {
  const ProviderSectionHeader({
    super.key,
    required this.title,
    this.count,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final int? count;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: AppTextStyle.sub_h1_medium_18()),
        if (count != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFFBF3DC),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: AppTextStyle.p_medium_12(color: const Color(0xFF9A7A12)),
            ),
          ),
        ],
        const Spacer(),
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF9A7A12),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 36),
            ),
            child: Text(
              actionLabel!,
              style: AppTextStyle.sub_h3_medium_14(
                color: const Color(0xFF9A7A12),
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────── Stat card ───────────────────────────

class ProviderStatCard extends StatelessWidget {
  const ProviderStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool highlight;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fg = highlight ? AppColors.textOnPrimary : AppColors.textPrimary;
    return Material(
      color: highlight ? AppColors.primary_1 : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: highlight ? AppColors.primary_1 : AppColors.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: highlight
                      ? Colors.white.withValues(alpha: 0.3)
                      : const Color(0xFFFBF3DC),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  icon,
                  size: 17,
                  color: highlight ? fg : const Color(0xFF9A7A12),
                ),
              ),
              const SizedBox(height: 10),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  maxLines: 1,
                  style: AppTextStyle.h3_semibold_20(color: fg),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.p_regular_12(
                  color: highlight
                      ? fg.withValues(alpha: 0.8)
                      : AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────── Empty / error state ───────────────────────────

class ProviderEmptyState extends StatelessWidget {
  const ProviderEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: Color(0xFFFBF3DC),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF9A7A12), size: 26),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyle.sub_h3_semibold_14(),
          ),
          if (message != null) ...[
            const SizedBox(height: 4),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: AppTextStyle.p_regular_12(color: AppColors.textTertiary),
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 14),
            ProviderPillButton(
              label: actionLabel!,
              onTap: onAction!,
              filled: true,
            ),
          ],
        ],
      ),
    );
  }
}

/// Round photo with a person icon while loading or when it fails.
class ProviderAvatar extends StatelessWidget {
  const ProviderAvatar({super.key, required this.url, this.size = 40});

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final hasUrl = url.trim().startsWith('http');
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: const Color(0xFFFBF3DC),
      foregroundImage: hasUrl ? CachedNetworkImageProvider(url) : null,
      onForegroundImageError: hasUrl ? (_, __) {} : null,
      child: Icon(
        Icons.person_rounded,
        size: size * 0.7,
        color: const Color(0xFF9A7A12),
      ),
    );
  }
}
