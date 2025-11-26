import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';

import '../../../gen/assets.gen.dart';

class AppBarWithTitle extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBack;
   final VoidCallback onTap;

  const AppBarWithTitle({
    super.key,
    required this.icons,
     this.title,
    this.showBack = true,
    required this.onTap,
  });

  final $AssetsIconsGen icons;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      title: Stack(
        alignment: Alignment.center,
        children: [

          if(showBack)
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: icons.caretLeft.svg(
                color: Colors.black,
                width: 30,
                height: 30,
              ),
            ),
          ),

          if (title != null)
            Center(child: Text(title!, style: AppTextStyle.sub_h1_regular_18().copyWith(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
