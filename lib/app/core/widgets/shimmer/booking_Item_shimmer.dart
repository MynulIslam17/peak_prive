import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class BookingCardSkeleton extends StatelessWidget {
  const BookingCardSkeleton({super.key});

  Widget _buildShimmerBlock({double? width, double? height, BorderRadius? borderRadius}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: borderRadius ?? BorderRadius.circular(4),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 7.h, horizontal: 10.w),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center, // Center vertically
            children: [
              /// Left Side: Image
              _buildShimmerBlock(
                width: 95.w,
                height: 120.h,
                borderRadius: BorderRadius.circular(10),
              ),

              SizedBox(width: 12.w),

              /// Right Side: Product Info
              Expanded(
                child: Column(
                 // mainAxisAlignment: MainAxisAlignment.center, // Center vertically
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Title
                    _buildShimmerBlock(width: double.infinity, height: 15.h),
                    SizedBox(height: 8.h),

                    /// Price
                    _buildShimmerBlock(width: 80.w, height: 15.h),
                    SizedBox(height: 8.h),

                    /// Booking Button
                    Align(
                      alignment: Alignment.centerRight,
                      child: _buildShimmerBlock(
                        width: 100.w,
                        height: 35.h,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
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
