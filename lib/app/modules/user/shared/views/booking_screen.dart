import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text-style.dart';
import '../../../../core/controllers/nav_controller.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/widgets/shimmer/booking_Item_shimmer.dart';
import '../../../../data/api/peak_api.dart';
import '../../../../routes/app_routes.dart';
import '../../../booking/controllers/my_bookings_controller.dart';
import '../../../booking/widgets/booking_list_card.dart';
import '../../../booking/widgets/review_dialog.dart';
import '../../../../core/widgets/shimmer/skeleton.dart';
import '../../../../core/widgets/collapsing_header.dart';

/// Bookings tab of the customer bottom nav (`/booking/my`), filtered by the
/// service the user is browsing.
class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> with SingleTickerProviderStateMixin {
  static const _tabs = MyBookingsController.tabs;

  late final TabController _tabController;
  late final List<ScrollController> _scrolls;
  final _nav = Get.find<NavController>();
  late final MyBookingsController _c;

  @override
  void initState() {
    super.initState();
    _c = Get.isRegistered<MyBookingsController>() ? Get.find() : Get.put(MyBookingsController());
    _c.setKind(ServiceKind.parse(_nav.getServiceType));
    _tabController = TabController(length: _tabs.length, vsync: this)..addListener(_onTab);
    _scrolls = [
      for (final t in _tabs)
        ScrollController()..addListener(() {
          final sc = _scrolls[_tabs.indexOf(t)];
          if (sc.hasClients && sc.position.pixels >= sc.position.maxScrollExtent - 200) _c.loadMore(t);
        }),
    ];
    _c.load(_tabs.first);
    // The bottom nav keeps this screen alive; follow the service the user
    // switches to on the home screen.
    _nav.addListener(_syncKind);
  }

  void _syncKind() {
    final k = ServiceKind.parse(_nav.getServiceType);
    if (k == _c.kind) return;
    _c.setKind(k);
    _c.load(_tabs[_tabController.index]);
  }

  void _onTab() {
    if (_tabController.indexIsChanging) return;
    _c.ensureLoaded(_tabs[_tabController.index]);
  }

  @override
  void dispose() {
    _nav.removeListener(_syncKind);
    _tabController.dispose();
    for (final s in _scrolls) {
      s.dispose();
    }
    super.dispose();
  }

  void _open(Booking b) => Get.toNamed(Routes.bookingDetails, arguments: {'bookingId': b.id, 'booking': b});

  Future<void> _review(Booking b) async {
    final r = await ReviewDialog.show(
      context,
      title: b.listing.title,
      onSubmit: (rating, comment) => _c.review(b, rating, comment),
    );
    if (r != null && mounted) {
      showAppToast(
        type: r.ok ? ToastType.success : ToastType.info,
        title: r.ok ? 'Thank you' : 'Already reviewed',
        message: r.message,
      );
    }
  }

  Widget _list(BookingTab tab, ScrollController sc, EdgeInsets insets) {
    return GetBuilder<MyBookingsController>(
      builder: (c) {
        final s = c.stateOf(tab);
        Widget child;
        if (s.items.isEmpty && s.error != null && !s.isLoading) {
          child = BookingStateMessage(
            icon: Icons.wifi_off_rounded,
            title: 'Something went wrong',
            message: s.error!,
            actionLabel: 'Try again',
            onAction: () => c.load(tab),
            insets: insets,
          );
        } else if (s.items.isEmpty && (s.isLoading || !s.fetched)) {
          child = BookingListSkeleton(insets: insets);
        } else if (s.items.isEmpty) {
          child = BookingStateMessage(
            icon: switch (tab) {
              BookingTab.past => Icons.task_alt_rounded,
              BookingTab.cancelled => Icons.event_busy_rounded,
              BookingTab.active => Icons.play_circle_outline_rounded,
              _ => Icons.event_available_rounded,
            },
            title: 'No ${tab.label.toLowerCase()} bookings',
            message: switch (tab) {
              BookingTab.upcoming => 'When you book a service, it will show up here.',
              BookingTab.active => 'Bookings that are happening right now appear here.',
              BookingTab.past => "Bookings you've finished will appear here.",
              _ => 'Cancelled and declined bookings appear here.',
            },
            insets: insets,
          );
        } else {
          child = ListView.separated(
            controller: sc,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 24.h) + insets,
            itemCount: s.items.length + (s.isLoadingMore ? 1 : 0),
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (_, i) {
              if (i >= s.items.length) {
                return const SkeletonLoadMore();
              }
              final b = s.items[i];
              return BookingListCard(
                booking: b,
                showKind: c.kind == null,
                onTap: () => _open(b),
                onReview: c.canReview(b) ? () => _review(b) : null,
              );
            },
          );
        }
        return RefreshIndicator(
          color: AppColors.primary_1,
          edgeOffset: CollapsingHeaderLayout.refreshEdge(context),
          onRefresh: () => c.load(tab),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: CollapsingHeaderLayout(
        expandedHeight: 76,
        collapsedHeight: 52,
        header: (_, t) => LargeTitleHeader(title: 'My Bookings', t: t),
        bottom: _tabBar(),
        bottomHeight: 64,
        body: (_, insets) => TabBarView(
          controller: _tabController,
          children: [for (var i = 0; i < _tabs.length; i++) _list(_tabs[i], _scrolls[i], insets)],
        ),
      ),
    );
  }

  Widget _tabBar() {
    return Container(
      height: 48,
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(color: const Color(0xFFF1ECE2), borderRadius: BorderRadius.circular(14.r)),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.textOnPrimary,
        labelStyle: AppTextStyle.sub_h3_semibold_14(),
        unselectedLabelColor: AppColors.textTertiary,
        unselectedLabelStyle: AppTextStyle.sub_h3_medium_14(),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        labelPadding: EdgeInsets.symmetric(horizontal: 2.w),
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        tabs: [
          for (final t in _tabs)
            Tab(
              child: FittedBox(fit: BoxFit.scaleDown, child: Text(t.label)),
            ),
        ],
      ),
    );
  }
}
