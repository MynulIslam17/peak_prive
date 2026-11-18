import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../booking_Item_shimmer.dart';
import '../skeleton.dart';

/// Loading placeholder for the provider home body, laid out like the loaded
/// screen: three stat cards, the balance card, the "My services" carousel and
/// "Recent bookings". White cards with grey shimmer blocks, same spacing, so
/// nothing jumps when the data arrives.
class ProviderHomeShimmer extends StatelessWidget {
  const ProviderHomeShimmer({super.key, this.insets = EdgeInsets.zero});

  /// Extra space for a header / nav bar drawn over the screen.
  final EdgeInsets insets;

  static BoxDecoration get _card => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      );

  /// `MyServiceCard` and the booking tiles carry a soft lift.
  static BoxDecoration get _liftedCard => _card.copyWith(
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      );

  Widget _statCard() => Container(
        padding: const EdgeInsets.all(12),
        decoration: _card,
        child: const SkeletonShimmer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: 30, height: 30, radius: 9),
              SizedBox(height: 10),
              SkeletonBox(width: 28, height: 20),
              SizedBox(height: 6),
              SkeletonBox(width: 60, height: 10),
            ],
          ),
        ),
      );

  Widget _figure() => const Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: 46, height: 13),
            SizedBox(height: 6),
            SkeletonBox(width: 60, height: 10),
          ],
        ),
      );

  Widget _balanceCard() => Container(
        padding: const EdgeInsets.all(14),
        decoration: _card,
        child: SkeletonShimmer(
          child: Column(
            children: [
              const Row(children: [
                SkeletonBox(width: 18, height: 18, radius: 5),
                SizedBox(width: 8),
                SkeletonBox(width: 56, height: 11),
                Spacer(),
                SkeletonBox(width: 80, height: 20),
              ]),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(height: 1, color: AppColors.border),
              ),
              Row(children: [_figure(), _figure(), _figure()]),
              const SizedBox(height: 10),
              Row(children: [_figure(), _figure(), _figure()]),
            ],
          ),
        ),
      );

  Widget _sectionHeader(double width) => SkeletonShimmer(
        child: Row(children: [
          SkeletonBox(width: width, height: 16),
          const Spacer(),
          const SkeletonBox(width: 44, height: 12),
        ]),
      );

  /// A `MyServiceCard` without the visibility switch (255 high).
  Widget _serviceCard() => Container(
        width: 280,
        height: 255,
        clipBehavior: Clip.antiAlias,
        decoration: _liftedCard,
        child: const SkeletonShimmer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: SkeletonBox(width: double.infinity, height: double.infinity, radius: 0)),
              Padding(
                padding: EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(child: SkeletonBox(height: 15)),
                      SizedBox(width: 40),
                      SkeletonBox(width: 60, height: 15),
                    ]),
                    SizedBox(height: 10),
                    Row(children: [
                      SkeletonBox(width: 64, height: 11),
                      SizedBox(width: 12),
                      SkeletonBox(width: 100, height: 11),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24) + insets,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(child: _statCard()),
              ],
            ],
          ),
          const SizedBox(height: 12),
          _balanceCard(),
          const SizedBox(height: 24),
          _sectionHeader(100),
          const SizedBox(height: 8),
          SizedBox(
            height: 259,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              clipBehavior: Clip.none,
              children: [_serviceCard(), const SizedBox(width: 10), _serviceCard()],
            ),
          ),
          const SizedBox(height: 24),
          _sectionHeader(130),
          const SizedBox(height: 8),
          for (var i = 0; i < 2; i++) ...[
            const BookingCardSkeleton(provider: true),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
