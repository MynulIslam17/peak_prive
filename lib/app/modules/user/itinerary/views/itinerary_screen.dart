import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text-style.dart';
import '../../../../core/widgets/shimmer/booking_Item_shimmer.dart';
import '../../../../routes/app_routes.dart';
import '../../../booking/widgets/booking_list_card.dart';
import '../controllers/itinerary_controller.dart';

/// Itinerary: running and upcoming bookings of every service, by day.
class ItineraryScreen extends StatefulWidget {
  const ItineraryScreen({super.key});

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  late final ItineraryController c;
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    c = Get.isRegistered<ItineraryController>() ? Get.find() : Get.put(ItineraryController());
    c.load();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) c.loadMore();
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  String _dayTitle(DateTime? d) {
    if (d == null) return 'Date to be confirmed';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = d.difference(today).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff < 0) return 'Ongoing · since ${DateFormat('d MMM').format(d)}';
    return DateFormat('EEEE, d MMMM').format(d);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: AppColors.scaffold,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('My itinerary', style: AppTextStyle.sub_h2_medium_16()),
      ),
      body: GetBuilder<ItineraryController>(builder: (c) {
        Widget child;
        final days = c.days;
        if (days.isEmpty && c.isLoading) {
          child = const BookingListSkeleton(dayHeaders: true);
        } else if (days.isEmpty && c.errorMessage != null) {
          child = BookingStateMessage(
            icon: Icons.wifi_off_rounded,
            title: 'Something went wrong',
            message: c.errorMessage!,
            actionLabel: 'Try again',
            onAction: c.load,
          );
        } else if (days.isEmpty) {
          child = const BookingStateMessage(
            icon: Icons.luggage_outlined,
            title: 'Nothing planned yet',
            message: 'Your upcoming and ongoing bookings will appear here, day by day.',
          );
        } else {
          child = ListView(
            controller: _scroll,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
            children: [
              for (final d in days) ...[
                Padding(
                  padding: EdgeInsets.only(top: 14.h, bottom: 8.h),
                  child: Text(_dayTitle(d.day), style: AppTextStyle.sub_h3_semibold_14(color: AppColors.textSecondary)),
                ),
                for (final b in d.bookings) ...[
                  BookingListCard(
                    booking: b,
                    showKind: true,
                    onTap: () => Get.toNamed(Routes.bookingDetails, arguments: {'bookingId': b.id, 'booking': b}),
                  ),
                  SizedBox(height: 12.h),
                ],
              ],
              if (c.isLoadingMore) const BookingCardSkeleton(),
            ],
          );
        }
        return RefreshIndicator(color: AppColors.primary_1, onRefresh: c.load, child: child);
      }),
    );
  }
}
