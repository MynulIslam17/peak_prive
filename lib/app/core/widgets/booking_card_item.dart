import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:harry_service_app/app/core/constants/app_colors.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/core/widgets/custome_button.dart';
import 'package:harry_service_app/gen/assets.gen.dart';

class BookingCardItem extends StatelessWidget {
  final String image;
  final String title;              // Product name
  final double ? dueTime;              // Product name
  final String price;              // Price
  final String buttonText;         // Button label
  final VoidCallback onButtonTap;  // Button action
  final VoidCallback? onMenuTap;   // Optional 3-dots action
  final Color borderColor;         // Card border color
  final bool showMenu;             // Toggle 3-dots visibility

  const BookingCardItem({
    super.key,
    required this.image,
    required this.title,
    required this.price,
    required this.buttonText,
    required this.onButtonTap,
    this.onMenuTap,
    this.showMenu = false,
    this.borderColor = Colors.white,
    this.dueTime,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: borderColor, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //  Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                image,
                width: 95.w,
                height: 93.h,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            //  Product Info
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTextStyle.sub_h2_medium_16(),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        price,
                        style: AppTextStyle.sub_h3_medium_14(
                          color: AppColors.primary_1,
                        ),
                      ),
                      if (showMenu && onMenuTap != null)
                        IconButton(
                          onPressed: onMenuTap,
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.black,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 8.h),


                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [

                      /// due time show when send duetime
                      if(dueTime!=null)...[
                        FittedBox(child: Text("Time Left : $dueTime",style: AppTextStyle.sub_h3_medium_14(color: AppColors.black_3,).copyWith(fontSize: 11))),

                      ],



                    SizedBox(width: 10.w,),
                    CustomButton(
                      text: buttonText,
                      width: 110.w,
                      height: 30.h,
                      textSize: 10.sp,
                      onTap: onButtonTap,
                    ),

                  ],)

                  
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
