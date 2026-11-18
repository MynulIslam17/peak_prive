import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text-style.dart';
import '../../../../core/utils/price_label.dart';
import '../../../../core/widgets/collapsible_details_layout.dart';
import '../../../../core/widgets/listing_details_parts.dart';
import '../../../../data/api/peak_api.dart';
import '../../shared/views/listing_reviews_screen.dart';
import '../../../../routes/app_routes.dart';
import '../controllers/message_details_controller.dart';
import 'package:harry_service_app/app/core/widgets/shimmer/skeleton.dart';

/// User → Massage listing: durations, hours, benefits, then book.
class MassageDetailsScreen extends StatefulWidget {
  const MassageDetailsScreen({super.key});

  @override
  State<MassageDetailsScreen> createState() => _MassageDetailsScreenState();
}

class _MassageDetailsScreenState extends State<MassageDetailsScreen> {
  final controller = Get.find<MassageDetailsController>();
  late final String productId;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    productId = args is Map ? (args['id']?.toString() ?? '') : '';
    if (productId.isNotEmpty) controller.fetch(productId);
  }

  void _book(MassageDetail m) => Get.toNamed(
        Routes.bookingRequest,
        arguments: {'id': m.id, 'listing': m},
      );

  @override
  Widget build(BuildContext context) {
    if (productId.isEmpty) {
      return ListingErrorView(
        message: 'This listing link is invalid.',
        onRetry: Get.back,
      );
    }

    return GetBuilder<MassageDetailsController>(
      builder: (_) {
        final m = controller.listing;
        if (m == null && controller.isLoading) {
          return const DetailsPageSkeleton(sections: [SkeletonSection.durations, SkeletonSection.lines]);
        }
        if (m == null) {
          return ListingErrorView(
            message: controller.errorMessage ?? 'No details available',
            onRetry: () => controller.fetch(productId),
          );
        }

        final rating = controller.rating;
        final bookable = controller.isBookable;
        final prices = m.durations.map((d) => d.price);
        final from = lowestPrice(prices) ?? m.price.amount;

        return CollapsibleDetailsLayout(
          imageUrl: m.thumbnail ?? '',
          title: m.title,
          onBack: Get.back,
          bottomBar: DetailsBottomBar(
            priceLabel: !m.isActive
                ? 'Not available'
                : m.durations.length > 1
                    ? 'From'
                    : 'Price',
            price: from > 0 ? euroLabel(from) : '—',
            buttonText: bookable ? 'Book now' : 'Unavailable',
            onPressed: bookable ? () => _book(m) : null,
          ),
          children: [
            if (!m.isActive) const ListingUnavailableNotice(),
            ListingHeader(
              title: m.title,
              rating: rating.average,
              reviewCount: rating.count,
              chips: [
                if ((m.subCategory?.name ?? '').isNotEmpty)
                  ListingInfoChip(
                    icon: Icons.spa_outlined,
                    label: m.subCategory!.name,
                  ),
                if ((m.serviceArea ?? '').isNotEmpty)
                  ListingInfoChip(
                    icon: Icons.location_on_outlined,
                    label: m.serviceArea!,
                  ),
                // How many can come together, so a group knows before checkout.
                ListingInfoChip(
                  icon: m.maxPeople == 1 ? Icons.person_outline_rounded : Icons.people_outline_rounded,
                  label: m.guestsLabel,
                ),
                if (m.openTime != null && m.closeTime != null)
                  ListingInfoChip(
                    icon: Icons.schedule_rounded,
                    label: '${m.openTime} – ${m.closeTime}',
                  ),
              ],
            ),
            const SizedBox(height: 20),
            if (m.provider != null)
              ListingProviderCard(
                id: m.provider!.id,
                name: m.provider!.name ?? '',
                photoUrl: m.provider!.photo ?? '',
              ),
            ListingSectionTitle(
              'Durations',
              trailing: m.durations.isEmpty ? null : '${m.durations.length}',
            ),
            if (m.durations.isEmpty)
              const ListingNote(
                icon: Icons.timer_off_outlined,
                text: 'No durations listed yet.',
              )
            else
              for (final d in m.durations) ...[
                _DurationTile(duration: d),
                const SizedBox(height: 8),
              ],
            if ((m.description ?? '').isNotEmpty) ...[
              const ListingSectionTitle('About'),
              ListingExpandableText(m.description!),
            ],
            if ((m.benefits ?? '').isNotEmpty) ...[
              const ListingSectionTitle('Benefits'),
              ListingExpandableText(m.benefits!),
            ],
            if ((m.recommendations ?? '').isNotEmpty) ...[
              const ListingSectionTitle('Our recommendation'),
              ListingExpandableText(m.recommendations!),
            ],
            ListingReviewsSection(
              reviews: controller.reviews,
              count: rating.count,
              isLoading: controller.reviewsLoading,
              error: controller.reviewsError,
              showSeeAll: controller.canSeeAllReviews,
              onSeeAll: () => openListingReviews(kind: controller.kind, id: controller.listing?.id),
            ),
          ],
        );
      },
    );
  }
}

class _DurationTile extends StatelessWidget {
  const _DurationTile({required this.duration});

  final MassageDuration duration;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primary_1.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.timer_outlined,
                size: 18, color: AppColors.primary_1),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(duration.label, style: AppTextStyle.sub_h3_medium_14()),
          ),
          Text(
            euroLabel(duration.price),
            style: AppTextStyle.sub_h3_semibold_14(color: AppColors.primary_1),
          ),
        ],
      ),
    );
  }
}
