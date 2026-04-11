import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:harry_service_app/app/core/constants/app_colors.dart';
import 'package:harry_service_app/app/core/controllers/nav_controller.dart';
import 'package:harry_service_app/app/modules/provider/pass/models/pass_item_model.dart';
import 'package:harry_service_app/app/modules/user/pass/controllers/pass_booking_details_single_controller.dart';
import 'package:harry_service_app/app/modules/user/pass/models/get_single_pass.dart';
import 'package:harry_service_app/app/modules/user/shared/models/booking_model.dart';

import '../../../../core/widgets/custom_appbar.dart';

class UsePassBookingInfo extends StatefulWidget {


  const UsePassBookingInfo({super.key});




  @override
  State<UsePassBookingInfo> createState() => _UsePassBookingInfoState();
}

class _UsePassBookingInfoState extends State<UsePassBookingInfo> {


  final passItemController=Get.put(SinglePassBookingItem());

  late final String bookingId;

 @override
  void initState() {

   var argument=Get.arguments;
   bookingId=argument["bookingId"];

   _fetchData();

    super.initState();
  }

  void _fetchData()async{

    await passItemController.fetchBooking(bookingId);
  }


  @override
  Widget build(BuildContext context) {





    return Scaffold(
      backgroundColor: const Color(0xffF9F7F3),
        appBar: CustomAppBar(title: "Pass booking details",onBackPressed: (){
          Get.back();
        },),
      body: GetBuilder<SinglePassBookingItem>(builder: (controller){

        if(controller.isLoading){
          return Center(child: CircularProgressIndicator(color: AppColors.primary_1,),);
        }



        return  Stack(
          children: [
            _buildMainContent(),
            _buildSlidingPanel(),
          ],
        );
      })
    );
  }

  /// ---------------- MAIN CONTENT ----------------
  Widget _buildMainContent() {
    return GetBuilder<SinglePassBookingItem>(builder: (controller) {
      final data = controller.getSinglePass?.data;
      final product = data?.product;
      final services = product?.services ?? [];

      return Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: product?.thumbnail != null
                  ? Image.network(
                product!.thumbnail!,
                width: double.infinity,
                height: 220.h,
                fit: BoxFit.cover,
              )
                  : Container(height: 220.h, color: Colors.grey[300]), // Fallback
            ),
            SizedBox(height: 16.h),
            Text(
              product?.title ?? "No Title",
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6.h),
            Text(
              product?.skiPassType ?? "N/A",
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
            ),
            SizedBox(height: 12.h),
            _buildStatusBadge(data?.bookingStatus ?? "Unknown"),
            // ... rest of your code ...
          ],
        ),
      );
    });
  }

  /// ---------------- SLIDING PANEL ----------------
  Widget _buildSlidingPanel() {
    return GetBuilder<SinglePassBookingItem>(builder: (controller) {
      // 1. Safe extraction: No '!' allowed here
      final data = controller.getSinglePass?.data;
      final product = data?.product;

      return DraggableScrollableSheet(
        initialChildSize: 0.2,
        minChildSize: 0.2,
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

                // 2. Use ?. and ?? everywhere to prevent crashes
                _infoRow("Date", data?.date != null ? _formatDate(data!.date.toString()) : "N/A"),
                _infoRow("Time", data?.time ?? "N/A"),
                _infoRow("Persons", data?.personCount?.toString() ?? "0"),
                _infoRow("Location", product?.serviceArea ?? "N/A"),
                _infoRow("Booking ID", data?.id ?? "N/A"),
                _infoRow("Total Paid", "€ ${data?.totalPrice ?? 0}"),
                _infoRow("Booked On", data?.createdAt != null ? _formatDateTime(data!.createdAt.toString()) : "N/A"),

                SizedBox(height: 24.h),
              ],
            ),
          );
        },
      );
    });
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

  String _formatDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    return "${date.day}-${date.month}-${date.year}";
  }

  String _formatDateTime(String isoDate) {
    final date = DateTime.parse(isoDate);
    return "${date.day}-${date.month}-${date.year} "
        "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }
}
