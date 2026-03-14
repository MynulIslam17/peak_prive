import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../gen/assets.gen.dart';
import '../constants/text-style.dart';
import 'custom_image_container.dart';

class BookingCard extends StatelessWidget {
  final VoidCallback onTap;
  final int personCount;
  final String passType;
  final String location;
  final String date;
  final String time;
  final String image;
  final IconData? buttonIcon;

  final icon = Assets.icons;

  const BookingCard({
    super.key,
    required this.onTap,
    this.personCount = 1,
    this.passType = "Default",
    required this.location,
    required this.date,
    required this.time,
    required this.image,
    this.buttonIcon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 150.h,
      child: Card(
        color: Colors.white,
        margin: EdgeInsets.symmetric(vertical: 6.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: Column(
            children: [
              /// Main Row with image + info
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /// ------------------ Image ------------------
                    CustomCachedImage(
                      imageUrl: image,
                      height: 95.h,
                      width: 95.w,
                    ),

                    SizedBox(width: 12.w),

                    /// ------------------ Info Column ------------------
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          /// -------- Row 1: Person + PassType --------
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Person", style: AppTextStyle.c_regular_10()),
                                    SizedBox(height: 2.h),
                                    Row(
                                      children: [
                                        icon.user.svg(width: 14.w, height: 14.h),
                                        SizedBox(width: 4.w),
                                        Flexible(
                                          child: Text(
                                            "$personCount person",
                                            style: AppTextStyle.c_regular_10(),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Pass Type", style: AppTextStyle.c_regular_10()),
                                    SizedBox(height: 2.h),
                                    Row(
                                      children: [
                                        icon.ticket.svg(width: 14.w, height: 14.h),
                                        SizedBox(width: 4.w),
                                        Flexible(
                                          child: Text(
                                            passType,
                                            style: AppTextStyle.c_regular_10(),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 6.h),

                          /// -------- Row 2: Time + Location --------
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Time", style: AppTextStyle.c_regular_10()),
                                    SizedBox(height: 2.h),
                                    Row(
                                      children: [
                                        icon.time.svg(width: 14.w, height: 14.h),
                                        SizedBox(width: 4.w),
                                        Flexible(
                                          child: Text(
                                            "$date | $time",
                                            style: AppTextStyle.c_regular_10(),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Location", style: AppTextStyle.c_regular_10()),
                                    SizedBox(height: 2.h),
                                    Row(
                                      children: [
                                        icon.mapPinSimpleArea.svg(width: 14.w, height: 14.h),
                                        SizedBox(width: 4.w),
                                        Flexible(
                                          child: Text(
                                            location,
                                            style: AppTextStyle.c_regular_10(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
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
                  ],
                ),
              ),

              /// -------- Details Button at bottom --------
              Align(
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xffD4AF38),
                          Color(0xffF4D03F),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (buttonIcon != null)
                          Icon(buttonIcon, color: Colors.white, size: 14.sp),
                        if (buttonIcon != null) SizedBox(width: 4.w),
                        Text(
                          "Details",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}