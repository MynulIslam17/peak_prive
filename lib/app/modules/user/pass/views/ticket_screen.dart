import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/app_colors.dart';
import 'package:harry_service_app/app/core/utils/app_toast.dart';
import 'package:intl/intl.dart';
import 'package:harry_service_app/app/core/widgets/custom_image_container.dart';

import '../../../../core/widgets/checkout_parts.dart';
import '../../../../data/api/peak_api.dart';

import '../../../../core/constants/text-style.dart';
import '../../../../routes/app_routes.dart';
import '../pdf_service/ticket_pdf.dart';
import '../../../../core/widgets/shimmer/skeleton.dart';

/// Ski pass ticket after checkout (or from a booking).
///
/// Arguments: `{'booking': Booking}` or `{'bookingId': String}`.
class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  Booking? _booking;
  String? _bookingId;
  String? _error;
  bool _downloading = false;

  /// Opened from a booking's details (customer or provider): back goes there.
  /// Right after checkout there is nothing to go back to, so "Go Home" is
  /// offered instead (customer app only).
  bool _fromBooking = false;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is Map) {
      _fromBooking = args['fromBooking'] == true;
      final b = args['booking'];
      if (b is Booking) _booking = b;
      final id = args['bookingId'];
      _bookingId = id is String && id.isNotEmpty ? id : _booking?.id;
    }
    if (_booking == null && _bookingId != null) _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    final r = await Get.find<PeakApi>().bookings.detail(_bookingId!);
    if (!mounted) return;
    setState(() {
      _booking = r.data;
      _error = r.isSuccess ? null : r.errorMessage;
    });
  }

  /// Resort day of the pass ("Fri, 20 Dec 2026").
  String _dateLabel(Booking b) {
    final day = DateTime.tryParse(b.schedule.date ?? '') ?? b.schedule.startAt;
    return day == null ? '—' : DateFormat('EEE, d MMM yyyy').format(day);
  }

  String _ticketId(Booking b) => b.ticketNumber ?? bookingRefOf(b.id);

  Future<void> _download(Booking b) async {
    if (_downloading) return;
    setState(() => _downloading = true);
    try {
      await PdfHelper.generateTicket(
        title: b.listing.title,
        date: _dateLabel(b),
        time: '',
        person: '${b.people ?? 1}',
        ticketId: _ticketId(b),
        imageUrl: b.listing.thumbnail,
        total: checkoutEuro(b.total),
      );
      showAppToast(
        type: ToastType.success,
        title: "Ticket ready",
        message: "Your ski pass ticket has been saved and opened.",
      );
    } catch (_) {
      showAppToast(
        type: ToastType.error,
        title: "Download failed",
        message: "We couldn't create your ticket. Please try again.",
      );
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = _booking;
    if (b == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: _fromBooking,
          title: const Text('Ticket'),
          centerTitle: true,
        ),
        body: _bookingId == null
            ? CheckoutStateView(
                icon: Icons.link_off_rounded,
                title: 'Ticket not found',
                message: 'Open it from My bookings.',
                actionLabel: 'Go home',
                onAction: _fromBooking ? () => Get.back() : () => Get.offAllNamed(Routes.bottomNav),
              )
            : _error == null
            ? const TicketSkeleton()
            : CheckoutStateView(
                icon: Icons.wifi_off_rounded,
                title: 'Could not load your ticket',
                message: _error!,
                actionLabel: 'Try again',
                onAction: _load,
              ),
      );
    }
    return _buildTicket(b);
  }

  Widget _buildTicket(Booking b) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: _fromBooking
            ? IconButton(
                tooltip: 'Back',
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.black_1),
              )
            : null,
        title: Text("Ticket", style: AppTextStyle.h3_semibold_20(color: AppColors.black_1)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Column(
          children: [
            // --- Ticket Card Start ---
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primary_3.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.primary_3.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Image Section
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                    child: Stack(
                      children: [
                        CustomCachedImage(
                          width: double.infinity,
                          height: 180,
                          borderRadius: 12,
                          imageUrl: b.listing.thumbnail,
                          fit: BoxFit.cover,
                        ),

                        // VIP Badge
                        Positioned(
                          top: 12.h,
                          left: 12.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: AppColors.secendary,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.stars, color: Colors.white, size: 14.sp),
                                SizedBox(width: 4.w),
                                Text(_ticketId(b), style: AppTextStyle.c_regular_10(color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 2. Info Section
                  Padding(
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Pass Title ---
                        Text(b.listing.title, style: AppTextStyle.h1_medium_24(color: AppColors.black_1)),
                        SizedBox(height: 12.h),

                        // --- Date & Time ---
                        _buildInfoItem(label: "Date", value: _dateLabel(b), icon: Icons.calendar_today_outlined),
                        SizedBox(height: 16.h),

                        // --- Person ---
                        _buildInfoItem(label: "Person", value: "${b.people ?? 1}", icon: Icons.person_outline),
                        SizedBox(height: 16.h),
                        _buildInfoItem(
                          label: "Ticket number",
                          value: _ticketId(b),
                          icon: Icons.confirmation_number_outlined,
                        ),
                        SizedBox(height: 16.h),
                        _buildInfoItem(
                          label: "Total paid",
                          value: checkoutEuro(b.total),
                          icon: Icons.payments_outlined,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- Ticket Card End ---
            SizedBox(height: 40.h),

            // --- Action Buttons ---
            Row(
              children: [
                // Download Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _downloading ? null : () => _download(b),
                    icon: _downloading
                        ? SizedBox(
                            width: 18.sp,
                            height: 18.sp,
                            child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Icon(Icons.file_download_outlined, color: Colors.white, size: 20.sp),
                    label: Text(
                      _downloading ? "Preparing…" : "Get Ticket",
                      style: AppTextStyle.sub_h3_medium_14(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary_1,
                      disabledBackgroundColor: AppColors.primary_1.withValues(alpha: 0.7),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      elevation: 0,
                    ),
                  ),
                ),
                if (!_fromBooking) ...[
                  SizedBox(width: 15.w),
                  // Home Button (after checkout only)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Get.offAllNamed(Routes.bottomNav);
                      },
                      icon: Icon(Icons.home_outlined, color: AppColors.primary_1, size: 20.sp),
                      label: Text("Go Home", style: AppTextStyle.sub_h3_medium_14(color: AppColors.primary_1)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary_1),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Reusable Info Widget
  Widget _buildInfoItem({required String label, required String value, required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyle.p_regular_12(color: AppColors.black_3)),
        SizedBox(height: 6.h),
        Row(
          children: [
            Icon(icon, color: AppColors.black_1, size: 18.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(value, style: AppTextStyle.sub_h3_medium_14(color: AppColors.black_1)),
            ),
          ],
        ),
      ],
    );
  }
}

/// Short booking reference when there is no ticket number ("#AF3CB").
String bookingRefOf(String id) =>
    id.length <= 6 ? '#${id.toUpperCase()}' : '#${id.substring(id.length - 6).toUpperCase()}';
