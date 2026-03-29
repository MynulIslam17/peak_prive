import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../constants/text-style.dart';
import '../controllers/auth_controller.dart';
import 'custom_image_container.dart';

class ProviderProfile extends StatelessWidget {
  const ProviderProfile({
    super.key,
    required this.onProfileTap,
    required this.onNotificationTap,
  });

  /// Callback for tapping the profile image
  final VoidCallback onProfileTap;

  /// Callback for tapping the notification icon
  final VoidCallback onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (authController) {
        final user = authController.userModel;

        return Row(
          children: [
            // Profile image with click action
            InkWell(
              onTap: onProfileTap,
              child: CustomCachedImage(
                width: 50,
                height: 50,
                imageUrl: user?.profilePic ?? '', // Fallback if image is null
                isCircle: true,
              ),
            ),

            SizedBox(width: 10.w),

            // Name & Role section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.fullName ?? 'No Name',
                  style: AppTextStyle.sub_h3_medium_14(),
                ),
                Text(
                  "${user?.providerType} Provider" ?? '___',
                  style: AppTextStyle.p_medium_12(),
                ),
              ],
            ),

            const Spacer(),

            // Notification icon with callback
            IconButton(
              onPressed: onNotificationTap,
              icon: const Icon(
                Icons.notifications_outlined,
                color: Colors.black87,
              ),
            ),
          ],
        );
      },
    );
  }
}