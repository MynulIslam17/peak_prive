import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/app_colors.dart';
import 'package:harry_service_app/app/modules/user/trasnport/model/get_single_trasnport.dart';
import 'package:intl/intl.dart';

import '../../../../data/services/stripe/payment_result.dart';
import '../../../../data/services/stripe/stripe_config.dart';
import '../../../../data/services/stripe/stripe_helper.dart';
import '../controlers/transport_booking_single_controller.dart'
    show SingleTransportBookingItem;

class UserTransportBookingInfo extends StatefulWidget {
  const UserTransportBookingInfo({super.key});

  @override
  State<UserTransportBookingInfo> createState() =>
      _UserTransportBookingInfoState();
}

class _UserTransportBookingInfoState extends State<UserTransportBookingInfo> {
  final transportController = Get.put(SingleTransportBookingItem());
  late final String bookingId;


  // Stripe payment helper
  late StripePaymentHelper _paymentHelper;
  bool _isProcessingPayment = false;

  @override
  void initState() {
    super.initState();

    /// Get bookingId from arguments
    final args = Get.arguments;
    bookingId = args["bookingId"];

    /// Call API
    transportController.fetchBooking(bookingId);



  }











  String _formatDateTime(DateTime? date) {
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

    String suffix = daySuffix(date.day);
    String formatted = DateFormat('EEE, d MMM, yyyy hh:mm a').format(date);
    return formatted.replaceFirst(date.day.toString(), '${date.day}$suffix');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F7F3),
      appBar: AppBar(
        backgroundColor: const Color(0xffF9F7F3),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Transport Booking Details",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(3),
          child: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: SvgPicture.asset(
              "assets/icons/back_icon.svg",
              color: Colors.black,
              width: 30.w,
              height: 30.h,
            ),
          ),
        ),
      ),
      body: GetBuilder<SingleTransportBookingItem>(builder: (controller) {
        if (controller.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary_1,),
          );
        }

        if (controller.errorMessage != null) {
          return Center(child: Text(controller.errorMessage!));
        }

        final data = controller.getSingleTransport?.data;
        if (data == null) {
          return const Center(child: Text("No booking data found"));
        }

        return Stack(
          children: [
            _buildMainContent(data),
            _buildSlidingPanel(data),
          ],
        );
      }),
    );
  }

  /// ---------------- MAIN CONTENT ----------------
  Widget _buildMainContent(Data data) {
    final product = data.product;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Image.network(
                product?.thumbnail ?? "",
                width: double.infinity,
                height: 180.h,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 16.h),

            // Product Title
            Text(
              product?.title ?? "-",
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6.h),

            // Category & Model
            Text(
              "${product?.category?.name ?? "-"} • ${data.productModel ?? "-"}",
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
            ),
            SizedBox(height: 12.h),

            // Booking Status
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                data.bookingStatus ?? "-",
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Product Details Section
            Text(
              "Product Information",
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12.h),

            _infoRow("Service Area", product?.serviceArea ?? "-"),
            _infoRow("Person Capacity", product?.personCount ?? "-"),
            _infoRow("Mileage", product?.milage ?? "-"),
            _infoRow("Power", product?.power ?? "-"),
          ],
        ),
      ),
    );
  }

///====sliding panel
  Widget _buildSlidingPanel(Data data) {
    return DraggableScrollableSheet(
      initialChildSize: 0.14,
      minChildSize: 0.14,
      maxChildSize: 0.55,
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

              Text(
                "Booking Information",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12.h),

              _infoRow("Start Time", _formatDateTime(data.startDateAndTime)),
              _infoRow("End Time", _formatDateTime(data.endDateAndTime)),
              _infoRow("Time Slot", data.timeLabel ?? "-"),
              _infoRow("Booking ID", data.id ?? "-"),

              Divider(height: 30.h),

              Text(
                "Payment Summary",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12.h),

              _infoRow("Total Paid", "₹ ${data.totalPrice ?? 0}"),
              _infoRow(
                "Overtime Charge",
                "₹ ${data.overTimeAmount?.toStringAsFixed(2) ?? '0.00'}",
              ),
              _infoRow("Booked On", _formatDateTime(data.createdAt)),
            ],
          ),
        );
      },
    );
  }


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
}
