import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../modules/user/shared/models/category_model.dart';
import '../constants/app_colors.dart';
import '../constants/text-style.dart';

class CategoryList extends StatelessWidget {
  final List<ServiceCategory> categoryList;
  final void Function(String name)? onTap;
  final String? selectedCategoryName;

  const CategoryList({
    super.key,
    required this.categoryList,
    this.onTap,
    this.selectedCategoryName,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100.h,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: categoryList.length,
        separatorBuilder: (_, __) => SizedBox(width: 15.w),
        itemBuilder: (context, index) {
          final category = categoryList[index];
          final isSelected = selectedCategoryName == category.name;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Circle with border
              InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () {
                  if (onTap != null) onTap!(category.name);
                },
                child: Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.primary_1 : Colors.white,
                    border: Border.all(
                      color: isSelected ? Colors.orange : Colors.black54,
                      width: 2,
                    ),
                  ),
                  padding: const EdgeInsets.all(6.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.network(
                      category.categoryPhoto,
                      width: 50.w,
                      height: 50.h,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(Icons.error, size: 40.sp),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 6.h),
              // Fixed width text with ellipsis
              SizedBox(
                width: 75, // Fixed width for all category titles
                child: Text(
                  category.name,
                  style: AppTextStyle.p_medium_12()?.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.normal,
                    fontSize: 11
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
