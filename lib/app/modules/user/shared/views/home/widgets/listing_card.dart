import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/text-style.dart';
import '../../../../../../core/widgets/custom_image_container.dart';
import '../home_service_source.dart';

/// Card for a single service listing on the home feed.
class ListingCard extends StatelessWidget {
  const ListingCard({super.key, required this.listing, required this.onTap});

  final HomeListing listing;
  final VoidCallback onTap;

  static String formatPrice(num price) =>
      '€${price % 1 == 0 ? price.toStringAsFixed(0) : price.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    const radius = 16.0;

    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CustomCachedImage(
                    imageUrl: listing.imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    borderRadius: 0,
                  ),
                  if (listing.badge != null)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: _ImageBadge(label: listing.badge!),
                    ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: _RatingBadge(
                      rating: listing.rating,
                      count: listing.reviewCount,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          listing.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.sub_h2_medium_16(),
                        ),
                      ),
                      if (listing.price != null) ...[
                        const SizedBox(width: 12),
                        Text.rich(
                          TextSpan(
                            children: [
                              if (listing.priceIsFrom)
                                TextSpan(
                                  text: 'from ',
                                  style: AppTextStyle.p_regular_12(
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              TextSpan(text: formatPrice(listing.price!)),
                              if (listing.priceUnit.isNotEmpty)
                                TextSpan(
                                  text: listing.priceUnit,
                                  style: AppTextStyle.p_regular_12(
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                            ],
                          ),
                          style: AppTextStyle.sub_h2_medium_16(
                            color: AppColors.primary_1,
                          ).copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ],
                  ),
                  if (listing.location.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            listing.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyle.p_regular_12(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageBadge extends StatelessWidget {
  const _ImageBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 160),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary_1,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyle.p_medium_12(
          color: Colors.white,
        ).copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating, required this.count});

  final double rating;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 15, color: AppColors.primary_1),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: AppTextStyle.p_medium_12().copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            '($count)',
            style: AppTextStyle.p_regular_12(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}

/// Placeholder shown while listings load; mirrors [ListingCard]'s layout.
class ListingCardSkeleton extends StatelessWidget {
  const ListingCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    Widget block({double? width, required double height, double radius = 6}) =>
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.shimmerBase,
            borderRadius: BorderRadius.circular(radius),
          ),
        );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Shimmer.fromColors(
        baseColor: AppColors.shimmerBase,
        highlightColor: AppColors.shimmerHighlight,
        child: _content(block),
      ),
    );
  }

  Widget _content(
    Widget Function({double? width, required double height, double radius})
    block,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: block(height: double.infinity, radius: 0),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: block(height: 16)),
                  const SizedBox(width: 40),
                  block(width: 48, height: 16),
                ],
              ),
              const SizedBox(height: 10),
              block(width: 140, height: 12),
            ],
          ),
        ),
      ],
    );
  }
}
