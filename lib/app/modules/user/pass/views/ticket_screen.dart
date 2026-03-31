import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/app_colors.dart';
import 'package:harry_service_app/app/core/widgets/custom_image_container.dart';


import '../../../../core/constants/text-style.dart';
import '../../../../routes/app_routes.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.black_1, size: 20),
          onPressed: () => Get.back(),
        ),
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
                color: AppColors.primary_3.withOpacity(0.15), // Using primary_3 for soft bg
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.primary_3.withOpacity(0.3)),
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
                          imageUrl: "https://picsum.photos/200/300",
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
                                Text(
                                  "Vip",
                                  style: AppTextStyle.c_regular_10(color: Colors.white),
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
                        _buildInfoItem(
                          label: "Date & time",
                          value: "16/10/2025 | 09:00 Am",
                          icon: Icons.calendar_today_outlined,
                        ),
                        SizedBox(height: 16.h),
                        _buildInfoItem(
                          label: "Person",
                          value: "2 Person",
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
                    onPressed: () {},
                    icon: Icon(Icons.file_download_outlined, color: Colors.white, size: 20.sp),
                    label: Text("Get Ticket", style: AppTextStyle.sub_h3_medium_14(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary_1,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      elevation: 0,
                    ),
                  ),
                ),
                SizedBox(width: 15.w),
                // Home Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: (){
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
        Text(
          label,
          style: AppTextStyle.p_regular_12(color: AppColors.black_3),
        ),
        SizedBox(height: 6.h),
        Row(
          children: [
            Icon(icon, color: AppColors.black_1, size: 18.sp),
            SizedBox(width: 8.w),
            Text(
              value,
              style: AppTextStyle.sub_h2_medium_16(color: AppColors.black_1),
            ),
          ],
        ),
      ],
    );
  }
}