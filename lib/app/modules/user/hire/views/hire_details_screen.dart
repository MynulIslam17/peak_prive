import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text-style.dart';
import '../../../../core/widgets/checkout_parts.dart';
import '../../../../core/widgets/collapsible_details_layout.dart';
import '../../../../core/widgets/listing_details_parts.dart';
import '../../../../routes/app_routes.dart';
import '../contollers/hire_details_controller.dart';
import '../../../../data/api/peak_api.dart';
import '../models/hire_price_unit.dart';
import 'package:harry_service_app/app/core/widgets/shimmer/skeleton.dart';

/// User → Ski hire listing: pick equipment, then continue to checkout.
class HireDetailsScreen extends StatefulWidget {
  const HireDetailsScreen({super.key});

  @override
  State<HireDetailsScreen> createState() => _HireDetailsScreenState();
}

class _HireDetailsScreenState extends State<HireDetailsScreen> {
  final controller = Get.find<HireDetailsController>();
  late final String hireId;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    hireId = args is Map ? (args['id']?.toString() ?? '') : '';
    if (hireId.isNotEmpty) controller.fetchHireDetails(hireId);
  }

  void _continue() {
    final listing = controller.listing;
    if (controller.selectedItems.isEmpty || listing == null || !listing.isActive) return;
    Get.toNamed(Routes.hireCheckout, arguments: {
      'id': listing.id,
      'listing': listing,
      // itemId → quantity chosen here.
      'quantities': Map<String, int>.of(controller.selectedItems),
    });
  }

  @override
  Widget build(BuildContext context) {
    if (hireId.isEmpty) {
      return ListingErrorView(
        message: 'This listing link is invalid.',
        onRetry: Get.back,
      );
    }

    return GetBuilder<HireDetailsController>(
      builder: (_) {
        final hire = controller.listing;
        if (hire == null && controller.isLoading) {
          return const DetailsPageSkeleton(sections: [SkeletonSection.lines, SkeletonSection.list]);
        }
        if (hire == null) {
          return ListingErrorView(
            message: controller.errorMessage ?? 'No details available',
            onRetry: () => controller.fetch(hireId),
          );
        }

        final count = controller.selectedCount;
        final hasSelection = count > 0;
        final unit = controller.priceUnit;
        final rating = controller.rating;

        return CollapsibleDetailsLayout(
          imageUrl: hire.thumbnail ?? '',
          title: hire.title,
          onBack: Get.back,
          bottomBar: DetailsBottomBar(
            priceLabel: !hire.isActive
                ? 'Not available'
                : hasSelection
                    ? '$count ${count == 1 ? 'item' : 'items'} selected'
                    : 'Select equipment',
            price: hasSelection
                ? '${checkoutEuro(controller.totalSelectedPrice)} ${unit.suffix}'
                : checkoutEuro(0),
            buttonText: hire.isActive ? 'Continue' : 'Unavailable',
            onPressed: hasSelection && hire.isActive ? _continue : null,
          ),
          children: [
            if (!hire.isActive) const ListingUnavailableNotice(),
            ListingHeader(
              title: hire.title,
              rating: rating.average,
              reviewCount: rating.count,
              chips: [
                if ((hire.subCategory?.name ?? '').isNotEmpty)
                  ListingInfoChip(
                    icon: Icons.downhill_skiing_rounded,
                    label: hire.subCategory!.name,
                  ),
                if ((hire.serviceArea ?? '').isNotEmpty)
                  ListingInfoChip(
                    icon: Icons.location_on_outlined,
                    label: hire.serviceArea!,
                  ),
                ListingInfoChip(
                  icon: Icons.sell_outlined,
                  label: unit == HirePriceUnit.perRental
                      ? 'Priced per rental'
                      : 'Priced per ${unit.singular}',
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (hire.provider != null)
              ListingProviderCard(
                id: hire.provider!.id,
                name: hire.provider!.name ?? '',
                photoUrl: hire.provider!.photo ?? '',
              ),
            if ((hire.description ?? '').isNotEmpty) ...[
              const ListingSectionTitle('About'),
              ListingExpandableText(hire.description!),
            ],
            ListingSectionTitle(
              'Choose equipment',
              trailing: hire.items.isEmpty ? null : '${hire.items.length}',
              action: hasSelection
                  ? TextButton(
                      onPressed: controller.clearSelection,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary_1,
                        minimumSize: const Size(0, 32),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: const Text('Clear'),
                    )
                  : null,
            ),
            if (hire.items.isEmpty)
              const _EmptyEquipment()
            else
              for (final item in hire.items) ...[
                _EquipmentTile(
                  item: item,
                  unit: unit,
                  stock: controller.maxQuantity(item),
                  quantity: controller.getQuantity(item.id),
                  canAdd: controller.canAdd(item),
                  onAdd: () => controller.addItem(item.id),
                  onRemove: () => controller.removeItem(item.id),
                ),
                const SizedBox(height: 10),
              ],
            if (hire.extraChargePerHour > 0)
              ListingNote(
                icon: Icons.more_time_rounded,
                text: lateFeeRuleText(checkoutEuro(hire.extraChargePerHour)),
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

// ─────────────────────────────── Equipment ───────────────────────────────

class _EquipmentTile extends StatelessWidget {
  const _EquipmentTile({
    required this.item,
    required this.unit,
    required this.stock,
    required this.quantity,
    required this.canAdd,
    required this.onAdd,
    required this.onRemove,
  });

  final HireItem item;
  final HirePriceUnit unit;

  /// Units in stock (date availability is checked at checkout).
  final int stock;
  final int quantity;
  final bool canAdd;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final selected = quantity > 0;
    final outOfStock = stock <= 0;
    final lowStock = !outOfStock && stock <= 3;

    final (stockText, stockColor) = outOfStock
        ? ('Out of stock', AppColors.error)
        : lowStock
            ? ('Only $stock in stock', const Color(0xFFB45309))
            : ('$stock in stock', AppColors.textTertiary);

    return AnimatedContainer(
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
        opacity: outOfStock ? 0.55 : 1,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 64,
                height: 64,
                child: (item.photo ?? '').isEmpty
                    ? const _ItemPlaceholder()
                    : CachedNetworkImage(
                        imageUrl: item.photo!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(color: AppColors.shimmerBase),
                        errorWidget: (_, __, ___) => const _ItemPlaceholder(),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.sub_h3_medium_14(),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${checkoutEuro(item.price)} ${unit.suffix}',
                    style: AppTextStyle.sub_h3_semibold_14(
                      color: AppColors.primary_1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stockText,
                    style: AppTextStyle.p_regular_12(color: stockColor),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (selected)
              CheckoutQuantityStepper(
                value: quantity,
                max: canAdd ? quantity + 1 : quantity,
                buttonSize: 34,
                onChanged: (v) => v > quantity ? onAdd() : onRemove(),
              )
            else
              OutlinedButton.icon(
                onPressed: outOfStock || !canAdd ? null : onAdd,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary_1,
                  side: BorderSide(
                    color: outOfStock ? AppColors.border : AppColors.primary_1,
                  ),
                  minimumSize: const Size(0, 38),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ItemPlaceholder extends StatelessWidget {
  const _ItemPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceAlt,
      alignment: Alignment.center,
      child: const Icon(
        Icons.downhill_skiing_rounded,
        color: AppColors.textTertiary,
      ),
    );
  }
}

class _EmptyEquipment extends StatelessWidget {
  const _EmptyEquipment();

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
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined,
              size: 28, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(
            'No equipment listed yet',
            style: AppTextStyle.sub_h3_regular_14(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
