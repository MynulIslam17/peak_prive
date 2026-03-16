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
    return GetBuilder<SinglePassBookingItem>(builder: (controller){

      final data=controller.getSinglePass!.data;
      final user=controller.getSinglePass!.data!.user;
      final services=controller.getSinglePass!.data!.product!.services;
      final product=controller.getSinglePass!.data!.product;


      return  Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Image.network(
                product!.thumbnail! ,
                width: double.infinity,
                height: 220.h,
                fit: BoxFit.cover,
              ),
            ),

            SizedBox(height: 16.h),

            /// Title
            Text(

              product!.title!,
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 6.h),

            /// Pass Type
            Text(
              product.skiPassType!,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
            ),

            SizedBox(height: 12.h),

            /// Booking Status
            _buildStatusBadge(data!.bookingStatus!),

            SizedBox(height: 20.h),

            /// Included Services
            Text(
              "Included Services",
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),

            SizedBox(height: 10.h),

            ...services.map<Widget>((service) {
              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  children:  [
                    Icon(Icons.check_circle, color: Colors.green, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "${service.description}",
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      );
    });
  }

  /// ---------------- SLIDING PANEL ----------------
  Widget _buildSlidingPanel() {
    return GetBuilder<SinglePassBookingItem>(builder: (controller){

      final data=controller.getSinglePass!.data;
      final user=controller.getSinglePass!.data!.user;
      final services=controller.getSinglePass!.data!.product!.services;
      final product=controller.getSinglePass!.data!.product;







    return   DraggableScrollableSheet(
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
                /// Handle
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

                _infoRow("Date", _formatDate(data!.date.toString())),
                _infoRow("Time", data.time!),
                _infoRow("Persons", data.personCount.toString()),
                _infoRow(
                    "Location", product!.serviceArea ?? "N/A"),
                _infoRow("Booking ID", data!.id ?? "N/A"),
                _infoRow(
                    "Total Paid","\$ ${data.totalPrice.toString()}"),
                _infoRow(
                    "Booked On", _formatDateTime(data.createdAt.toString())),

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
