import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/text-style.dart';

class ProviderProfile extends StatelessWidget {
  const ProviderProfile({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.role,
    this.icon,
    this.onIconTap,
    required this.onTap,
  });

  /// Network image URL
  final String imageUrl;

  /// Provider name
  final String name;

  /// Provider role / designation (e.g., "Ski Pass Provider")
  final String role;

  /// Optional notification or action icon
  final Widget? icon;

  /// Optional callback for icon tap
  final VoidCallback? onIconTap;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        /// Profile Image from network
        Material(
          shape: CircleBorder(),
          clipBehavior: Clip.hardEdge,
          color: Colors.transparent,
          child: Ink.image(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
            width: 52,
            height: 52,
            child: InkWell(
              onTap: onTap,
              splashColor: Colors.grey.withOpacity(0.3),
              highlightColor: Colors.grey.withOpacity(0.1),
              customBorder: CircleBorder(),
            ),
          ),
        ),

        SizedBox(width: 10.w),

        /// Name & Role Section
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: AppTextStyle.sub_h3_medium_14(),
            ),
            Text(
              role,
              style: AppTextStyle.p_medium_12(),
            ),
          ],
        ),

        const Spacer(),

        /// Optional Action Icon
        if (icon != null)
          InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: onIconTap,
            child: icon!,
          ),
      ],
    );
  }
}
