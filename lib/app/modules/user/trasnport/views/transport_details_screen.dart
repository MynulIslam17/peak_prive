import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text-style.dart';
import '../../../../core/widgets/checkout_parts.dart';
import '../../../../core/widgets/collapsible_details_layout.dart';
import '../../../../core/widgets/listing_details_parts.dart';
import '../../../../routes/app_routes.dart';
import '../controlers/trasnport_details_controller.dart';
import '../../../../data/api/peak_api.dart';
import 'package:harry_service_app/app/core/widgets/shimmer/skeleton.dart';

/// User → Transport listing: vehicle details, then continue to checkout.
class TransportDetailsScreen extends StatefulWidget {
  const TransportDetailsScreen({super.key});

  @override
  State<TransportDetailsScreen> createState() => _TransportDetailsScreenState();
}

class _TransportDetailsScreenState extends State<TransportDetailsScreen> {
  final controller = Get.find<TransportDetailsController>();
  late final String transportId;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    transportId = args is Map ? (args['id']?.toString() ?? '') : '';
    if (transportId.isNotEmpty) controller.fetch(transportId);
  }

  @override
  Widget build(BuildContext context) {
    if (transportId.isEmpty) {
      return ListingErrorView(
        message: 'This listing link is invalid.',
        onRetry: Get.back,
      );
    }

    return GetBuilder<TransportDetailsController>(
      builder: (_) {
        final t = controller.listing;
        if (t == null && controller.isLoading) {
          return const DetailsPageSkeleton(sections: [SkeletonSection.infoCard, SkeletonSection.lines]);
        }
        if (t == null) {
          return ListingErrorView(
            message: controller.errorMessage ?? 'No details available',
            onRetry: () => controller.fetch(transportId),
          );
        }

        final bookable = controller.isBookable;
        final rating = controller.rating;
        return CollapsibleDetailsLayout(
          imageUrl: t.thumbnail ?? '',
          title: t.title,
          onBack: Get.back,
          bottomBar: DetailsBottomBar(
            priceLabel: 'Price per trip',
            price: bookable ? checkoutEuro(t.price.amount) : '—',
            buttonText: bookable ? 'Continue' : 'Unavailable',
            onPressed: bookable
                ? () => Get.toNamed(
                      Routes.transportCheckout,
                      arguments: {'id': t.id, 'listing': t},
                    )
                : null,
          ),
          children: [
            if (!t.isActive) const ListingUnavailableNotice(),
            ListingHeader(
              title: t.title,
              rating: rating.average,
              reviewCount: rating.count,
              chips: [
                if ((t.subCategory?.name ?? '').isNotEmpty)
                  ListingInfoChip(
                    icon: Icons.directions_car_outlined,
                    label: t.subCategory!.name,
                  ),
                if ((t.serviceArea ?? '').isNotEmpty)
                  ListingInfoChip(
                    icon: Icons.location_on_outlined,
                    label: t.serviceArea!,
                  ),
              ],
            ),
            const SizedBox(height: 20),
            if (t.provider != null)
              ListingProviderCard(
                id: t.provider!.id,
                name: t.provider!.name ?? '',
                photoUrl: t.provider!.photo ?? '',
              ),
            if ((t.seats ?? 0) > 0 || t.mileage != null || t.power != null) ...[
              const ListingSectionTitle('Vehicle'),
              _SpecsRow(transport: t),
            ],
            if ((t.description ?? '').isNotEmpty) ...[
              const ListingSectionTitle('About'),
              ListingExpandableText(t.description!),
            ],
            const ListingSectionTitle('Price'),
            _PriceCard(transport: t, bookable: bookable),
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

class _SpecsRow extends StatelessWidget {
  const _SpecsRow({required this.transport});

  final TransportDetail transport;

  /// Old listings stored bare numbers ("250"); newer ones "15 km/l".
  static String _withUnit(String v, String unit) =>
      num.tryParse(v) != null ? '$v $unit' : v;

  @override
  Widget build(BuildContext context) {
    final seats = transport.seats ?? 0;
    final specs = <(IconData, String, String)>[
      if (seats > 0) (Icons.event_seat_outlined, '$seats', 'Seats'),
      if (transport.mileage != null)
        (Icons.speed_rounded, _withUnit(transport.mileage!, 'km'), 'Mileage'),
      if (transport.power != null)
        (Icons.bolt_rounded, _withUnit(transport.power!, 'hp'), 'Power'),
    ];
    return Row(
      children: [
        for (var i = 0; i < specs.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Icon(specs[i].$1, size: 20, color: AppColors.primary_1),
                  const SizedBox(height: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      specs[i].$2,
                      maxLines: 1,
                      style: AppTextStyle.sub_h3_semibold_14(),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    specs[i].$3,
                    style: AppTextStyle.p_regular_12(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _PriceCard extends StatelessWidget {
  const _PriceCard({required this.transport, required this.bookable});

  final TransportDetail transport;
  final bool bookable;

  @override
  Widget build(BuildContext context) {
    Widget row(IconData icon, String label, String value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.textTertiary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyle.sub_h3_regular_14(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Text(value, style: AppTextStyle.sub_h3_semibold_14()),
            ],
          ),
        );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          row(
            Icons.payments_outlined,
            'Trip (whole booking)',
            bookable ? checkoutEuro(transport.price.amount) : '—',
          ),
          if ((transport.extraChargePerHour ?? 0) > 0)
            row(
              Icons.more_time_rounded,
              'Late return',
              '${checkoutEuro(transport.extraChargePerHour!)} / hour',
            ),
          const Divider(height: 16, color: AppColors.divider),
          Text(
            !bookable
                ? 'This vehicle cannot be booked right now.'
                : (transport.extraChargePerHour ?? 0) > 0
                    ? 'One price for your whole booking, whatever its length. '
                        '${lateFeeRuleText(checkoutEuro(transport.extraChargePerHour!))}'
                    : 'One price for your whole booking, whatever its length.',
            style: AppTextStyle.p_regular_12(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}
