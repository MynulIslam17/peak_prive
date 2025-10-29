import 'package:flutter/material.dart';
import '../../../gen/assets.gen.dart';
import '../constants/app_colors.dart';
import '../constants/text-style.dart';

class AppBarWithUserInfo extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final icon = Assets.icons;

  const AppBarWithUserInfo({
    super.key,
    required this.onTap,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          /// back button
          Container(
            decoration: BoxDecoration(
              color: AppColors.secendary,
              shape: BoxShape.circle
            ),
            child: IconButton(onPressed: onTap,
                icon: icon.caretLeft.svg()
            ),
          ),

          /// Title
          Text(
            title,
            style: AppTextStyle.h3_medium_20(color: Colors.white),
          ),

          /// Spacer to balance the back button
           SizedBox(),
        ],
      ),
    );
  }
}
