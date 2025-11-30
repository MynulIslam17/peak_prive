import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class ProviderServiceShimmer extends StatelessWidget {
  const ProviderServiceShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shimmer for Provider Profile
              Row(
                children: [
                  CircleAvatar(radius: 25, backgroundColor: Colors.white),
                  SizedBox(width: 10.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 100.w, height: 10.h, color: Colors.white),
                      SizedBox(height: 5.h),
                      Container(width: 150.w, height: 12.h, color: Colors.white),
                    ],
                  ),
                  const Spacer(),
                  Container(width: 30.w, height: 30.h, color: Colors.white),
                ],
              ),

              SizedBox(height: 24.h),

              // Shimmer for "My service" title and Add button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(width: 80.w, height: 15.h, color: Colors.white),
                  Container(width: 60.w, height: 25.h, color: Colors.white),
                ],
              ),

              SizedBox(height: 17.h),

              // Shimmer for 5 service cards
              Column(
                children: List.generate(5, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Container(
                      height: 200.h, // Approximate height of MyServiceCard
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          // Image placeholder
                          Container(
                            width: 100.w,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          // Text content placeholder
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 12.h,
                                  color: Colors.white,
                                ),
                                SizedBox(height: 8.h),
                                Container(
                                  width: 150.w,
                                  height: 10.h,
                                  color: Colors.white,
                                ),
                                SizedBox(height: 5.h),
                                Container(
                                  width: 100.w,
                                  height: 10.h,
                                  color: Colors.white,
                                ),
                                const Spacer(),
                                Row(
                                  children: [
                                    Container(
                                      width: 60.w,
                                      height: 10.h,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      width: 24.w,
                                      height: 24.h,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Container(
                                      width: 24.w,
                                      height: 24.h,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.white,
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
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
