import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/app_colors.dart';
import '../constants/text-style.dart';
import '../../data/api/models/booking.dart';
import '../../data/api/models/service_kind.dart';
import '../utils/resort_time.dart';
import 'shimmer/skeleton.dart';

/// Shared building blocks for the booking screens (every service, both
/// roles). They sit inside
/// [CollapsibleDetailsLayout], so every booking screen gets the same hero
/// image + draggable full-screen sheet + fading app bar as the pass details.

// ───────────────────────────── Formatting ─────────────────────────────

/// "Sat, 23 May 2026" in the user's local time.
String bookingDate(DateTime? date) =>
    date == null ? '—' : DateFormat('EEE, d MMM yyyy').format(date.toLocal());

/// "Sat, 23 May 2026" for a calendar day `YYYY-MM-DD` (no zone shift).
String bookingDay(String? day) {
  final d = day == null ? null : DateTime.tryParse(day);
  return d == null ? '—' : DateFormat('EEE, d MMM yyyy').format(d);
}

/// "08:34 PM" in the user's local time.
String bookingTime(DateTime? date) =>
    date == null ? '—' : DateFormat('hh:mm a').format(date.toLocal());

/// "23 May 2026 · 08:34 PM" in the user's local time (fits on one line).
String bookingDateTime(DateTime? date, {ServiceKind? kind}) => date == null
    ? '—'
    : DateFormat('d MMM yyyy · hh:mm a').format(bookingClock(date, kind));

/// [t] on the clock the booking's own times use: Paris (resort) time for
/// services booked by resort clock time (massage, restaurant, ski pass), so a
/// deadline reads next to "11:00 AM" in the same zone; phone time otherwise
/// (transport and ski hire are picked in phone time).
DateTime bookingClock(DateTime t, ServiceKind? kind) => switch (kind) {
      ServiceKind.massage || ServiceKind.restaurant || ServiceKind.skiPass => resortNow(t),
      _ => t.toLocal(),
    };

/// "€1,250.50"
String euro(num? amount) =>
    NumberFormat.currency(locale: 'en_IE', symbol: '€', decimalDigits: 2)
        .format(amount ?? 0);

/// Short human-friendly reference from a Mongo id: "#A1B2C3".
String bookingRef(String? id) {
  if (id == null || id.isEmpty) return '—';
  return '#${id.substring(id.length > 6 ? id.length - 6 : 0).toUpperCase()}';
}

String _orDash(String? v) => (v == null || v.trim().isEmpty) ? '—' : v.trim();

// ───────────────────────────── Header ─────────────────────────────

/// Title, status chip and a muted subtitle line (category · location).
class BookingDetailsHeader extends StatelessWidget {
  const BookingDetailsHeader({
    super.key,
    required this.title,
    required this.status,
    this.subtitle,
    this.overdue = false,
    this.forProvider = false,
  });

  final String title;
  final BookingStatus status;
  final String? subtitle;

  /// A rental past its return time (`timer.state == overdue`).
  final bool overdue;

  /// Provider wording ("Needs approval" instead of "Awaiting approval").
  final bool forProvider;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BookingStatusChip(status: status, overdue: overdue, forProvider: forProvider),
        const SizedBox(height: 10),
        Text(
          title.isEmpty ? 'Booking' : title,
          style: AppTextStyle.h3_semibold_20(color: AppColors.textPrimary),
        ),
        if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: AppTextStyle.sub_h3_regular_14(color: AppColors.textTertiary),
          ),
        ],
      ],
    );
  }
}

/// Chip for the server's booking `status` (plus "Overdue" for late rentals).
class BookingStatusChip extends StatelessWidget {
  const BookingStatusChip({
    super.key,
    required this.status,
    this.overdue = false,
    this.forProvider = false,
    this.dense = false,
  });

  final BookingStatus status;
  final bool overdue;
  final bool forProvider;

  /// Smaller variant for list cards.
  final bool dense;

  /// Background, foreground, icon and label for a status.
  static (Color, Color, IconData, String) styleFor(
    BookingStatus status, {
    bool overdue = false,
    bool forProvider = false,
  }) {
    if (overdue && status.isOpen) {
      return (const Color(0xFFFDECEC), const Color(0xFFB42318), Icons.timer_off_outlined, 'Overdue');
    }
    return switch (status) {
      // Grey was invisible on the off-white cards; same amber for both sides.
      BookingStatus.pending => (
          const Color(0xFFFFF4E0),
          const Color(0xFFB45309),
          Icons.hourglass_top_rounded,
          forProvider ? 'Needs approval' : 'Awaiting approval'
        ),
      BookingStatus.confirmed => (
          const Color(0xFFFBF3DC),
          const Color(0xFF9A7A12),
          Icons.check_circle_outline_rounded,
          'Confirmed'
        ),
      BookingStatus.inProgress => (
          const Color(0xFFE7F4EC),
          AppColors.success,
          Icons.play_circle_outline_rounded,
          'In progress'
        ),
      BookingStatus.completed => (
          const Color(0xFFE7F4EC),
          AppColors.success,
          Icons.task_alt_rounded,
          'Completed'
        ),
      BookingStatus.cancelled => (
          const Color(0xFFFBEAEA),
          AppColors.error,
          Icons.cancel_outlined,
          'Cancelled'
        ),
      BookingStatus.unknown => (
          AppColors.scaffold,
          AppColors.textTertiary,
          Icons.info_outline_rounded,
          'Unknown'
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon, label) = styleFor(status, overdue: overdue, forProvider: forProvider);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: dense ? 8 : 10, vertical: dense ? 3 : 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!dense) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 5),
          ],
          Text(label,
              style: (dense ? AppTextStyle.c_regular_10(color: fg) : AppTextStyle.p_medium_12(color: fg))
                  .copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ───────────────────────────── Sections ─────────────────────────────

class BookingSectionTitle extends StatelessWidget {
  const BookingSectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 10),
      child: Text(text,
          style: AppTextStyle.sub_h1_medium_18(color: AppColors.textPrimary)),
    );
  }
}

class BookingInfoRow {
  const BookingInfoRow(this.icon, this.label, this.value,
      {this.emphasize = false, this.valueColor});

  final IconData icon;
  final String label;
  final String? value;
  final bool emphasize;
  final Color? valueColor;
}

/// Rounded card of icon · label · value rows separated by thin dividers.
class BookingInfoCard extends StatelessWidget {
  const BookingInfoCard({super.key, required this.rows});

  final List<BookingInfoRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.scaffold,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            if (i > 0)
              const Divider(
                  height: 1, indent: 52, endIndent: 16, color: AppColors.border),
            _InfoRowTile(row: rows[i]),
          ],
        ],
      ),
    );
  }
}

class _InfoRowTile extends StatelessWidget {
  const _InfoRowTile({required this.row});

  final BookingInfoRow row;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(row.icon, size: 16, color: AppColors.primary_1),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(row.label,
                  style:
                      AppTextStyle.p_regular_12(color: AppColors.textTertiary)),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _orDash(row.value),
                textAlign: TextAlign.right,
                style: (row.emphasize
                        ? AppTextStyle.sub_h3_semibold_14()
                        : AppTextStyle.sub_h3_medium_14())
                    .copyWith(color: row.valueColor ?? AppColors.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A booked item (hire equipment, restaurant seat…): photo, name, detail, qty.
class BookingItemTile extends StatelessWidget {
  const BookingItemTile({
    super.key,
    required this.title,
    this.imageUrl,
    this.subtitle,
    this.quantity,
    this.fallbackIcon = Icons.inventory_2_outlined,
  });

  final String title;
  final String? imageUrl;
  final String? subtitle;
  final int? quantity;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      color: AppColors.scaffold,
      alignment: Alignment.center,
      child: Icon(fallbackIcon, color: AppColors.textDisabled, size: 22),
    );

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 48,
              height: 48,
              child: (imageUrl == null || imageUrl!.isEmpty)
                  ? placeholder
                  : CachedNetworkImage(
                      imageUrl: imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => placeholder,
                      errorWidget: (_, __, ___) => placeholder,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_orDash(title),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.sub_h3_semibold_14(
                        color: AppColors.textPrimary)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!,
                      style: AppTextStyle.p_regular_12(
                          color: AppColors.textTertiary)),
                ],
              ],
            ),
          ),
          if (quantity != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFFBF3DC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('×$quantity',
                  style: AppTextStyle.p_medium_12(color: const Color(0xFF9A7A12))
                      .copyWith(fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }
}

/// Small highlighted note inside the sheet (e.g. overtime warning).
class BookingNotice extends StatelessWidget {
  const BookingNotice({
    super.key,
    required this.icon,
    required this.text,
    this.color = AppColors.warning,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: AppTextStyle.p_regular_12(color: AppColors.textSecondary)
                    .copyWith(height: 1.4)),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────── Bottom bar ─────────────────────────────

/// Pinned bar: total paid on the left, optional action on the right.
class BookingTotalBar extends StatelessWidget {
  const BookingTotalBar({
    super.key,
    required this.total,
    this.label = 'Total paid',
    this.actionLabel,
    this.actionIcon,
    this.onAction,
    this.loading = false,
    this.loadingLabel = 'Preparing…',
    this.trailing,
  });

  final String total;
  final String label;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;
  final bool loading;
  final String loadingLabel;

  /// Shown on the right when there is no action button.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: AppTextStyle.p_regular_12(
                              color: AppColors.textTertiary)),
                      const SizedBox(height: 2),
                      Text(total,
                          style: AppTextStyle.h3_semibold_20(
                              color: AppColors.textPrimary)),
                    ],
                  ),
                  if (actionLabel == null && trailing != null) ...[
                    const Spacer(),
                    trailing!,
                  ],
                  if (actionLabel != null) ...[
                    const SizedBox(width: 20),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: loading ? null : onAction,
                          icon: loading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : Icon(actionIcon ?? Icons.arrow_forward_rounded,
                                  size: 20),
                          label: Text(
                            loading ? loadingLabel : actionLabel!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyle.sub_h2_medium_16(
                                color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary_1,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                AppColors.primary_1.withValues(alpha: 0.7),
                            disabledForegroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────── Loading / error ─────────────────────────────

/// Full-screen loading or error state with its own back button, used before
/// the booking has loaded (the collapsible layout needs an image + title).
class BookingDetailsState extends StatelessWidget {
  const BookingDetailsState.loading({super.key, required this.title})
      : message = null,
        onRetry = null;

  const BookingDetailsState.error({
    super.key,
    required this.title,
    required String this.message,
    this.onRetry,
  });

  final String title;
  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    // Loading: the booking page's own shape (photo, sheet, info cards).
    if (message == null) {
      return const DetailsPageSkeleton(booking: true, sections: [SkeletonSection.infoCard, SkeletonSection.infoCard]);
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: AppColors.textPrimary),
        ),
        title: Text(title, style: AppTextStyle.sub_h1_medium_18()),
      ),
      body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFBF3DC),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.receipt_long_outlined,
                          size: 36, color: AppColors.primary_1),
                    ),
                    const SizedBox(height: 16),
                    Text("Couldn't load this booking",
                        textAlign: TextAlign.center,
                        style: AppTextStyle.sub_h2_medium_16(
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    Text(message!,
                        textAlign: TextAlign.center,
                        style: AppTextStyle.p_regular_12(
                            color: AppColors.textTertiary)),
                    if (onRetry != null) ...[
                      const SizedBox(height: 18),
                      ElevatedButton.icon(
                        onPressed: onRetry,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Try again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary_1,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}
