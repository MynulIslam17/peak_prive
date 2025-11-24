import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class HireDetailsSkeleton extends StatelessWidget {
  const HireDetailsSkeleton({super.key});

  // 🔥 Reusable shimmer box builder
  Widget _shimmerBox({
    double? width,
    double? height,
    double radius = 10,
    BoxShape shape = BoxShape.rectangle,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          shape: shape,
          borderRadius: shape == BoxShape.circle
              ? null
              : BorderRadius.circular(radius),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        children: [
          /// 🔹 Thumbnail shimmer
          _shimmerBox(
            height: size.height * 0.48,
            width: double.infinity,
            radius: 10,
          ),

          /// 🔹 Overlapping card section
          Positioned(
            top: size.height * 0.3,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              width: size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    /// Drag line
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _shimmerBox(
                        width: 87.w,
                        height: 9.h,
                        radius: 10,
                      ),
                    ),
                    SizedBox(height: 20.h),

                    /// 🔹 Provider info shimmer
                    Row(
                      children: [
                        _shimmerBox(
                          width: 60,
                          height: 60,
                          shape: BoxShape.circle,
                        ),
                        SizedBox(width: 12.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _shimmerBox(
                              width: 150.w,
                              height: 16.h,
                            ),
                            SizedBox(height: 6.h),
                            _shimmerBox(
                              width: 100.w,
                              height: 14.h,
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    /// 🔹 Tabs shimmer
                    _shimmerBox(
                      height: 40.h,
                      radius: 10,
                    ),
                    SizedBox(height: 16.h),


                    SizedBox(height: 10.h),

                    /// 🔹 Bottom Book Now shimmer
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 10,
                      ),
                      child: Row(
                        children: [
                          _shimmerBox(
                            width: 80.w,
                            height: 25.h,
                          ),
                          SizedBox(width: 20.w),
                          Expanded(
                            child: _shimmerBox(
                              height: 50.h,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// 🔹 Back button shimmer
          Positioned(
            top: 40.h,
            left: 20.w,
            child: _shimmerBox(
              width: 40,
              height: 40,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
