import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/app_colors.dart';
import '../constants/text-style.dart';

/// Standard title bar: cream background, centred title, back arrow.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color backgroundColor;
  final bool centerTitle;
  final double elevation;
  final Color iconColor;
  final VoidCallback? onBackPressed;
  final bool showBackButton;

  const CustomAppBar({
    super.key,
    required this.title,
    this.backgroundColor = AppColors.scaffold,
    this.centerTitle = true,
    this.elevation = 0,
    this.iconColor = AppColors.textPrimary,
    this.onBackPressed,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: elevation,
      scrolledUnderElevation: 0,
      centerTitle: centerTitle,
      automaticallyImplyLeading: false,
      title: Text(
        title,
        style: AppTextStyle.sub_h1_medium_18(color: AppColors.textPrimary),
      ),
      leading: showBackButton
          ? IconButton(
              tooltip: 'Back',
              onPressed: onBackPressed ?? () => Get.back(),
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 20, color: iconColor),
            )
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
