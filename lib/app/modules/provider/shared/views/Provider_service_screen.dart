import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/collapsing_header.dart';
import 'package:harry_service_app/app/core/widgets/shimmer/skeleton.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text-style.dart';
import '../../../../core/controllers/nav_controller.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/delete_dialog.dart';
import '../../../../core/widgets/my_service_card.dart';
import '../../../../core/widgets/provider_profile.dart';
import '../../../../data/api/peak_api.dart';
import '../../../../routes/app_routes.dart';
import '../controllers/my_listings_controller.dart';
import '../widgets/provider_ui.dart';

/// Add / edit route for each service. Edit args: `{'isEdit': true, 'id': id}`.
String listingEditorRoute(ServiceKind kind) => switch (kind) {
  ServiceKind.skiPass => Routes.addPassService,
  ServiceKind.skiHire => Routes.addHireService,
  ServiceKind.transport => Routes.addTransportService,
  ServiceKind.restaurant => Routes.addRestaurantService,
  ServiceKind.massage => Routes.addMessageService,
};

/// Provider → "My services": every listing the provider owns (active and
/// inactive), for all five provider types.
class ProviderServiceScreen extends StatefulWidget {
  const ProviderServiceScreen({super.key});

  @override
  State<ProviderServiceScreen> createState() => _ProviderServiceScreenState();
}

class _ProviderServiceScreenState extends State<ProviderServiceScreen> {
  final controller = Get.put(MyListingsController());

  @override
  void initState() {
    super.initState();
    // After the first frame: update() must not run mid-build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) controller.load();
    });
  }

  Future<void> _create() async {
    final kind = controller.kind;
    if (kind == null) return;
    final created = await Get.toNamed(listingEditorRoute(kind), arguments: {'isEdit': false});
    _applySaved(created);
  }

  Future<void> _edit(ListingCard card) async {
    final saved = await Get.toNamed(listingEditorRoute(card.kind), arguments: {'isEdit': true, 'id': card.id});
    _applySaved(saved);
  }

  /// The editor returns the saved listing: show it at once, then sync quietly.
  void _applySaved(Object? result) {
    if (result is ListingCard) controller.upsert(result);
    if (result != null && result != false) controller.load(showLoader: false);
  }

  Future<void> _toggle(ListingCard card, bool active) async {
    final error = await controller.setActive(card, active);
    if (error != null) {
      AppToast.error(error, title: "Couldn't update the listing");
    } else {
      AppToast.success(
        active ? 'Guests can find and book it again.' : 'Hidden from guests. Existing bookings continue.',
        title: active ? 'Listing visible' : 'Listing hidden',
      );
    }
  }

  Future<void> _delete(ListingCard card) async {
    var outcome = DeleteOutcome.failed;
    await DeleteDialogService.show(
      context: context,
      title: 'Delete listing?',
      message: 'Guests will no longer see "${card.title}". This can\'t be undone.',
      failureMessage: () => controller.actionError,
      onDelete: () async {
        outcome = await controller.delete(card);
        // Close on 409 too: we offer "hide instead" next.
        return outcome != DeleteOutcome.failed;
      },
    );
    if (!mounted) return;
    if (outcome == DeleteOutcome.deleted) {
      AppToast.success('The listing was removed.', title: 'Deleted');
    } else if (outcome == DeleteOutcome.hasOpenBookings) {
      _offerHide(card);
    }
  }

  void _offerHide(ListingCard card) {
    DeleteDialogService.show(
      context: context,
      title: 'It has open bookings',
      message:
          '${controller.actionError ?? 'This listing still has bookings that are not finished.'}\n\n'
          'Hide it instead? Guests won\'t find it, and existing bookings continue.',
      deleteLabel: 'Hide listing',
      cancelLabel: 'Keep it',
      themeColor: AppColors.primary_1,
      icon: Icons.visibility_off_outlined,
      failureMessage: () => controller.actionError,
      onDelete: () async => await controller.setActive(card, false) == null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: CollapsingHeaderLayout(
        expandedHeight: ProviderProfile.expandedHeight,
        collapsedHeight: ProviderProfile.collapsedHeight,
        header: (_, t) => ProviderProfile(
          t: t,
          onProfileTap: () => Get.find<NavController>().changeIndex(4),
          onNotificationTap: () => Get.toNamed(Routes.notification),
        ),
        body: (_, insets) => GetBuilder<MyListingsController>(
          builder: (c) {
            return RefreshIndicator(
              color: AppColors.primary_1,
              edgeOffset: CollapsingHeaderLayout.refreshEdge(context),
              onRefresh: () => c.load(showLoader: false),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24) + insets,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ProviderSectionHeader(
                          title: 'My services',
                          count: c.isLoading ? null : c.listings.length,
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: c.kind == null ? null : _create,
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Add service'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary_1,
                          foregroundColor: AppColors.textOnPrimary,
                          textStyle: AppTextStyle.p_medium_12().copyWith(fontWeight: FontWeight.w600),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          minimumSize: const Size(0, 38),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                  if (!c.isLoading && c.listings.isNotEmpty && c.activeCount < c.listings.length)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '${c.activeCount} visible · ${c.listings.length - c.activeCount} hidden from guests',
                        style: AppTextStyle.p_regular_12(color: AppColors.textTertiary),
                      ),
                    ),
                  const SizedBox(height: 14),
                  if (c.isLoading)
                    _shimmer()
                  else if (c.errorMessage != null && c.listings.isEmpty)
                    ProviderEmptyState(
                      icon: Icons.cloud_off_rounded,
                      title: "Couldn't load your services",
                      message: c.errorMessage,
                      actionLabel: 'Try again',
                      onAction: () => c.load(),
                    )
                  else if (c.listings.isEmpty)
                    ProviderEmptyState(
                      icon: Icons.storefront_outlined,
                      title: 'No services yet',
                      message: 'Add your first listing so guests can find and book it.',
                      actionLabel: 'Add service',
                      onAction: _create,
                    )
                  else
                    for (final l in c.listings)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: MyServiceCard(
                          image: l.thumbnail ?? '',
                          title: l.title,
                          status: listingPriceLabel(l),
                          rating: l.rating.average,
                          reviews: l.rating.count,
                          location: l.serviceArea ?? '',
                          packageType: l.passType?.label ?? l.subCategory?.name,
                          isActive: l.isActive,
                          busy: c.busyIds.contains(l.id),
                          onActiveChanged: (v) => _toggle(l, v),
                          onEdit: () => _edit(l),
                          onDelete: () => _delete(l),
                        ),
                      ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Shaped like [MyServiceCard] with its visibility switch (290 high).
  Widget _shimmer() => Column(
        children: [for (var i = 0; i < 3; i++) const Padding(padding: EdgeInsets.only(bottom: 14), child: _ServiceCardSkeleton())],
      );
}

class _ServiceCardSkeleton extends StatelessWidget {
  const _ServiceCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 290,
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const SkeletonShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: SkeletonBox(width: double.infinity, height: double.infinity, radius: 15)),
            Padding(
              padding: EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(child: SkeletonBox(height: 15)),
                    SizedBox(width: 40),
                    SkeletonBox(width: 64, height: 15),
                  ]),
                  SizedBox(height: 10),
                  Row(children: [
                    SkeletonBox(width: 70, height: 11),
                    SizedBox(width: 12),
                    SkeletonBox(width: 110, height: 11),
                  ]),
                  SizedBox(height: 10),
                  Row(children: [
                    SkeletonBox(width: 130, height: 11),
                    Spacer(),
                    SkeletonBox(width: 40, height: 24, radius: 12),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
