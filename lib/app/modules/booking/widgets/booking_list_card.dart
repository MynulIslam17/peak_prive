import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/text-style.dart';
import '../../../core/widgets/booking_details_parts.dart';
import '../../../core/widgets/custom_image_container.dart';
import '../../../data/api/peak_api.dart';
import '../booking_text.dart';

/// Booking card for lists (My bookings, itinerary).
class BookingListCard extends StatelessWidget {
  const BookingListCard({
    super.key,
    required this.booking,
    required this.onTap,
    this.onReview,
    this.forProvider = false,
    this.showKind = false,
  });

  final Booking booking;
  final VoidCallback onTap;

  /// Shown as "Rate & review" when set.
  final VoidCallback? onReview;
  final bool forProvider;

  /// Prefix the service name (lists mixing services).
  final bool showKind;

  @override
  Widget build(BuildContext context) {
    final b = booking;
    final when = scheduleLine(b);
    final people = b.kind == ServiceKind.transport
        ? peopleText(b.people, one: 'passenger', many: 'passengers')
        : peopleText(b.people);
    final items = b.items.isEmpty ? null : b.items.map((i) => '${i.quantity}× ${i.name}').join(', ');
    final lateDue = b.lateFee?.isDue == true;

    return Material(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: lateDue ? AppColors.error.withValues(alpha: 0.4) : AppColors.border),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomCachedImage(imageUrl: b.listing.thumbnail ?? '', width: 76.w, height: 76.w, borderRadius: 12.r),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                showKind ? '${b.kind.label} · ${b.listing.title}' : b.listing.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyle.sub_h3_semibold_14(color: AppColors.textPrimary),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            BookingStatusChip(status: b.status, overdue: b.isOverdue, forProvider: forProvider, dense: true),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        if (when.isNotEmpty) _MetaRow(Icons.calendar_today_rounded, when),
                        if (b.listing.serviceArea != null) _MetaRow(Icons.location_on_outlined, b.listing.serviceArea!),
                        if (people != null) _MetaRow(Icons.people_outline_rounded, people),
                        if (items != null) _MetaRow(Icons.inventory_2_outlined, items),
                        if (lateDue) _MetaRow(Icons.more_time_rounded, 'Late fee due: ${euro(b.lateFee!.amount)}', color: AppColors.error),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                child: const Divider(height: 1, color: AppColors.border),
              ),
              Row(
                children: [
                  // Shrinks a long total instead of overflowing next to the button.
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Total ', style: AppTextStyle.p_regular_12(color: AppColors.textTertiary)),
                          Text(euro(b.total), style: AppTextStyle.sub_h2_medium_16(color: AppColors.textPrimary)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  // An unpaid late fee blocks new bookings: paying it comes
                  // before reviewing (it's paid on the detail screen).
                  if (lateDue && !forProvider)
                    BookingPillButton(label: 'Pay late fee', icon: Icons.credit_card_rounded, filled: true, onTap: onTap)
                  else if (onReview != null)
                    BookingPillButton(label: 'Rate & review', icon: Icons.star_rounded, onTap: onReview!)
                  else
                    BookingPillButton(label: 'View details', icon: Icons.arrow_forward_rounded, filled: true, onTap: onTap),
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
      padding: EdgeInsets.only(top: 3.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 13.sp, color: color ?? AppColors.textTertiary),
          SizedBox(width: 5.w),
          Expanded(
            // Two lines: a rental "19 Nov · 9:00 AM → 26 Nov · 9:00 AM"
            // doesn't fit one line on small phones.
            child: Text(text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.p_regular_12(color: color ?? AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}

/// Small rounded button used on cards and empty states.
class BookingPillButton extends StatelessWidget {
  const BookingPillButton({super.key, required this.label, required this.icon, required this.onTap, this.filled = false});

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final fg = filled ? AppColors.textOnPrimary : const Color(0xFF9A7A12);
    return Material(
      color: filled ? AppColors.primary_1 : const Color(0xFFFBF3DC),
      borderRadius: BorderRadius.circular(10.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!filled) ...[Icon(icon, size: 15.sp, color: fg), SizedBox(width: 4.w)],
              Text(label, style: AppTextStyle.p_medium_12(color: fg).copyWith(fontWeight: FontWeight.w600)),
              if (filled) ...[SizedBox(width: 4.w), Icon(icon, size: 15.sp, color: fg)],
            ],
          ),
        ),
      ),
    );
  }
}

/// Empty / error state that still allows pull to refresh.
class BookingStateMessage extends StatelessWidget {
  const BookingStateMessage({super.key, required this.icon, required this.title, required this.message, this.actionLabel, this.onAction, this.insets = EdgeInsets.zero});

  /// Space for a header / nav bar drawn over the list.
  final EdgeInsets insets;

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 32.w) + insets,
      children: [
        SizedBox(height: 90.h),
        Center(
          child: Container(
            width: 84.w,
            height: 84.w,
            decoration: const BoxDecoration(color: Color(0xFFFBF3DC), shape: BoxShape.circle),
            child: Icon(icon, size: 38.sp, color: AppColors.primary_1),
          ),
        ),
        SizedBox(height: 18.h),
        Text(title, textAlign: TextAlign.center, style: AppTextStyle.sub_h2_medium_16(color: AppColors.textPrimary)),
        SizedBox(height: 6.h),
        Text(message, textAlign: TextAlign.center, style: AppTextStyle.p_regular_12(color: AppColors.textTertiary)),
        if (actionLabel != null && onAction != null) ...[
          SizedBox(height: 18.h),
          Center(child: BookingPillButton(label: actionLabel!, icon: Icons.refresh_rounded, filled: true, onTap: onAction!)),
        ],
      ],
    );
  }
}
