
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../gen/assets.gen.dart';
import '../constants/text-style.dart';

class CategoryList extends StatelessWidget {
  final List<SvgGenImage> icons;
  final List<String> titles;

  const CategoryList({
    super.key,
    required this.icons,
    required this.titles,
  }) : assert(
  icons.length == titles.length,
  'Icons and titles must have the same length',
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60.h, // better than Flexible for predictable layout
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: titles.length,
        separatorBuilder: (_, __) => SizedBox(width: 40.w),
        itemBuilder: (context, index) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Category Icon
              icons[index].svg(
                width: 33.w,
                height: 33.h,
              ),

              SizedBox(height: 6.h),

              /// Category Title
              Text(
                titles[index],
                style: AppTextStyle.p_medium_12(),
              ),
            ],
          );
        },
      ),
    );
  }
}