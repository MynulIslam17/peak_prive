import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/app_colors.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/app_toast.dart';
import '../../../data/api/peak_api.dart';
import '../controller/notification_controller.dart';
import '../../../core/widgets/shimmer/skeleton.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final controller = NotificationController.ensure();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    // After the first frame: update() must not run mid-build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) controller.fetch();
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

  Future<void> _markAll() async {
    if (!await controller.markAllRead()) {
      AppToast.error("Couldn't mark them as read. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NotificationController>(
      builder: (c) {
        return Scaffold(
          backgroundColor: AppColors.scaffold,
          appBar: AppBar(
            backgroundColor: AppColors.scaffold,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: false,
            leading: IconButton(
              tooltip: 'Back',
              onPressed: Get.back,
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 20, color: AppColors.textPrimary),
            ),
            title: Text("Notifications",
                style: AppTextStyle.sub_h1_medium_18(color: AppColors.textPrimary)),
            actions: [
              if (c.unread > 0)
                TextButton(
                  onPressed: _markAll,
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFF9A7A12)),
                  child: const Text('Mark all read'),
                ),
            ],
          ),
          body: _body(c),
        );
      },
    );
  }

  Widget _body(NotificationController c) {
    if (c.isLoading && c.items.isEmpty) return _buildShimmerNotification();
    if (c.errorMessage != null && c.items.isEmpty) {
      return _buildError(c.errorMessage!, c.fetch);
    }
    return RefreshIndicator(
      color: AppColors.primary_1,
      onRefresh: c.fetch,
      child: c.items.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [_buildEmptyNotification()],
            )
          : ListView.separated(
              controller: _scroll,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: c.items.length + (c.hasMore ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                if (index >= c.items.length) {
                  return const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: _NotificationSkeleton());
                }
                final n = c.items[index];
                return _NotificationCard(
                  notification: n,
                  time: n.createdAt == null ? '' : _relative(n.createdAt!),
                  onTap: () => c.open(n),
                  onReview: () => c.review(n),
                );
              },
            ),
    );
  }

  Widget _buildError(String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 40, color: AppColors.textTertiary),
            const SizedBox(height: 12),
            Text("Couldn't load notifications", style: AppTextStyle.sub_h3_semibold_14()),
            const SizedBox(height: 4),
            Text(message,
                textAlign: TextAlign.center,
                style: AppTextStyle.p_regular_12(color: AppColors.textTertiary)),
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }

  static String _relative(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.isNegative) return 'Just now';
    if (d.inMinutes < 1) return 'Just now';
    if (d.inMinutes < 60) return '${d.inMinutes} min ago';
    if (d.inHours < 24) return '${d.inHours} h ago';
    if (d.inDays < 7) return '${d.inDays} d ago';
    // Add the year when it isn't this year: "24 Nov 2025", not "24 Nov".
    final sameYear = t.year == DateTime.now().year;
    return DateFormat(sameYear ? 'd MMM' : 'd MMM yyyy').format(t);
  }

  Widget _buildEmptyNotification() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 120, 40, 40),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: const BoxDecoration(
              color: Color(0xFFFBF3DC),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none_rounded,
                size: 40, color: Color(0xFF9A7A12)),
          ),
          const SizedBox(height: 20),
          Text("You're all caught up",
              textAlign: TextAlign.center,
              style: AppTextStyle.sub_h1_medium_18()),
          const SizedBox(height: 8),
          Text(
            "Booking and payment updates will show up here.",
            textAlign: TextAlign.center,
            style: AppTextStyle.sub_h3_regular_14(
                color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  /// Shaped like [_NotificationCard]: icon square, title + time, text.
  Widget _buildShimmerNotification() {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: 7,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => const _NotificationSkeleton(),
    );
  }
}

class _NotificationSkeleton extends StatelessWidget {
  const _NotificationSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const SkeletonShimmer(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: 40, height: 40, radius: 12),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(child: SkeletonBox(height: 13)),
                    SizedBox(width: 40),
                    SkeletonBox(width: 40, height: 10),
                  ]),
                  SizedBox(height: 10),
                  SkeletonBox(width: double.infinity, height: 11),
                  SizedBox(height: 6),
                  SkeletonBox(width: 150, height: 11),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final String time;
  final VoidCallback onTap;
  final VoidCallback onReview;

  const _NotificationCard({
    required this.notification,
    required this.time,
    required this.onTap,
    required this.onReview,
  });

  /// "New Ski_Hire booking … Total: 20." → "New Ski Hire booking … Total: €20."
  static String _tidy(String s) => s
      .replaceAll('_', ' ')
      .replaceAllMapped(RegExp(r'Total:\s*(\d+(?:\.\d+)?)'),
          (m) => 'Total: €${m.group(1)}');

  String get _event => notification.event ?? '';

  bool get _negative {
    if (_event.isNotEmpty) {
      return const {
        'booking.rejected',
        'booking.expired',
        'booking.cancelled',
        'booking.late_fee_due',
        'booking.no_show',
        'booking.dispute_lost',
        'withdraw.rejected',
      }.contains(_event);
    }
    final t = notification.title.toLowerCase();
    return t.contains('reject') || t.contains('declin') || t.contains('cancel');
  }

  IconData get _icon {
    switch (_event) {
      case 'booking.approved':
      case 'booking.confirmed':
      case 'booking.completed':
        return Icons.check_circle_outline_rounded;
      case 'booking.rejected':
      case 'booking.expired':
      case 'booking.cancelled':
        return Icons.cancel_outlined;
      case 'booking.handed_over':
        return Icons.handshake_outlined;
      case 'booking.no_show':
        return Icons.person_off_outlined;
      case 'booking.late_fee_due':
      case 'booking.late_fee_paid':
        return Icons.more_time_rounded;
      case 'booking.new':
      case 'booking.requested':
        return Icons.event_available_outlined;
      case 'withdraw.requested':
      case 'withdraw.paid':
      case 'withdraw.rejected':
        return Icons.account_balance_outlined;
    }
    final t = '${notification.title} ${notification.description}'.toLowerCase();
    if (t.contains('withdraw')) return Icons.account_balance_outlined;
    if (t.contains('reject') || t.contains('cancel')) {
      return Icons.cancel_outlined;
    }
    if (t.contains('approved')) return Icons.check_circle_outline_rounded;
    if (t.contains('booking')) return Icons.event_available_outlined;
    if (t.contains('payment') || t.contains('paid')) {
      return Icons.payments_outlined;
    }
    return Icons.notifications_none_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final isRead = notification.isRead;
    final fg = _negative ? AppColors.error : const Color(0xFF9A7A12);
    final bg = _negative ? const Color(0xFFFBEAEA) : const Color(0xFFFBF3DC);
    final opensBooking = NotificationController.routeFor(notification) != null;

    return Material(
      color: isRead ? Colors.white : const Color(0xFFFFFCF2),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isRead ? AppColors.border : const Color(0xFFF0DFA8),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: bg, borderRadius: BorderRadius.circular(12)),
                child: Icon(_icon, size: 20, color: fg),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _tidy(notification.title),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyle.sub_h3_semibold_14(
                                color: AppColors.textPrimary),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(time,
                            style: AppTextStyle.p_regular_12(
                                color: AppColors.textTertiary)),
                        if (!isRead) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary_1,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (notification.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        _tidy(notification.description),
                        style: AppTextStyle.sub_h3_regular_14(
                            color: AppColors.textSecondary),
                      ),
                    ],
                    if (opensBooking && notification.canReview) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 34,
                        child: FilledButton.icon(
                          onPressed: onReview,
                          icon: const Icon(Icons.star_rounded, size: 16),
                          label: const Text('Leave a review'),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFFBF3DC),
                            foregroundColor: const Color(0xFF9A7A12),
                            textStyle: AppTextStyle.p_medium_12(),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            shape: const StadiumBorder(),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ] else if (opensBooking) ...[
                      const SizedBox(height: 6),
                      Text('View booking',
                          style: AppTextStyle.p_medium_12(
                              color: const Color(0xFF9A7A12))),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
