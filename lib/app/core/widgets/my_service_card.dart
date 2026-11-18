import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/text-style.dart';
import 'custom_image_container.dart';

/// A provider's own listing: photo, price, rating, area, and edit / delete
/// actions. Used on the provider home carousel and the services tab.
class MyServiceCard extends StatelessWidget {
  const MyServiceCard({
    super.key,
    required this.image,
    required this.title,
    required this.status,
    required this.rating,
    required this.reviews,
    required this.location,
    required this.onDelete,
    required this.onEdit,
    this.packageType,
    this.isActive = true,
    this.onActiveChanged,
    this.busy = false,
  });

  final String image;
  final String title;

  /// Price label ("from €20 / day") or, for restaurants, the open status.
  final String status;
  final double rating;
  final int reviews;
  final String location;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  /// Small badge over the photo (e.g. the ski pass type).
  final String? packageType;

  /// Hidden from guests when false (shows an "Inactive" badge).
  final bool isActive;

  /// Shows a "Visible to guests" switch when set.
  final ValueChanged<bool>? onActiveChanged;

  /// A status change or delete is in flight.
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final badge = (packageType ?? '').trim();

    return Container(
      height: onActiveChanged != null ? 290 : 255,
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                CustomCachedImage(
                  imageUrl: image,
                  fit: BoxFit.cover,
                  customBorderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  right: 10,
                  child: Row(
                    children: [
                      if (badge.isNotEmpty)
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary_1,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              badge,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyle.p_medium_12(
                                color: AppColors.textOnPrimary,
                              ),
                            ),
                          ),
                        ),
                      if (!isActive) ...[
                        if (badge.isNotEmpty) const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('Inactive',
                              style: AppTextStyle.p_medium_12(color: Colors.white)),
                        ),
                      ],
                      const Spacer(),
                      _CircleAction(
                        icon: Icons.edit_outlined,
                        color: AppColors.textPrimary,
                        tooltip: 'Edit',
                        onTap: onEdit,
                      ),
                      const SizedBox(width: 8),
                      _CircleAction(
                        icon: Icons.delete_outline_rounded,
                        color: AppColors.error,
                        tooltip: 'Delete',
                        onTap: onDelete,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title.trim().isEmpty ? 'Untitled' : title.trim(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.sub_h3_semibold_14(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 150),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          status,
                          maxLines: 1,
                          style: AppTextStyle.sub_h3_semibold_14(
                            color: status.trim().toLowerCase() == 'closed'
                                ? AppColors.textTertiary
                                : const Color(0xFF9A7A12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: AppColors.primary_1,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      reviews == 0 ? 'New' : rating.toStringAsFixed(1),
                      style: AppTextStyle.p_medium_12(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (reviews > 0) ...[
                      const SizedBox(width: 4),
                      Text(
                        '($reviews)',
                        style: AppTextStyle.p_regular_12(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                    const SizedBox(width: 12),
                    if (location.trim().isNotEmpty) ...[
                      const Icon(
                        Icons.location_on_outlined,
                        size: 15,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          location.trim(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.p_regular_12(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (onActiveChanged != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        isActive ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        size: 16,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          isActive ? 'Visible to guests' : 'Hidden from guests',
                          style: AppTextStyle.p_regular_12(color: AppColors.textSecondary),
                        ),
                      ),
                      SizedBox(
                        height: 28,
                        child: FittedBox(
                          child: Switch.adaptive(
                            value: isActive,
                            activeTrackColor: AppColors.primary_1,
                            onChanged: busy ? null : onActiveChanged,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 1,
      shadowColor: Colors.black26,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Tooltip(
          message: tooltip,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 18, color: color),
          ),
        ),
      ),
    );
  }
}
