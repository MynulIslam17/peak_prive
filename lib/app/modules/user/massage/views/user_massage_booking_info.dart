import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:harry_service_app/app/core/constants/app_colors.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/custom_appbar.dart';
import '../../../../data/services/stripe/payment_result.dart';
import '../../../../data/services/stripe/stripe_config.dart';
import '../../../../data/services/stripe/stripe_helper.dart';
import '../controllers/massage_booking_single_controller.dart';

class UserMassageBookingInfo extends StatefulWidget {
  const UserMassageBookingInfo({super.key});

  @override
  State<UserMassageBookingInfo> createState() =>
      _UserMassageBookingInfoState();
}

class _UserMassageBookingInfoState extends State<UserMassageBookingInfo> {

  // Stripe payment helper
  late StripePaymentHelper _paymentHelper;
  bool _isProcessingPayment = false;

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

  /// ---------------- DUMMY DATA ----------------
  final String serviceImage =
      "https://images.unsplash.com/photo-1587017539504-67cfbddac569";
  final String serviceName = "Relaxing Swedish Massage";
  final String category = "Full Body";
  final String location = "Home Service";
  final String description =
      "A deeply relaxing full body Swedish massage designed to reduce stress and improve circulation.";

  final String therapistName = "Ananya Sharma";
  final int therapistExperience = 6;
  final String therapistImage =
      "https://randomuser.me/api/portraits/women/44.jpg";

  final DateTime sessionDate = DateTime.now().add(const Duration(days: 2));
  final String sessionTime = "06:00 PM - 07:00 PM";
  final int duration = 60;

  final int serviceFee = 1800;
  final int travelFee = 200;
  final int totalPaid = 2000;


  /// find controllers
  final massageController = Get.put(SingleMassageBookingItem());

  late final String bookingId;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    var argument=Get.arguments;
    bookingId=argument["bookingId"];


    ///  Call API
    massageController.fetchBooking(bookingId);


  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F7F3),
        appBar: CustomAppBar(title: "Massage booking details",onBackPressed: (){
          Get.back();
        },),
      body: GetBuilder<SingleMassageBookingItem>(builder: (controller){

        if(controller.isLoading){
          return Center(child: CircularProgressIndicator(color: AppColors.primary_1,),);
        }

        if (controller.errorMessage != null) {
          return Center(child: Text(controller.errorMessage!));
        }


        final data = controller.getSingleMassage?.data;

        if (data == null) {
          return const Center(child: Text("No booking data found"));
        }



        return Stack(
          children: [
            _buildMainContent(controller),
            _buildSlidingPanel(controller),
          ],
        );


      })
    );
  }

  /// ---------------- MAIN CONTENT ----------------
  Widget _buildMainContent(SingleMassageBookingItem controller) {

    final data=controller.getSingleMassage!.data;
    final product=controller.getSingleMassage!.data!.product;


    return SingleChildScrollView(
      padding:
      EdgeInsets.only(left: 16.w, right: 16.w, top: 16.h, bottom: 120.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Service Image
          ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Image.network(
              product?.thumbnail ?? '',
              height: 180.h,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 180.h,
                  width: double.infinity,
                  color: Colors.grey.shade300,
                  alignment: Alignment.center,
                  child: const Icon(Icons.spa, size: 40),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return SizedBox(
                  height: 180.h,
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),


          SizedBox(height: 16.h),

          /// Service Name
          Text(
            product!.title ?? "N/A",
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6.h),

          /// Category • Duration • Location
          Text(
            "${product.category!.name} • ${data!.duration} mins • ${product.serviceArea}",
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
          ),
          SizedBox(height: 12.h),

          Text(
            "Benefit",
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
          ),


          Text(
            product!.benefits ?? "",
            style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
          ),


          /// Description
          Text(
            "Our Recommendations",
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 6.h),

          Text(
            product!.ourRecommendations ?? "",
            style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
          ),

          SizedBox(height: 24.h),


        ],
      ),
    );
  }

  /// ---------------- SLIDING PANEL ----------------
  Widget _buildSlidingPanel(SingleMassageBookingItem controller) {
    final data = controller.getSingleMassage!.data!;

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
                spreadRadius: 2,
              ),
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

              /// ---------------- API-DRIVEN INFO ----------------
              _infoRow("Session Date", _formatDate(data.date)),
              _infoRow("Session Time", data.time ?? "-"),
              _infoRow("Duration", data.duration ?? "-"),

              const Divider(),

              _infoRow(
                "Total Paid",
                "€ ${data.totalPrice ?? 0}",
                isBold: true,
              ),
              _infoRow(
                "Booking Status",
                data.bookingStatus ?? "-",
              ),
              _infoRow(
                "Booking ID",
                "#${data.id}",
              ),
              _infoRow(
                "Booked On",
                _formatDate(data.createdAt),
              ),
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
                color: isBold ? Colors.black : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
