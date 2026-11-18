import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/collapsing_header.dart';
import 'package:harry_service_app/app/core/widgets/shimmer/booking_Item_shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text-style.dart';
import '../../../../core/utils/price_label.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../data/api/peak_api.dart';
import '../../../../core/controllers/nav_controller.dart';
import '../../../../core/widgets/provider_profile.dart';
import '../../../../routes/app_routes.dart';
import '../controllers/all_booking_controller.dart';
import '../controllers/provider_home_controller.dart';
import '../widgets/provider_ui.dart';

/// Provider → Bookings tab: every booking on the provider's listings, with
/// filters by status. Works for all provider types.
class ProviderBookingRequestScreen extends StatefulWidget {
  const ProviderBookingRequestScreen({super.key});

  @override
  State<ProviderBookingRequestScreen> createState() => _ProviderBookingRequestScreenState();
}

class _ProviderBookingRequestScreenState extends State<ProviderBookingRequestScreen> {
  final controller = Get.put(ProviderBookingsController());
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    // After the first frame: update() must not run mid-build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) controller.fetchBookings();
    });
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 400) controller.loadMore();
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// Requests waiting for approval, from the dashboard (badge on the chip).
  int? _requestCount() => Get.isRegistered<ProviderHomeController>()
      ? Get.find<ProviderHomeController>().dashboard?.bookings.requests
      : null;

  void _refreshHome() {
    if (Get.isRegistered<ProviderHomeController>()) {
      Get.find<ProviderHomeController>().refreshData();
    }
  }

  /// [build] again whenever the dashboard changes (when it's registered).
  Widget _withHome(Widget Function() build) => Get.isRegistered<ProviderHomeController>()
      ? GetBuilder<ProviderHomeController>(builder: (_) => build())
      : build();

  Future<void> _quick(Booking b, BookingAction action) async {
    String? reason;
    if (action == BookingAction.reject) {
      final res = await _confirmReject(context, b);
      if (res == null) return; // kept
      reason = res;
    }
    final r = await controller.quickAction(b, action, reason: reason);
    if (r.message.isEmpty) return;
    if (r.ok) {
      AppToast.success(r.message);
      _refreshHome();
    } else if (r.conflict) {
      AppToast.info(r.message, title: 'Booking changed');
      _refreshHome();
    } else {
      AppToast.error(r.message);
    }
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
        body: (_, insets) => GetBuilder<ProviderBookingsController>(
          builder: (c) {
            final shown = c.bookings;
            return RefreshIndicator(
              color: AppColors.primary_1,
              edgeOffset: CollapsingHeaderLayout.refreshEdge(context),
              onRefresh: () async {
                _refreshHome();
                await c.refreshBookings();
              },
              child: CustomScrollView(
                controller: _scroll,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(16, 8 + insets.top, 16, 12),
                    sliver: SliverToBoxAdapter(
                      child: ProviderSectionHeader(title: 'Bookings', count: c.isLoading ? null : c.total),
                    ),
                  ),
                  SliverToBoxAdapter(
                    // Rebuilds with the dashboard too, so the request
                    // count follows accepts/rejects and live updates.
                    child: _withHome(
                      () => SizedBox(
                        height: 38,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            for (final f in ProviderBookingFilter.values) ...[
                              _FilterChip(
                                label: f.label,
                                count: f == ProviderBookingFilter.requests && (_requestCount() ?? 0) > 0
                                    ? _requestCount()
                                    : null,
                                selected: c.filter == f,
                                onTap: () => c.setFilter(f),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  if (c.isLoading)
                    const SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverToBoxAdapter(child: _ListShimmer()),
                    )
                  else if (shown.isEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverToBoxAdapter(
                        child: c.errorMessage != null
                            ? ProviderEmptyState(
                                icon: Icons.cloud_off_rounded,
                                title: "Couldn't load bookings",
                                message: c.errorMessage,
                                actionLabel: 'Try again',
                                onAction: c.fetchBookings,
                              )
                            : c.filter == ProviderBookingFilter.all
                            ? const ProviderEmptyState(
                                icon: Icons.event_available_outlined,
                                title: 'No bookings yet',
                                message:
                                    'When guests book your services, '
                                    'they will show up here.',
                              )
                            : ProviderEmptyState(
                                icon: Icons.filter_list_rounded,
                                title: 'Nothing here',
                                message: 'No ${c.filter.label.toLowerCase()} bookings.',
                                actionLabel: 'Show all',
                                onAction: () => c.setFilter(ProviderBookingFilter.all),
                              ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList.separated(
                        itemCount: shown.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) {
                          final b = shown[i];
                          return ProviderBookingTile(
                            booking: b,
                            busy: c.busyIds.contains(b.id),
                            onAccept: () => _quick(b, BookingAction.approve),
                            onReject: () => _quick(b, BookingAction.reject),
                            onTap: () async {
                              await openProviderBooking(b);
                              c.refreshBookings();
                              _refreshHome();
                            },
                          );
                        },
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 20 + insets.bottom),
                      child: c.isLoadingMore ? const Padding(padding: EdgeInsets.only(top: 12), child: BookingCardSkeleton(provider: true)) : const SizedBox.shrink(),
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
}

/// Asks before rejecting (the guest is refunded in full). Returns the
/// optional reason ('' for none), or null when the provider keeps it.
Future<String?> _confirmReject(BuildContext context, Booking b) {
  // Not disposed here: the dialog still builds while it animates out.
  final reason = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Reject this booking?', style: AppTextStyle.sub_h2_medium_16()),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${ProviderBookingText.customerName(b)} gets a full refund '
            '(${euroLabel(b.total)}) to their card.',
            style: AppTextStyle.p_regular_12(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: reason,
            maxLines: 2,
            maxLength: 200,
            decoration: InputDecoration(
              hintText: 'Reason (optional)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Keep it')),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          onPressed: () => Navigator.of(ctx).pop(reason.text.trim()),
          child: const Text('Reject'),
        ),
      ],
    ),
  );
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap, this.count});

  final String label;
  final int? count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.textOnPrimary : AppColors.textSecondary;
    return Material(
      color: selected ? AppColors.primary_1 : Colors.white,
      shape: StadiumBorder(side: BorderSide(color: selected ? AppColors.primary_1 : AppColors.border)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Center(
            child: Text(
              count == null ? label : '$label  $count',
              style: AppTextStyle.p_medium_12(color: fg).copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}

class _ListShimmer extends StatelessWidget {
  const _ListShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < 4; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          const BookingCardSkeleton(provider: true),
        ],
      ],
    );
  }
}
