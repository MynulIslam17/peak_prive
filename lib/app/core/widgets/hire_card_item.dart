import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:harry_service_app/app/core/widgets/custom_image_container.dart';

import '../constants/app_colors.dart';
import '../constants/text-style.dart';

class HireCardItem extends StatelessWidget {
  final String productImg;
  final String itemName;
  final int productPrice;

  final int quantity; // <-- NEW
  final VoidCallback addOnTap;
  final VoidCallback removeOnTap;

  const HireCardItem({
    super.key,
    required this.productImg,
    required this.itemName,
    required this.productPrice,
    required this.quantity, // <-- NEW
    required this.addOnTap,
    required this.removeOnTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.all(6.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      shadowColor: Colors.grey.withOpacity(0.2),
      child: Container(
        height: 160.h,
        padding: EdgeInsets.all(10.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

             CustomCachedImage(
               imageUrl: productImg,
               height: 70,
               width: 60,
               fit: BoxFit.cover,
             ),

            SizedBox(height: 8.h),

            Text(
              itemName,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              maxLines: 2,
            ),
            SizedBox(height: 4.h),

            Text(
              "\$$productPrice",
              style: AppTextStyle.sub_h3_medium_14(
                color: AppColors.primary_1,
              ),
            ),

            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Remove
                Material(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  child: InkWell(
                    onTap: removeOnTap,
                    child: Padding(
                      padding: EdgeInsets.all(4.w),
                      child: Icon(Icons.remove, size: 16, color: Colors.red),
                    ),
                  ),
                ),

                SizedBox(width: 6.w),

                /// SHOW REAL CONTROLLER QUANTITY
                Text(
                  "$quantity",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),

                SizedBox(width: 6.w),

                // Add
                Material(
                  color: AppColors.primary_1.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  child: InkWell(
                    onTap: addOnTap,
                    child: Padding(
                      padding: EdgeInsets.all(4.w),
                      child:
                      Icon(Icons.add, size: 16, color: AppColors.primary_1),
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
}
