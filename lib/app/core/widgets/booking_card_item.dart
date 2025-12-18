import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:harry_service_app/app/core/constants/app_colors.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/core/widgets/custome_button.dart';

class BookingCardItem extends StatelessWidget {
  final String image;
  final String title;              // Product name
  final String price;              // Price
  final  buttonText;         // Button label
  final VoidCallback onButtonTap;  // Button action
  final Color borderColor;         // Card border color
  final String? timeLabel;         // Optional time label
  final IconData buttonIcon;

  const BookingCardItem({
    super.key,
    required this.image,
    required this.title,
    required this.price,
    required this.buttonText,
    required this.onButtonTap,
    this.borderColor = Colors.white,
    this.timeLabel,
    required this.buttonIcon,
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
                            style: AppTextStyle.sub_h3_medium_14(),
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
                    /// Time Label and Button Row
                    Row(
                      children: [
                        // Time Label
                        if (timeLabel != null && timeLabel!.isNotEmpty)
                          Expanded(
                            flex:2,
                            child: Text(
                              timeLabel!,
                              style: AppTextStyle.sub_h3_medium_14(
                                color: Colors.red,
                              ).copyWith(fontSize: 8),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              softWrap: true,
                            ),
                          ),


                        Spacer(),
                        /// Button
                        if(buttonText!=null)
                        Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            onTap: onButtonTap,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.r),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xffD4AF38),
                                    const Color(0xffF4D03F),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    buttonIcon,
                                    color: Colors.white,
                                    size: 14.sp,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    buttonText,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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
