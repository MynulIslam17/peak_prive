import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

/// Circular skeleton for categories
class CategorySkeleton extends StatelessWidget {
  const CategorySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (_, __) => SizedBox(width: 15.w),
        itemBuilder: (context, index) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              SizedBox(height: 6.h),
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 50,
                  height: 12,
                  color: Colors.grey[300],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}



/// Detailed skeleton for item cards


class ItemCardSkeleton extends StatelessWidget {
  const ItemCardSkeleton({super.key});

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
      padding: EdgeInsets.symmetric(vertical: 7.h),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Image Section
              _buildShimmerBlock(
                width: double.infinity,
                height: 120.h,
                borderRadius: BorderRadius.circular(8),
              ),
              SizedBox(height: 10.h),

              // Title and Price Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildShimmerBlock(width: 120.w, height: 15.h),
                  _buildShimmerBlock(width: 60.w, height: 15.h),
                ],
              ),
              SizedBox(height: 8.h),

              // Rating and Review Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildShimmerBlock(width: 80.w, height: 15.h),
                  _buildShimmerBlock(width: 50.w, height: 15.h),
                ],
              ),
              SizedBox(height: 8.h),




            ],
          ),
        ),
      ),
    );
  }
}




/// Header skeleton (profile + search bar)
class HeaderSkeleton extends StatelessWidget {
  const HeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [


          Row(children: [


            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[300],
              ),
            ),


            SizedBox(width: 10,),



             Column(
               children: [

                 Shimmer.fromColors(
                   baseColor: Colors.grey[300]!,
                   highlightColor: Colors.grey[100]!,
                   child: Container(
                     width: 200,
                     height: 20,
                     decoration: BoxDecoration(
                         color: Colors.grey[300],
                         borderRadius: BorderRadius.circular(8)
                     ),
                   ),
                 ),


                 SizedBox(height: 10,),

                 Shimmer.fromColors(
                   baseColor: Colors.grey[300]!,
                   highlightColor: Colors.grey[100]!,
                   child: Container(
                     width: 200,
                     height: 20,
                     decoration: BoxDecoration(
                         color: Colors.grey[300],
                         borderRadius: BorderRadius.circular(8)
                     ),
                   ),
                 ),


               ],
             )



          ],),


          SizedBox(height: 16.h),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 40.h,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12)
              ),
              width: double.infinity,

            ),
          ),
        ],
      ),
    );
  }
}



/// Category title skeleton
class CategoryTitleSkeleton extends StatelessWidget {
  const CategoryTitleSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 120.w,
              height: 20.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          // "See All"
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 60.w,
              height: 16.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
