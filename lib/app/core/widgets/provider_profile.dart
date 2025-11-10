import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../gen/assets.gen.dart';
import '../constants/text-style.dart';

class ProviderProfile extends StatelessWidget {
  const ProviderProfile({
    super.key,
    required this.image,
    required this.name,
    required this.role,
    this.icon,
    this.onIconTap,
  });

  /// Accepts an image (can be from FlutterGen or custom)
  final AssetGenImage image;

  /// Provider name
  final String name;

  /// Provider role / designation (e.g., "Ski Pass Provider")
  final String role;

  /// Optional notification or action icon
  final SvgGenImage? icon;

  /// Optional callback for icon tap
  final VoidCallback? onIconTap;

  @override
  Widget build(BuildContext context) {
    return Row(

      children: [
        /// Profile Image
        CircleAvatar(
          backgroundImage: image.provider(),
          radius: 26,
        ),

        SizedBox(width: 10.w),

        /// Name & Role Section
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: AppTextStyle.h3_semibold_20(),
            ),
            Text(
              role,
              style: AppTextStyle.c_regular_12(),
            ),
          ],
        ),

        const Spacer(),

        /// Optional Action Icon
        if (icon != null)
          InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: onIconTap,
            child: icon!.svg(width: 25, height: 25),
          ),
      ],
    );
  }
}
