import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text-style.dart';
import '../../../../core/widgets/collapsible_details_layout.dart';
import '../../../../core/widgets/listing_details_parts.dart';
import '../../../../routes/app_routes.dart';
import '../controllers/pass_details_controller.dart';
import '../../../../core/utils/price_label.dart';
import '../../../../data/api/peak_api.dart';
import '../../shared/views/listing_reviews_screen.dart';
import 'package:harry_service_app/app/core/widgets/shimmer/skeleton.dart';

class PassDetailsScreen extends StatefulWidget {
  const PassDetailsScreen({super.key});

  @override
  State<PassDetailsScreen> createState() => _PassDetailsScreenState();
}

class _PassDetailsScreenState extends State<PassDetailsScreen> {
  late final String id;
  final controller = Get.find<PassDetailsController>();

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    id = args is Map ? (args['id']?.toString() ?? '') : '';
    controller.fetch(id);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PassDetailsController>(
      builder: (_) {
        if (controller.isLoading && controller.listing == null) {
          return const DetailsPageSkeleton(sections: [SkeletonSection.tiles, SkeletonSection.lines]);
        }

        final pass = controller.listing;
        if (pass == null) {
          return ListingErrorView(
            message: controller.errorMessage ?? 'No details available',
            onRetry: () => controller.fetch(id),
          );
        }
        final rating = controller.rating;

        return CollapsibleDetailsLayout(
          imageUrl: pass.thumbnail ?? '',
          title: pass.title,
          onBack: Get.back,
          bottomBar: DetailsBottomBar(
            priceLabel: pass.isActive ? 'Price per person' : 'Not available',
            price: euroLabel(pass.price.amount),
            buttonText: pass.isActive ? 'Book Ski Pass' : 'Unavailable',
            onPressed: pass.isActive
                ? () => Get.toNamed(
                      Routes.passInformation,
                      arguments: {'id': pass.id, 'listing': pass},
                    )
                : null,
          ),
          children: [
            if (!pass.isActive) const ListingUnavailableNotice(),
            ListingHeader(
              title: pass.title,
              rating: rating.average,
              reviewCount: rating.count,
              chips: [
                if (pass.passType != null)
                  ListingInfoChip(
                    icon: Icons.confirmation_number_outlined,
                    label: pass.passType!.label,
                  ),
                if ((pass.serviceArea ?? '').isNotEmpty)
                  ListingInfoChip(
                    icon: Icons.location_on_outlined,
                    label: pass.serviceArea!,
                  ),
              ],
            ),
            const SizedBox(height: 20),
            if (pass.provider != null)
              ListingProviderCard(
                id: pass.provider!.id,
                name: pass.provider!.name ?? '',
                photoUrl: pass.provider!.photo ?? '',
              ),
            if (pass.services.isNotEmpty) ...[
              const ListingSectionTitle("What's included"),
              _IncludedGrid(services: pass.services),
            ],
            if ((pass.description ?? '').isNotEmpty) ...[
              const ListingSectionTitle('About this pass'),
              ListingExpandableText(pass.description!),
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

// ─────────────────────────────── What's included ───────────────────────────────

class _IncludedGrid extends StatelessWidget {
  const _IncludedGrid({required this.services});

  final List<PassService> services;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 10.0;
        final w = constraints.maxWidth;
        final columns = w < 340 ? 1 : (w < 520 ? 2 : 3);
        final tileWidth = (w - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final s in services)
              SizedBox(width: tileWidth, child: _IncludedTile(service: s)),
          ],
        );
      },
    );
  }
}

class _IncludedTile extends StatelessWidget {
  const _IncludedTile({required this.service});

  final PassService service;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primary_1.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.check_rounded,
                size: 18, color: AppColors.primary_1),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.p_regular_12(
                      color: AppColors.textTertiary),
                ),
                const SizedBox(height: 2),
                Text(
                  service.description ?? service.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.sub_h3_medium_14(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
