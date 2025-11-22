import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../modules/user/shared/models/category_model.dart';
import '../constants/text-style.dart';

class CategoryList extends StatelessWidget {
  final List<ServiceCategory> categoryList;
  final void Function(String name)? onTap;

  const CategoryList({
    super.key,
    required this.categoryList,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categoryList.length,
        separatorBuilder: (_, __) => SizedBox(width: 40.w),
        itemBuilder: (context, index) {
          final category = categoryList[index];
          final name=category.name;

          return InkWell(
            onTap: () => onTap?.call(name),
            borderRadius: BorderRadius.circular(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.network(
                    category.categoryPhoto,
                    width: 33.w,
                    height: 33.h,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.error, size: 24),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(category.name, style: AppTextStyle.p_medium_12()),
              ],
            ),
          );
        },
      ),
    );
  }
}
