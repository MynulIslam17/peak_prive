import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../gen/assets.gen.dart';
import '../constants/app_colors.dart';
import '../constants/text-style.dart';

class HireCardItem extends StatelessWidget {
  final String productImg;
  final String itemName;
  final int productPrice;
  final VoidCallback addOnTap;
  final VoidCallback removeOnTap;

  const HireCardItem({
    super.key,
    required this.productImg,
    required this.itemName,
    required this.addOnTap,
    required this.removeOnTap,
    required this.productPrice
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 2.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// Left Section (image + Name)
            Flexible(
              flex: 2,
              child: Row(
                children: [
                  Image.network(productImg,width: 40,height: 40,),
                  SizedBox(width: 5.w),
                  Expanded(
                    child: Text(
                      itemName,
                      style: AppTextStyle.c_regular_12().copyWith(fontSize: 10.sp),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            /// Right Section (Price + +/-)
            Flexible(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "${productPrice}",
                    style: AppTextStyle.c_regular_12(
                      color: AppColors.primary_1,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: addOnTap,
                        child: const Icon(Icons.add, size: 14),
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        "1",
                        style: AppTextStyle.sub_h3_medium_14().copyWith(fontSize: 10.sp),
                      ),
                      SizedBox(width: 3.w),
                      InkWell(
                        onTap: removeOnTap,
                        child: const Icon(Icons.remove, size: 14),
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
  }
}
