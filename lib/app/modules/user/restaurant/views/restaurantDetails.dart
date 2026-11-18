import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text-style.dart';
import '../../../../core/widgets/checkout_parts.dart';
import '../../../../core/widgets/collapsible_details_layout.dart';
import '../../../../core/widgets/listing_details_parts.dart';
import '../../../../routes/app_routes.dart';
import '../controllers/restaurant_details_controller.dart';
import '../../../../data/api/peak_api.dart';
import 'package:harry_service_app/app/core/widgets/shimmer/skeleton.dart';

/// User → Restaurant listing: pick a seating, then continue to checkout.
class RestaurantDetails extends StatefulWidget {
  const RestaurantDetails({super.key});

  @override
  State<RestaurantDetails> createState() => _RestaurantDetailsState();
}

class _RestaurantDetailsState extends State<RestaurantDetails> {
  final controller = Get.find<RestaurantDetailsController>();
  late final String restaurantId;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    restaurantId = args is Map ? (args['id']?.toString() ?? '') : '';
    if (restaurantId.isNotEmpty) {
      controller.fetch(restaurantId);
    }
  }

  void _continue() {
    final r = controller.listing;
    final seat = controller.selectedItem;
    if (seat == null || r == null || !controller.isBookable) return;
    Get.toNamed(Routes.restaurantCheckout, arguments: {
      'id': r.id,
      'listing': r,
      // Seat type picked here: start checkout with one seat of it.
      'seats': {seat.id: 1},
    });
  }

  @override
  Widget build(BuildContext context) {
    if (restaurantId.isEmpty) {
      return ListingErrorView(
        message: 'This listing link is invalid.',
        onRetry: Get.back,
      );
    }

    return GetBuilder<RestaurantDetailsController>(
      builder: (_) {
        final r = controller.listing;
        if (r == null && controller.isLoading) {
          return const DetailsPageSkeleton(sections: [SkeletonSection.lines, SkeletonSection.tiles, SkeletonSection.list]);
        }
        if (r == null) {
          return ListingErrorView(
            message: controller.errorMessage ?? 'No details available',
            onRetry: () => controller.fetch(restaurantId),
          );
        }

        final selected = controller.selectedItem;
        final bookable = controller.isBookable;
        final rating = controller.rating;
        final from = controller.fromPrice;
        final hours = (r.openTime ?? '').isNotEmpty
            ? '${r.openTime} – ${r.closeTime ?? ''}'
            : null;

        return CollapsibleDetailsLayout(
          imageUrl: r.thumbnail ?? '',
          title: r.title,
          onBack: Get.back,
          bottomBar: DetailsBottomBar(
            priceLabel: !bookable
                ? 'Not available'
                : selected != null
                    ? '${selected.type} · per seat'
                    : 'Choose a seating',
            price: selected != null
                ? checkoutEuro(selected.price)
                : from != null
                    ? 'from ${checkoutEuro(from)}'
                    : '—',
            buttonText: bookable ? 'Continue' : 'Unavailable',
            onPressed: bookable && selected != null ? _continue : null,
          ),
          children: [
            if (!r.isActive) const ListingUnavailableNotice(),
            ListingHeader(
              title: r.title,
              rating: rating.average,
              reviewCount: rating.count,
              chips: [
                if (r.isOpenNow != null) _StatusChip(isOpen: r.isOpenNow!),
                if ((r.subCategory?.name ?? '').isNotEmpty)
                  ListingInfoChip(
                    icon: Icons.restaurant_rounded,
                    label: r.subCategory!.name,
                  ),
                if ((r.foodType ?? '').isNotEmpty &&
                    r.foodType != r.subCategory?.name)
                  ListingInfoChip(
                    icon: Icons.ramen_dining_outlined,
                    label: r.foodType!,
                  ),
                if (hours != null)
                  ListingInfoChip(icon: Icons.schedule_rounded, label: hours),
                if ((r.serviceArea ?? '').isNotEmpty)
                  ListingInfoChip(
                    icon: Icons.location_on_outlined,
                    label: r.serviceArea!,
                  ),
              ],
            ),
            const SizedBox(height: 20),
            if (r.provider != null)
              ListingProviderCard(
                id: r.provider!.id,
                name: r.provider!.name ?? '',
                photoUrl: r.provider!.photo ?? '',
              ),
            if ((r.description ?? '').trim().isNotEmpty) ...[
              const ListingSectionTitle('About'),
              ListingExpandableText(r.description!.trim()),
            ],
            ListingSectionTitle(
              'Choose your seating',
              trailing: r.seats.isEmpty ? null : '${r.seats.length}',
            ),
            if (r.seats.isEmpty)
              const _EmptySeating()
            else
              for (final item in r.seats) ...[
                _SeatTile(
                  item: item,
                  selected: item.id == controller.selectedItemId,
                  enabled: r.isActive,
                  onTap: () => controller.selectItem(
                    item.id == controller.selectedItemId ? null : item.id,
                  ),
                ),
                const SizedBox(height: 10),
              ],
            if (r.serviceFee > 0)
              ListingNote(
                icon: Icons.receipt_long_outlined,
                text: 'A service fee of ${checkoutEuro(r.serviceFee)} is '
                    'added once per booking.',
              ),
            ListingSectionTitle(
              'Time slots',
              trailing: r.slots.isEmpty ? null : '${r.slots.length}',
            ),
            if (r.slots.isEmpty)
              const ListingNote(
                icon: Icons.event_busy_outlined,
                text: 'No time slots listed yet.',
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final slot in r.slots)
                    ListingInfoChip(icon: Icons.schedule_rounded, label: slot.label),
                ],
              ),
            const SizedBox(height: 6),
            Text(
              'Free seats depend on the date and slot; you choose them at checkout.',
              style: AppTextStyle.p_regular_12(color: AppColors.textTertiary),
            ),
            ListingReviewsSection(
              reviews: controller.reviews,
              count: rating.count,
              isLoading: controller.reviewsLoading,
              error: controller.reviewsError,
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────── Widgets ───────────────────────────────

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.isOpen});

  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    final color = isOpen ? AppColors.success : AppColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            isOpen ? 'Open' : 'Closed',
            style: AppTextStyle.p_medium_12(color: color),
          ),
        ],
      ),
    );
  }
}

class _SeatTile extends StatelessWidget {
  const _SeatTile({
    required this.item,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final SeatType item;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final soldOut = !RestaurantDetailsController.isSelectable(item);
    final canTap = enabled && !soldOut;

    final (stockText, stockColor) = soldOut
        ? ('Not available', AppColors.error)
        : ('${item.quantity} ${item.quantity == 1 ? 'seat' : 'seats'}', AppColors.textTertiary);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: canTap ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary_1.withValues(alpha: 0.06)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.primary_1 : AppColors.border,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Opacity(
            opacity: canTap || selected ? 1 : 0.55,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: (item.photo ?? '').isEmpty
                        ? const _SeatPlaceholder()
                        : CachedNetworkImage(
                            imageUrl: item.photo!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) =>
                                Container(color: AppColors.shimmerBase),
                            errorWidget: (_, __, ___) =>
                                const _SeatPlaceholder(),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.type,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.sub_h3_medium_14(),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${checkoutEuro(item.price)} / seat',
                        style: AppTextStyle.sub_h3_semibold_14(
                          color: AppColors.primary_1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        stockText,
                        style: AppTextStyle.p_regular_12(color: stockColor),
                      ),
                      if ((item.description ?? '').trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.description!.trim(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.p_regular_12(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: selected ? AppColors.primary_1 : AppColors.border,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SeatPlaceholder extends StatelessWidget {
  const _SeatPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceAlt,
      alignment: Alignment.center,
      child: const Icon(Icons.chair_outlined, color: AppColors.textTertiary),
    );
  }
}

class _EmptySeating extends StatelessWidget {
  const _EmptySeating();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        'No seating listed yet',
        textAlign: TextAlign.center,
        style: AppTextStyle.sub_h3_regular_14(color: AppColors.textTertiary),
      ),
    );
  }
}
