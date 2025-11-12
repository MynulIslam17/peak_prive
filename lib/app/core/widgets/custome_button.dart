import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../gen/assets.gen.dart';
import '../constants/app_colors.dart';
import '../constants/text-style.dart';

class CustomButton extends StatelessWidget {
  final Color textColor;
  final double? textSize;
  final Color backgroundColor;
  final String text;
  final SvgGenImage? leftIcon;
  final SvgGenImage? rightIcon;
  final double width;
  final double height;
  final VoidCallback? onTap;
  final double iconWidth;
  final double iconHeight;

  const CustomButton({
    super.key,
    this.textColor = Colors.white,
    this.backgroundColor = AppColors.primary_1,
    required this.text,
    this.leftIcon,
    this.rightIcon,
    this.width = 268,
    this.height = 44,
    this.onTap,
    this.iconWidth = 24,
    this.iconHeight = 24,
    this.textSize,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width.w,
      height: height.h,
      child: ElevatedButton(
        onPressed: onTap,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(backgroundColor),
          foregroundColor: MaterialStateProperty.all(textColor),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leftIcon != null) ...[
              leftIcon!.svg(width: iconWidth.w, height: iconHeight.h),
              SizedBox(width: 8.w),
            ],
            Expanded(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: textSize != null
                    ? AppTextStyle.sub_h1_medium_18(color: textColor).copyWith(fontSize: textSize)
                    : AppTextStyle.sub_h1_medium_18(color: textColor),
              ),
            ),
            if (rightIcon != null) ...[
              SizedBox(width: 8.w),
              rightIcon!.svg(width: iconWidth.w, height: iconHeight.h),
            ],
          ],
        ),
      ),
    );
  }
}
