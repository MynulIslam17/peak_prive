import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:harry_service_app/app/core/constants/app_colors.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/core/widgets/custome_button.dart';

class BookingCardItem extends StatelessWidget {
  final String image;
  final String title;              // Product name
  final double? dueTime;
  final String price;              // Price
  final String buttonText;         // Button label
  final VoidCallback onButtonTap;  // Button action
  final Color borderColor;         // Card border color

  const BookingCardItem({
    super.key,
    required this.image,
    required this.title,
    required this.price,
    required this.buttonText,
    required this.onButtonTap,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                image,
                width: 95.w,
                height: 93.h,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 12.w),
            // Product Info
            Expanded(
              child: SizedBox(
                height: 95.h,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Title and Price Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: AppTextStyle.sub_h2_medium_16().copyWith(fontSize: 17),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          price,
                          style: AppTextStyle.sub_h3_medium_14(
                            color: AppColors.primary_1,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    // Due Time and Button Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (dueTime != null)
                          FittedBox(
                            child: Text(
                              "Time Left: ${dueTime!.toStringAsFixed(1)}",
                              style: AppTextStyle.sub_h3_medium_14(
                                color: Colors.red,
                              ).copyWith(fontSize: 12),
                            ),
                          ),
                        CustomButton(
                          text: buttonText,
                          width: 110,
                          height: 30,
                          textSize: 10,
                          onTap: onButtonTap,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
