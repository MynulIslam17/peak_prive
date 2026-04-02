import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/text-style.dart';

class CategoryTitle extends StatelessWidget {
  final String title;
  final String? text;
  final VoidCallback ?onClick;
  const CategoryTitle({
    super.key,
    required this.title,
     this.text,
     this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyle.h3_medium_20()),

        if (text != null)
          InkWell(
            onTap: onClick,
            child: Text(
              text!,
              style: AppTextStyle.c_regular_12(color: AppColors.primary_1),
            ),
          ),
      ],
    );
  }
}