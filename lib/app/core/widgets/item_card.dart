import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../gen/assets.gen.dart';

import '../constants/app_colors.dart';
import '../constants/text-style.dart';

class ItemCard extends StatelessWidget {
  final bool  fromSkiPasses;
  final String image;
  final String title;
  final String price;
  final double rating;
  final String reviewCount;
  final String location;
  final  String ? skiPassType;
  final VoidCallback onTap;

  const ItemCard({
    super.key,
    required this.image,
    required this.title,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.location,
     this.fromSkiPasses=false,
     this.skiPassType,
    required this.onTap



  });

  @override
  Widget build(BuildContext context) {
    // Fixed icons
    final starIcon = Assets.icons.star;
    final mapPinIcon = Assets.icons.mapPinSimpleArea;

    return   Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            /// Card
            Card(
              margin: EdgeInsets.only(bottom: 12.h),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                height: 220.h,
                width: 345.w,
                decoration: BoxDecoration(
                  gradient: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      /// Rounded Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child:Image.network(image,width: double.infinity,height: 160,fit: BoxFit.cover,)
                      ),

                      SizedBox(height: 5.h),

                      /// Title + Price
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(title, style: AppTextStyle.sub_h3_medium_14(),overflow: TextOverflow.ellipsis,),
                            Text(price,
                                style: AppTextStyle.sub_h3_medium_14(
                                  color: AppColors.primary_1,
                                )),
                          ],
                        ),
                      ),

                      /// Rating + Location
                      Expanded(
                        child: Row(
                          children: [
                            Assets.icons.star.svg(height: 12.h, width: 12.h),
                            SizedBox(width: 4.w),
                            Text(rating.toString(), style: AppTextStyle.sub_h3_regular_14()),
                            SizedBox(width: 4.w),
                            Text("($reviewCount)", style: AppTextStyle.c_light_12()),
                            const Spacer(),
                            Assets.icons.mapPinSimpleArea.svg(height: 14.h, width: 14.w),
                            SizedBox(width: 5.w),
                            Text(location, style: AppTextStyle.c_regular_12().copyWith(fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            /// Optional Ski Pass Badge
            if (fromSkiPasses && skiPassType != null)
              Positioned(
                top: 30,
                left: 40,
                child: Container(
                  height: 30.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.brown),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        skiPassType!,
                        style: AppTextStyle.sub_h3_medium_14(color: AppColors.primary_1),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );


  }
}
