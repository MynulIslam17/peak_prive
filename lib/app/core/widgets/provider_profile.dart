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
    required this.onTap

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
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(

      children: [
        /// Profile Image

        Material(
          shape: CircleBorder(),
          clipBehavior: Clip.hardEdge, // ensures ripple doesn't overflow
          color: Colors.transparent,
          child: Ink.image(
            image: image.provider(), // your image provider
            fit: BoxFit.cover,
            width: 52, // diameter = 2 * radius
            height: 52,
            child: InkWell(
              onTap: onTap,
              splashColor: Colors.grey.withOpacity(0.3), // visible ripple
              highlightColor: Colors.grey.withOpacity(0.1), // subtle highlight
              customBorder: CircleBorder(), // keeps ripple circular
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
            child: icon!.svg(width: 25, height: 25),
          ),
      ],
    );
  }
}
