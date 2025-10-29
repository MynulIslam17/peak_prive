import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../gen/assets.gen.dart';
import '../constants/text-style.dart';

class CategoryList extends StatelessWidget {
  final List<dynamic> icons; // SvgGenImage or AssetGenImage
  final List<String> titles;
  final VoidCallback onTap;

  const CategoryList({
    super.key,
    required this.icons,
    required this.titles,
    required this.onTap,
  }) : assert(
  icons.length == titles.length,
  'Icons and titles must have the same length',
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: titles.length,
        separatorBuilder: (_, __) => SizedBox(width: 40.w),
        itemBuilder: (context, index) {
          final icon = icons[index];
          Widget iconWidget;

          // Render SVG or PNG dynamically
          if (icon is SvgGenImage) {
            iconWidget = icon.svg(width: 33.w, height: 33.h);
          } else if (icon is AssetGenImage) {
            iconWidget = icon.image(width: 33.w, height: 33.h, fit: BoxFit.cover);
          } else {
            iconWidget = SizedBox(width: 33.w, height: 33.h);
          }

          return InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  iconWidget,
                  SizedBox(height: 6.h),
                  Text(
                    titles[index],
                    style: AppTextStyle.p_medium_12(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
