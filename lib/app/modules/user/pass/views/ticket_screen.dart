import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/app_colors.dart';
import 'package:harry_service_app/app/core/utils/date_parser.dart';
import 'package:harry_service_app/app/core/widgets/custom_image_container.dart';
import 'package:harry_service_app/app/modules/user/pass/controllers/pass_booking_controller.dart';

import '../../../../core/constants/text-style.dart';
import '../../../../routes/app_routes.dart';
import '../controllers/pass_details_controller.dart';
import '../pdf_service/ticket_pdf.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  final detailsController = Get.find<PassDetailsController>();
  final bookingController = Get.find<CreateBookingController>();

  @override
  Widget build(BuildContext context) {
    final pass = detailsController.passDetails;
    final ticket = bookingController.successResponse;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          "Ticket",
          style: AppTextStyle.h3_semibold_20(color: AppColors.black_1),
        ),
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
                color: AppColors.primary_3.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.primary_3.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Image Section
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16.r),
                    ),
                    child: Stack(
                      children: [
                        CustomCachedImage(
                          width: double.infinity,
                          height: 180,
                          borderRadius: 12,
                          imageUrl: pass?.thumbnail,
                          fit: BoxFit.cover,
                        ),

                        // VIP Badge
                        Positioned(
                          top: 12.h,
                          left: 12.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secendary,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.stars,
                                  color: Colors.white,
                                  size: 14.sp,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  pass?.skiPassType ?? "__",
                                  style: AppTextStyle.c_regular_10(
                                    color: Colors.white,
                                  ),
                                ),
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
                        Text(
                          pass?.title ?? "__",
                          style: AppTextStyle.h1_medium_24(color: AppColors.black_1),
                        ),
                        SizedBox(height: 12.h),

                        // --- Date & Time ---
                        _buildInfoItem(
                          label: "Date & Time",
                          value: "${ticket?.date} ${ticket?.time}",
                          icon: Icons.calendar_today_outlined,
                        ),
                        SizedBox(height: 16.h),

                        // --- Person ---
                        _buildInfoItem(
                          label: "Person",
                          value: ticket?.personCount.toString() ?? "__",
                          icon: Icons.person_outline,
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
                    onPressed: ()async {

                      Get.snackbar("Downloading", "Please wait while we generate your ticket...",
                          snackPosition: SnackPosition.BOTTOM);

                      await PdfHelper.generateTicket(
                        title: pass?.title ?? "Ski Pass Ticket",
                        date: DateParserHelper.toDisplayDate(ticket?.date),
                        time: ticket?.time ?? "__",
                        person: ticket?.personCount?.toString() ?? "0",
                        ticketId: ticket?.ticketNumber ?? "N/A",
                        imageUrl: pass?.thumbnail,
                      );

                    },
                    icon: Icon(
                      Icons.file_download_outlined,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                    label: Text(
                      "Get Ticket",
                      style: AppTextStyle.sub_h3_medium_14(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary_1,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                SizedBox(width: 15.w),
                // Home Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.offAllNamed(Routes.bottomNav);
                    },
                    icon: Icon(
                      Icons.home_outlined,
                      color: AppColors.primary_1,
                      size: 20.sp,
                    ),
                    label: Text(
                      "Go Home",
                      style: AppTextStyle.sub_h3_medium_14(
                        color: AppColors.primary_1,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary_1),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Reusable Info Widget
  Widget _buildInfoItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
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
              child: Text(
                value,
                style: AppTextStyle.sub_h3_medium_14(color: AppColors.black_1),
              ),
            ),
          ],
        ),
      ],
    );
  }
}



