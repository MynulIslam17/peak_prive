import 'package:flutter/material.dart';

import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/text-style.dart';
import '../../../../../../core/widgets/custom_image_container.dart';
import '../../../../../../core/widgets/shimmer/skeleton.dart';
import '../../../../../../data/api/peak_api.dart';

/// Horizontal row of category pills with a leading "All" option.
///
/// [selected] is the sub-category id, `null` when "All" is active.
class HomeCategoryBar extends StatelessWidget {
  const HomeCategoryBar({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
    required this.isLoading,
    required this.horizontalPadding,
  });

  final List<CategoryOption> categories;
  final String? selected;
  final ValueChanged<String?> onSelected;
  final bool isLoading;
  final double horizontalPadding;

  static const double height = 44;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.3);
    final h = height * textScale;
    if (isLoading) return _Skeleton(height: h, padding: horizontalPadding);
    if (categories.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _CategoryPill(
              label: 'All',
              isSelected: selected == null,
              onTap: () => onSelected(null),
              icon: const Icon(Icons.grid_view_rounded, size: 18),
            );
          }
          final category = categories[index - 1];
          return _CategoryPill(
            label: category.name,
            isSelected: selected == category.id,
            onTap: () => onSelected(category.id),
            image: category.photo ?? '',
          );
        },
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.image,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? icon;
  final String? image;

  static const _dark = Color(0xFF161616);

  @override
  Widget build(BuildContext context) {
    final fg = isSelected ? Colors.white : AppColors.textPrimary;
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.fromLTRB(image != null ? 5 : 14, 5, 16, 5),
            decoration: ShapeDecoration(
              color: isSelected ? _dark : Colors.white,
              shape: StadiumBorder(
                side: BorderSide(color: isSelected ? _dark : AppColors.border),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (image != null)
                  Container(
                    width: 32,
                    height: 32,
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.surfaceAlt),
                    child: CustomCachedImage(imageUrl: image!, width: 32, height: 32, isCircle: true),
                  )
                else
                  IconTheme(data: IconThemeData(color: fg, size: 18), child: icon!),
                const SizedBox(width: 8),
                Text(
                  label,
                  maxLines: 1,
                  style: AppTextStyle.sub_h3_medium_14(color: fg).copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton({required this.height, required this.padding});

  final double height;
  final double padding;

  @override
  Widget build(BuildContext context) {
    const widths = [64.0, 104.0, 120.0, 92.0];
    return SizedBox(
      height: height,
      child: SkeletonShimmer(
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: padding),
          itemCount: widths.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) => SkeletonBox(width: widths[i], height: height, radius: height / 2),
        ),
      ),
    );
  }
}
