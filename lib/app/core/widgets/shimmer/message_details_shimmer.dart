import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class MassageDetailsShimmer extends StatelessWidget {
  const MassageDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          children: [
            // Background image shimmer
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: size.height * 0.48,
                color: Colors.white,
              ),
            ),

            // Overlap card
            Positioned(
              top: size.height * 0.33,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                width: size.width,
                decoration: BoxDecoration(
                  color: const Color(0xffFDFAF6),
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
                      // Line indicator shimmer
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              width: 87.w,
                              height: 9.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // Provider Info Shimmer
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          child: SizedBox(
                            height: 70.h,
                            width: double.infinity,
                            child: _buildProviderInfoShimmer(),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // Tab bar shimmer
                      _buildTabButtonsShimmer(),

                      // Tab content shimmer
                      Expanded(
                        child: _buildContentShimmer(),
                      ),

                      // Footer shimmer (Price + Button)
                      Padding(
                        padding: EdgeInsets.only(
                          top: 10.h,
                          bottom: 20.h,
                        ),
                        child: _buildFooterShimmer(),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Back button shimmer
            Positioned(
              top: 40.h,
              left: 20.w,
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Provider info shimmer
  // Provider Info Shimmer
  Widget _buildProviderInfoShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 50.w,
              height: 50.h,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 12.w),

            // Name and rating
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120.w,
                    height: 14.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Container(
                    width: 80.w,
                    height: 10.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),

            // Action buttons
            Row(
              children: [
                Container(
                  width: 35.w,
                  height: 35.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 10.w),
                Container(
                  width: 35.w,
                  height: 35.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Tab Buttons Shimmer (About/Review)
  Widget _buildTabButtonsShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
          SizedBox(width: 7.w),
          Expanded(
            child: Container(
              height: 44.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Content shimmer
  Widget _buildContentShimmer() {
    return ListView(
      padding: EdgeInsets.all(20),
      children: [
        // Title and price row
        _buildShimmerRow(150.w, 20.h, 50.w, 20.h),
        SizedBox(height: 10.h),
        // Open/Close time row
        _buildShimmerRow(70.w, 12.h, 80.w, 12.h, circle: true),
        SizedBox(height: 10.h),
        // Location row
        _buildShimmerRow(20.w, 20.h, 200.w, 12.h),
        SizedBox(height: 20.h),
        // Benefits title
        _buildShimmerLine(100.w, 18.h),
        SizedBox(height: 10.h),
        // Benefits description lines
        ...List.generate(3, (_) => Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: _buildShimmerLine(double.infinity, 12.h),
        )),
        SizedBox(height: 20.h),
        // Recommendation title
        _buildShimmerLine(180.w, 18.h),
        SizedBox(height: 10.h),
        // Recommendation description lines
        ...List.generate(4, (_) => Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: _buildShimmerLine(double.infinity, 12.h),
        )),
      ],
    );
  }

  // Footer shimmer
  Widget _buildFooterShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Row(
        children: [
          Container(
            width: 60.w,
            height: 24.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(width: 30.w),
          Expanded(
            child: Container(
              height: 50.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper: shimmer row
  Widget _buildShimmerRow(double width1, double height1, double width2, double height2,
      {bool circle = false}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Row(
        children: [
          Container(
            width: width1,
            height: height1,
            decoration: circle
                ? const BoxDecoration(color: Colors.white, shape: BoxShape.circle)
                : BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(width: 10.w),
          Container(
            width: width2,
            height: height2,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  // Helper: shimmer line
  Widget _buildShimmerLine(double width, double height) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }














}
