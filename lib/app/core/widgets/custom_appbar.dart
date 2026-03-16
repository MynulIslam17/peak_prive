import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color backgroundColor;
  final bool centerTitle;
  final double elevation;
  final Color iconColor;
  final VoidCallback? onBackPressed;
  final bool showBackButton; // NEW

  const CustomAppBar({
    super.key,
    required this.title,
    this.backgroundColor = const Color(0xffF9F7F3),
    this.centerTitle = true,
    this.elevation = 0,
    this.iconColor = Colors.black,
    this.onBackPressed,
    this.showBackButton = true, // default true
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: elevation,
      centerTitle: centerTitle,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,

          color: Colors.black,
        ),
      ),
      leading: showBackButton
          ? IconButton(
        onPressed: onBackPressed ?? () => Get.back(),
        icon: Icon(Icons.arrow_back_ios, color: iconColor),
      )
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}