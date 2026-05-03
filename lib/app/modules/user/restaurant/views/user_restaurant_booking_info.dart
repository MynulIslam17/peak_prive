import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_appbar.dart';
import '../controllers/restaurant_booking_single_controler.dart';
import '../models/get_single_restarant.dart';

class UserRestaurantBookingInfo extends StatefulWidget {
  const UserRestaurantBookingInfo({super.key});

  @override
  State<UserRestaurantBookingInfo> createState() =>
      _UserRestaurantBookingInfoState();
}

class _UserRestaurantBookingInfoState extends State<UserRestaurantBookingInfo> {
  final SingleRestaurantBookingItem controller =
  Get.put(SingleRestaurantBookingItem());
  late final String bookingId;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args != null && args['bookingId'] != null) {
      bookingId = args['bookingId'];
      controller.fetchBooking(bookingId);
    }
  }

  /// ---------------- DATE FORMAT ----------------
  String _formatDate(DateTime? date) {
    if (date == null) return "-";
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
    final suffix = daySuffix(date.day);
    final formatted = DateFormat('EEE, d MMM yyyy').format(date);
    return formatted.replaceFirst(date.day.toString(), '${date.day}$suffix');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F7F3),
     appBar: CustomAppBar(title: "Restaurant booking details",onBackPressed: (){
      Get.back();
    },),
      body: GetBuilder<SingleRestaurantBookingItem>(
        builder: (_) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary_1,));
          }

          if (controller.errorMessage != null) {
            return Center(child: Text(controller.errorMessage!));
          }

          final data = controller.getSingleRestaurant?.data;
          if (data == null) {
            return const Center(child: Text("No booking data found"));
          }

          return Stack(
            children: [
              _buildMainContent(data),
              _buildSlidingPanel(data),
            ],
          );
        },
      ),
    );
  }

  /// ---------------- MAIN CONTENT ----------------
  Widget _buildMainContent(RestaurantBookingData data) {
    final product = data.product;

    return SingleChildScrollView(
      padding:
      EdgeInsets.only(left: 16.w, right: 16.w, top: 16.h, bottom: 120.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Restaurant Image
          ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Image.network(
              product?.thumbnail ?? "",
              height: 180.h,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 180.h,
                color: Colors.grey[300],
                child: const Icon(Icons.restaurant, size: 40),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Restaurant Name
          Text(
            product?.title ?? "Restaurant Name",
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6.h),

          // Category & Food Type & Service Area
          Text(
            "${product?.category?.name ?? "Category"} • ${product?.foodType ?? "Food Type"} • ${product?.serviceArea ?? "Location"}",
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
          ),
          SizedBox(height: 12.h),

          // Description
          if (product?.description != null)
            Text(
              product!.description!,
              style: TextStyle(fontSize: 13.sp, color: Colors.grey[800]),
            ),
          SizedBox(height: 24.h),

          // Booked Items Section
          Text(
            "Booked Seats/Items",
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 12.h),

          if (data.bookingItems != null && data.bookingItems!.isNotEmpty)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.bookingItems!.length,
              separatorBuilder: (_, __) => SizedBox(height: 10.h),
              itemBuilder: (context, index) {
                final bookingItem = data.bookingItems![index];
                final seat = bookingItem.item; // nested seat object

                return Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.network(
                          seat?.photo ?? "",
                          width: 50.w,
                          height: 50.h,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                          const Icon(Icons.chair),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              seat?.seat ?? "Table/Seat",
                              style: TextStyle(
                                  fontSize: 15.sp, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              "Price: €${seat?.price ?? 0}",
                              style: TextStyle(
                                  fontSize: 12.sp, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: const Color(0xffF9F7F3),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          "Qty: ${bookingItem.quantity ?? 0}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13.sp),
                        ),
                      ),
                    ],
                  ),
                );
              },
            )
          else
            const Text("No items found in this booking."),
        ],
      ),
    );
  }

  /// ---------------- SLIDING PANEL ----------------
  Widget _buildSlidingPanel(RestaurantBookingData data) {
    final slotDisplay = data.slots != null && data.slots!.isNotEmpty
        ? data.slots!.map((s) => "${s.startTime} - ${s.endTime}").join(", ")
        : "No slot selected";

    return DraggableScrollableSheet(
      initialChildSize: 0.18,
      minChildSize: 0.18,
      maxChildSize: 0.55,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                "Booking & Payment Info",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15.h),
              _infoRow("Booking Date", _formatDate(data.date)),
              _infoRow("Time Slot", slotDisplay),
              _infoRow(
                  "Service Fee",
                  "${data.product?.serviceFee ?? 0}%"
              ),
              const Divider(),
              _infoRow("Total Paid", "€ ${data.totalPrice ?? 0}", isBold: true),
              _infoRow("Booking Status", data.bookingStatus ?? "-"),
              _infoRow("Order ID",
                  "#${data.id?.substring(data.id!.length - 6).toUpperCase() ?? "-"}"),
              _infoRow("Booked On", _formatDate(data.createdAt)),
            ],
          ),
        );
      },
    );
  }

  /// ---------------- INFO ROW ----------------
  Widget _infoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(color: Colors.grey[600], fontSize: 14.sp)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14.sp,
                  color: isBold ? Colors.black : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
