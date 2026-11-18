import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text-style.dart';
import '../../../../core/controllers/auth_controller.dart';
import '../../../../core/controllers/nav_controller.dart';
import '../../../../core/utils/price_label.dart';
import '../../../../core/widgets/collapsing_header.dart';
import '../../../../core/widgets/delete_dialog.dart';
import '../../../../core/widgets/my_service_card.dart';
import '../../../../core/widgets/provider_profile.dart';
import '../../../../core/widgets/shimmer/provider/provider_home_shimmer.dart';
import '../../../../data/api/peak_api.dart';
import '../../../../routes/app_routes.dart';
import '../controllers/all_booking_controller.dart';
import '../controllers/provider_home_controller.dart';
import '../widgets/provider_ui.dart';

/// Provider → Home: counts, earnings, own listings, today's and recent
/// bookings. The same screen for every provider type.
class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  final authController = Get.find<AuthController>();
  final homeController = Get.find<ProviderHomeController>();
  final navController = Get.find<NavController>();

  @override
  void initState() {
    super.initState();
    // After the first frame: the fetch calls update(), which must not mark
    // other GetBuilders of this controller dirty mid-build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) homeController.fetchProviderHomeData();
    });
  }

  /// Opens the Bookings tab on [filter].
  void _openBookings([ProviderBookingFilter filter = ProviderBookingFilter.all]) {
    Get.put(ProviderBookingsController()).preselect(filter);
    navController.changeIndex(2);
  }

  /// "from €25 / day", "€220 / person"…
  String _priceLabel(ListingCard s) {
    final unit = s.price.unitLabel;
    final from = s.kind == ServiceKind.skiHire || s.kind == ServiceKind.restaurant || s.kind == ServiceKind.massage;
    if (s.price.amount <= 0) return 'No price yet';
    return '${from ? 'from ' : ''}${euroLabel(s.price.amount)}'
        '${unit.isEmpty ? '' : ' / $unit'}';
  }

  void _onDelete(ListingCard card) {
    String? failure;
    DeleteDialogService.show(
      context: context,
      title: card.kind == ServiceKind.restaurant ? 'Delete restaurant' : 'Delete service',
      message: 'Delete "${card.title}"? Guests will no longer see it.',
      failureMessage: () => failure,
      onDelete: () async {
        final r = await homeController.deleteListing(card);
        failure = r.isSuccess ? null : r.errorMessage;
        return r.isSuccess;
      },
    );
  }

  Widget _bookingCard(Booking b) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: ProviderBookingTile(
      booking: b,
      onTap: () async {
        await openProviderBooking(b);
        homeController.refreshData();
      },
    ),
  );

  Widget _emptyServices(ServiceKind? kind) => ProviderEmptyState(
    icon: Icons.storefront_outlined,
    title: 'No services yet',
    message: 'Add your first ${(kind?.label ?? 'service').toLowerCase()} listing so guests can book it.',
    actionLabel: 'Add a service',
    onAction: () => navController.changeIndex(1),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: CollapsingHeaderLayout(
        expandedHeight: ProviderProfile.expandedHeight,
        collapsedHeight: ProviderProfile.collapsedHeight,
        header: (_, t) => ProviderProfile(
          t: t,
          onProfileTap: () => navController.changeIndex(4),
          onNotificationTap: () => Get.toNamed(Routes.notification),
        ),
        body: (_, insets) => GetBuilder<ProviderHomeController>(
          builder: (c) {
            if (authController.userModel == null || c.isLoading) {
              return ProviderHomeShimmer(insets: insets);
            }
            final d = c.dashboard;
            if (d == null) {
              return RefreshIndicator(
                color: AppColors.primary_1,
                edgeOffset: CollapsingHeaderLayout.refreshEdge(context),
                onRefresh: c.refreshData,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16) + insets,
                  children: [
                    ProviderEmptyState(
                      icon: Icons.cloud_off_rounded,
                      title: "Couldn't load your dashboard",
                      message: c.errorMessage ?? 'Check your connection and try again.',
                      actionLabel: 'Try again',
                      onAction: c.fetchProviderHomeData,
                    ),
                  ],
                ),
              );
            }

            final counts = d.bookings;
            final money = d.earnings;
            return RefreshIndicator(
              color: AppColors.primary_1,
              edgeOffset: CollapsingHeaderLayout.refreshEdge(context),
              onRefresh: c.refreshData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24) + insets,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Counts ─────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: ProviderStatCard(
                            icon: Icons.mark_email_unread_outlined,
                            label: 'Requests',
                            value: '${counts.requests}',
                            highlight: counts.requests > 0,
                            onTap: () => _openBookings(ProviderBookingFilter.requests),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ProviderStatCard(
                            icon: Icons.event_rounded,
                            label: 'Upcoming',
                            value: '${counts.upcoming}',
                            onTap: () => _openBookings(ProviderBookingFilter.upcoming),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ProviderStatCard(
                            icon: Icons.timelapse_rounded,
                            label: 'In progress',
                            value: '${counts.inProgress}',
                            onTap: () => _openBookings(ProviderBookingFilter.active),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ── Earnings ───────────────────────────────
                    _EarningsCard(
                      earnings: money,
                      completed: counts.completed,
                      cancelled: counts.cancelled,
                      // Late fees exist only for rentals (ski hire, transport).
                      showLateFees: c.kind == null || c.kind == ServiceKind.skiHire || c.kind == ServiceKind.transport,
                      // Balance changes after a withdrawal: refresh on the way back.
                      onTap: () => Get.toNamed(Routes.userWallet)?.then((_) => c.refreshData()),
                    ),

                    // ── Today ──────────────────────────────────
                    if (d.today.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      ProviderSectionHeader(title: 'Today', count: d.today.length),
                      const SizedBox(height: 8),
                      for (final b in d.today) _bookingCard(b),
                    ],

                    const SizedBox(height: 24),

                    // ── My services ────────────────────────────
                    ProviderSectionHeader(
                      title: 'My services',
                      count: d.listings > 0 ? d.listings : null,
                      actionLabel: c.services.isEmpty ? null : 'See all',
                      onAction: () => navController.changeIndex(1),
                    ),
                    const SizedBox(height: 8),
                    c.services.isEmpty
                        ? _emptyServices(c.kind)
                        : SizedBox(
                            height: 259,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              clipBehavior: Clip.none,
                              itemCount: c.services.length,
                              itemBuilder: (_, i) {
                                final s = c.services[i];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: SizedBox(
                                    width: 280,
                                    child: MyServiceCard(
                                      image: s.thumbnail ?? '',
                                      title: s.title,
                                      rating: s.rating.average,
                                      reviews: s.rating.count,
                                      location: s.serviceArea ?? '',
                                      packageType: s.isActive ? s.passType?.label : 'Hidden',
                                      status: _priceLabel(s),
                                      onDelete: () => _onDelete(s),
                                      // Editing lives on the Services tab.
                                      onEdit: () => navController.changeIndex(1),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                    const SizedBox(height: 24),

                    // ── Recent bookings ────────────────────────
                    ProviderSectionHeader(
                      title: 'Recent bookings',
                      actionLabel: d.recent.isEmpty ? null : 'See all',
                      onAction: _openBookings,
                    ),
                    const SizedBox(height: 8),
                    if (d.recent.isEmpty)
                      const ProviderEmptyState(
                        icon: Icons.event_available_outlined,
                        title: 'No bookings yet',
                        message: 'New bookings will show up here.',
                      )
                    else
                      for (final b in d.recent) _bookingCard(b),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Balance (withdrawable) plus earned / pending / fees / late fees due.
class _EarningsCard extends StatelessWidget {
  const _EarningsCard({
    required this.earnings,
    required this.completed,
    required this.cancelled,
    required this.onTap,
    this.showLateFees = true,
  });

  final Earnings earnings;
  final int completed;
  final int cancelled;
  final VoidCallback onTap;
  final bool showLateFees;

  @override
  Widget build(BuildContext context) {
    final e = earnings;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.account_balance_wallet_outlined, size: 18, color: Color(0xFF9A7A12)),
                  const SizedBox(width: 8),
                  Text('Balance', style: AppTextStyle.p_medium_12(color: AppColors.textSecondary)),
                  const Spacer(),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        euroLabel(e.balance),
                        style: AppTextStyle.h3_semibold_20(color: AppColors.textPrimary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(height: 1, color: AppColors.border),
              ),
              Row(
                children: [
                  _figure('Earned', euroLabel(e.earned)),
                  _figure('Pending', euroLabel(e.pending)),
                  _figure('Platform fees', euroLabel(e.platformFees)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _figure('Completed', '$completed'),
                  _figure('Cancelled', '$cancelled'),
                  if (showLateFees || e.lateFeesDue > 0)
                    _figure('Late fees due', euroLabel(e.lateFeesDue), warn: e.lateFeesDue > 0)
                  else
                    const Spacer(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _figure(String label, String value, {bool warn = false}) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            maxLines: 1,
            style: AppTextStyle.sub_h3_semibold_14(color: warn ? const Color(0xFFB45309) : AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyle.p_regular_12(color: AppColors.textTertiary),
        ),
      ],
    ),
  );
}
