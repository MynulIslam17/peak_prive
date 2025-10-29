import 'package:flutter/material.dart';
import '../../../gen/assets.gen.dart';
import '../constants/app_colors.dart';
import '../constants/text-style.dart';

class CustomAppBarWithTabBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final VoidCallback onTap;
  final TabController? controller;
  final List<String>? tabNames;

  const CustomAppBarWithTabBar({
    super.key,
    required this.title,
    required this.onTap,
    this.controller,
    this.tabNames,
  });

  @override
  Size get preferredSize => const Size.fromHeight(90);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text(
        title,
        style: AppTextStyle.h3_medium_20(),
      ),
      leading: IconButton(
        onPressed: onTap,
        icon: Assets.icons.caretLeft.svg(
          color: Colors.black,
          width: 30,
          height: 30,
        ),
      ),
      bottom: (tabNames != null && tabNames!.isNotEmpty && controller != null)
          ? TabBar(
        controller: controller,
        isScrollable: false,
        indicatorColor: AppColors.primary_1,
        indicatorWeight: 3,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey,
        labelStyle: AppTextStyle.sub_h3_medium_14(),
        tabs: tabNames!.map((name) => Tab(text: name)).toList(),
      )
          : null,
    );
  }
}
