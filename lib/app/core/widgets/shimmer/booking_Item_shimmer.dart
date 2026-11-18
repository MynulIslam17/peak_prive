import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import 'skeleton.dart';

/// Loading placeholder shaped like `BookingListCard`: thumbnail, title with
/// status chip, meta rows, divider, then the total and the pill button.
/// [provider] matches `ProviderBookingTile` instead (customer row, 72
/// thumbnail, two meta rows).
class BookingCardSkeleton extends StatelessWidget {
  const BookingCardSkeleton({super.key, this.provider = false});

  final bool provider;

  @override
  Widget build(BuildContext context) {
    // `_MetaRow`: a 13 icon and one line of 12 pt text.
    Widget meta(double w) => Padding(
          padding: EdgeInsets.only(top: provider ? 4 : 3.h),
          child: Row(children: [
            const SkeletonBox(height: 13, width: 13, radius: 3),
            const SizedBox(width: 6),
            SkeletonBox(height: 12, width: w),
          ]),
        );

    final thumb = provider ? 72.0 : 76.w;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SkeletonShimmer(
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: thumb, height: thumb, radius: 12),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(child: SkeletonBox(height: 14.h)),
                        SizedBox(width: 24.w),
                        // Dense status chip: 10 pt text, padding 8 × 3.
                        SkeletonBox(width: 62.w, height: 18.h, radius: 20),
                      ]),
                      SizedBox(height: 6.h),
                      if (provider) ...[
                        Row(children: [
                          const SkeletonBox(height: 18, circle: true),
                          SizedBox(width: 6.w),
                          SkeletonBox(width: 90.w, height: 12),
                        ]),
                        meta(130.w),
                        meta(96.w),
                      ] else ...[
                        meta(120.w),
                        meta(90.w),
                        meta(70.w),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              child: const Divider(height: 1, color: AppColors.border),
            ),
            Row(children: [
              SkeletonBox(width: 34.w, height: 12),
              SizedBox(width: 6.w),
              SkeletonBox(width: 60.w, height: 16.h),
              const Spacer(),
              // `BookingPillButton` / `ProviderPillButton`: radius 10,
              // padding 12 × 8 around a 12 pt label and a 15 icon.
              if (provider) ...[
                SkeletonBox(width: 72.w, height: 33.h, radius: 10),
                SizedBox(width: 8.w),
              ],
              SkeletonBox(width: provider ? 88.w : 108.w, height: 33.h, radius: 10),
            ]),
          ],
        ),
      ),
    );
  }
}

/// A scrollable column of [BookingCardSkeleton]s with the booking list's
/// spacing. [dayHeaders] adds the itinerary's day titles.
class BookingListSkeleton extends StatelessWidget {
  const BookingListSkeleton({super.key, this.insets = EdgeInsets.zero, this.dayHeaders = false, this.count = 3});

  final EdgeInsets insets;
  final bool dayHeaders;
  final int count;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, dayHeaders ? 8.h : 14.h, 16.w, 24.h) + insets,
      children: [
        for (var i = 0; i < count; i++) ...[
          // The middle card shares the day above it, like a real itinerary.
          if (dayHeaders && i != 1)
            Padding(
              padding: EdgeInsets.only(top: 14.h, bottom: 8.h),
              child: SkeletonShimmer(child: SkeletonBox(width: 110.w, height: 14.h)),
            ),
          const BookingCardSkeleton(),
          SizedBox(height: 12.h),
        ],
      ],
    );
  }
}
