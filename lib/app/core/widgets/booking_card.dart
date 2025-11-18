import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../gen/assets.gen.dart';
import '../constants/text-style.dart';

class BookingCard extends StatelessWidget {
  final VoidCallback onTap;
  final int personCount;
  final String passType;
  final String location;
  final String date;
  final String time;
  final String image;

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
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 130.h,
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 6.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// ------------------ Image (Centered vertically) ------------------
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: Image.network(
                  image,
                  width: 70.w,
                  height: 70.h,
                  fit: BoxFit.cover,
                ),
              ),

              SizedBox(width: 12.w),

              /// ------------------ Right Section ------------------
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //
                    // /// -------- Row 1: Menu Only --------
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.end,
                    //   children: [
                    //     IconButton(
                    //       padding: EdgeInsets.zero,
                    //       constraints: const BoxConstraints(),
                    //       onPressed: onTap,
                    //       icon: icon.dots.svg(width: 14.w, height: 14.h),
                    //     ),
                    //   ],
                    // ),

                    SizedBox(height: 4.h),

                    /// -------- Row 2: Person + Pass Type --------
                    Row(
                      children: [
                        /// Person
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Person", style: AppTextStyle.c_regular_10()),
                              SizedBox(height: 4.h),
                              Row(
                                children: [
                                  icon.user.svg(width: 14.w, height: 14.h),
                                  SizedBox(width: 4.w),
                                  Text(
                                    "$personCount person",
                                    style: AppTextStyle.c_regular_10(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        /// Pass Type
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Pass Type", style: AppTextStyle.c_regular_10()),
                              SizedBox(height: 4.h),
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

                    SizedBox(height: 10.h),

                    /// -------- Row 3: Time + Location --------
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        /// Time
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Time", style: AppTextStyle.c_regular_10()),
                              SizedBox(height: 4.h),
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

                        /// Location
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Text("Location", style: AppTextStyle.c_regular_10()),
                              SizedBox(height: 4.h),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  icon.mapPinSimpleArea
                                      .svg(width: 14.w, height: 14.h),
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
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
