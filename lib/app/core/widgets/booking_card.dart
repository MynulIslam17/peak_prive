import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../gen/assets.gen.dart';
import '../constants/text-style.dart';

class BookingCard extends StatelessWidget {

  final icon=Assets.icons;
  final VoidCallback onTap;

  const BookingCard({
    super.key,
    required this.onTap,

  });



  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 111.h,

      child: Card(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// Item image
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10), // Image corner radius
                child: Assets.images.bookingImg.image(
                  width: 95.w,
                  height: 93.h,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
        
            /// Item info
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Top row: Person & Ski Pass Type
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Person", style: AppTextStyle.c_regular_12()),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                icon.user.svg(),
                                SizedBox(width: 3.w),
                                Expanded(child: Expanded(child: Text("1 person", style: AppTextStyle.p_medium_12().copyWith(fontSize: 11)))),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Ski Pass Type", style: AppTextStyle.c_regular_12()),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                icon.calendarDots.svg(),
                                SizedBox(width: 3.w),
                                Expanded(child: Expanded(child: Text("1 Day", style: AppTextStyle.p_medium_12().copyWith(fontSize: 11)))),
                              ],
                            ),
                          ],
                        ),
                      ),
        
                      /// option dots icon
                      Expanded(
                        flex: 1,
                        child: IconButton(
                          onPressed: onTap,
                          icon: icon.dots.svg(width: 12, height: 12),
                        ),
                      ),
                    ],
                  ),
        
                  const SizedBox(height: 6),
        
                  /// Bottom row: Time & Location
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Time", style: AppTextStyle.c_regular_12()),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                icon.calendarDots.svg(),
                                SizedBox(width: 3.w),
                                Expanded(child: Text("10 Jun | 09:45", style: AppTextStyle.p_medium_12().copyWith(fontSize: 11))),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Location", style: AppTextStyle.c_regular_12()),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                icon.mapPinSimpleArea.svg(),
                                SizedBox(width: 3.w),
                                Expanded(child: Expanded(child: Text("Mountain1", style: AppTextStyle.p_medium_12().copyWith(fontSize: 11)))),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}