import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/widgets/custom_image_container.dart';
import 'package:intl/intl.dart';

import '../../../../core/controllers/nav_controller.dart';
import '../../../../core/widgets/custom_appbar.dart';
import '../contollers/hire_booking_single_controller.dart';

class UserHireBookingInfo extends StatefulWidget {
  const UserHireBookingInfo({super.key});

  @override
  State<UserHireBookingInfo> createState() => _UserHireBookingInfoState();
}

class _UserHireBookingInfoState extends State<UserHireBookingInfo> {
  final SingleHireBookingItem hireController=Get.put(SingleHireBookingItem());
  late final String bookingId;

  @override
  void initState() {
    super.initState();


    /// Get bookingId from arguments
    final args = Get.arguments;
    bookingId = args["bookingId"];

    ///  Call API
    hireController.fetchBooking(bookingId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F7F3),
      appBar: CustomAppBar(title: "Hire booking details",onBackPressed: (){
        Get.back();
      },),
      body: GetBuilder<SingleHireBookingItem>(
        builder: (controller) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.errorMessage != null) {
            return Center(child: Text(controller.errorMessage!));
          }

          final data = controller.getSingleHire?.data;

          if (data == null) {
            return const Center(child: Text("No booking data found"));
          }

          return Stack(
            children: [
              _buildMainContent(controller),
              _buildSlidingPanel(controller),
            ],
          );
        },
      ),
    );
  }

  /// ---------------- MAIN CONTENT ----------------
  Widget _buildMainContent(SingleHireBookingItem controller) {
    final data = controller.getSingleHire!.data!;
    final product = data.product;


    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Image.network(
                product?.thumbnail ?? "",
                width: double.infinity,
                height: 160.h,
                fit: BoxFit.cover,
              ),
            ),

            SizedBox(height: 16.h),

            // Title
            Text(
              product?.title ?? "",
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 6.h),


            SizedBox(height: 12.h),

            // Booking Status
            _buildStatusBadge(data.bookingStatus ?? ""),

            SizedBox(height: 20.h),

            // Hired Items
            Text(
              "Hired Items",
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),

            SizedBox(height: 10.h),

            Wrap(
              spacing: 10.w, // horizontal spacing
              runSpacing: 10.h, // vertical spacing
              children: [
                for (var item in data.bookingItems ?? [])
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomCachedImage(
                          imageUrl: item.item?.productPhoto ?? "",
                             width: 40.w,
                             height: 40.h,
                             fit: BoxFit.cover,
                        ),
                        SizedBox(width: 8.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.item?.productName ?? "",
                              style: TextStyle(
                                  fontSize: 14.sp, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              "Qty: ${item.quantity ?? 0}",
                              style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),








          ],
        ),
      ),
    );
  }

  /// ---------------- SLIDING PANEL ----------------
  Widget _buildSlidingPanel(SingleHireBookingItem controller) {
    final data = controller.getSingleHire!.data!;
    final product = data.product;

    return DraggableScrollableSheet(
      initialChildSize: 0.25,
      minChildSize: 0.25,
      maxChildSize: 0.75,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 10,
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.all(16.w),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              _infoRow("Start", _formatDateTime(data.startDateAndTime)),
              _infoRow("End", _formatDateTime(data.endDateAndTime)),
              _infoRow("Time Slot", data.timeLabel ?? "-"),
              _infoRow("Location", product?.serviceArea ?? "N/A"),
              _infoRow("Booking ID", data.id ?? "N/A"),
              _infoRow("Total Paid", "₹ ${data.totalPrice ?? 0}"),

              if (data.overTimeAmount != null)
                _infoRow(
                  "Overtime",
                  "₹ ${data.overTimeAmount!.toStringAsFixed(2)}",
                ),

              _infoRow("Booked On", _formatDateTime(data.createdAt)),

              SizedBox(height: 24.h),
            ],
          ),
        );
      },
    );
  }

  /// ---------------- STATUS BADGE ----------------
  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'completed':
        color = Colors.green;
        break;
      case 'active':
        color = Colors.orange;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  /// ---------------- HELPERS ----------------
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  /// data time formater

  String _formatDateTime(DateTime? date) {
    if (date == null) return "-";

    // Get the day suffix
    String daySuffix(int day) {
      if (day >= 11 && day <= 13) return 'th';
      switch (day % 10) {
        case 1:
          return 'st';
        case 2:
          return 'nd';
        case 3:
          return 'rd';
        default:
          return 'th';
      }
    }

    String suffix = daySuffix(date.day);

    // Format: Tue, 2nd Nov, 2025 03:30 PM
    String formattedDate = DateFormat('EEE, d MMM, yyyy hh:mm a').format(date);

    // Add suffix to day
    formattedDate = formattedDate.replaceFirst(
      date.day.toString(),
      '${date.day}$suffix',
    );

    return formattedDate;
  }









}
