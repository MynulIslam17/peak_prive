import '../../modules/notification/widgets/unread_badge.dart';
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/app_colors.dart';
import '../constants/text-style.dart';
import '../controllers/auth_controller.dart';
import 'custom_image_container.dart';

/// Header on the provider tabs: photo, greeting, name, provider type and the
/// notifications button. [t] is the collapse progress (0 roomy, 1 compact
/// app bar) from [CollapsingHeaderLayout].
class ProviderProfile extends StatelessWidget {
  const ProviderProfile({
    super.key,
    required this.onProfileTap,
    required this.onNotificationTap,
    this.t = 0,
  });

  final VoidCallback onProfileTap;
  final VoidCallback onNotificationTap;
  final double t;

  /// Heights for [CollapsingHeaderLayout].
  static const double expandedHeight = 108;
  static const double collapsedHeight = 60;

  static String _greeting(DateTime now) {
    if (now.hour < 12) return 'Good morning 👋';
    if (now.hour < 17) return 'Good afternoon 👋';
    return 'Good evening 👋';
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (authController) {
        final user = authController.userModel;
        final type = (user?.providerType ?? '').replaceAll('_', ' ').trim();
        var name = (user?.fullName ?? '').trim();
        if (name.toUpperCase() == 'N/A') name = '';
        final avatar = lerpDouble(52, 34, t)!;
        final fade = (1 - t * 1.6).clamp(0.0, 1.0);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Semantics(
                button: true,
                label: 'Profile',
                child: GestureDetector(
                  onTap: onProfileTap,
                  child: Container(
                    width: avatar,
                    height: avatar,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary_3, width: 1.5),
                    ),
                    child: CustomCachedImage(
                      width: avatar - 7,
                      height: avatar - 7,
                      imageUrl: user?.profilePic ?? '',
                      isCircle: true,
                    ),
                  ),
                ),
              ),
              SizedBox(width: lerpDouble(14, 10, t)),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (fade > 0)
                      ClipRect(
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          heightFactor: fade,
                          child: Opacity(
                            opacity: fade,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text(
                                _greeting(DateTime.now()),
                                maxLines: 1,
                                style: AppTextStyle.p_regular_12(color: AppColors.textTertiary).copyWith(fontSize: 13),
                              ),
                            ),
                          ),
                        ),
                      ),
                    Text(
                      name.isEmpty ? 'Welcome' : name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.sub_h2_medium_16(color: AppColors.textPrimary).copyWith(
                        fontSize: lerpDouble(21, 16, t),
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                    ),
                    if (type.isNotEmpty) ...[
                      SizedBox(height: lerpDouble(6, 2, t)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBF3DC),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$type provider',
                          style: AppTextStyle.c_regular_10(
                            color: const Color(0xFF9A7A12),
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              UnreadBadge(
                child: Material(
                  color: Colors.white,
                  shape: const CircleBorder(
                    side: BorderSide(color: AppColors.border),
                  ),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onNotificationTap,
                    child: Tooltip(
                      message: 'Notifications',
                      child: SizedBox.square(
                        dimension: lerpDouble(46, 40, t),
                        child: const Icon(Icons.notifications_none_rounded, size: 22, color: AppColors.textPrimary),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
