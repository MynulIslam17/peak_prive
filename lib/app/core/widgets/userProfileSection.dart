import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../gen/assets.gen.dart';
import '../constants/text-style.dart';
import 'make_clickable.dart';

class UserProfileSection extends StatelessWidget {
  /// ------------------------- PARAMETERS -------------------------
  final String name;
  final String welcomeText;
  final String image;
  final VoidCallback onTap;

  /// ------------------------- CONSTRUCTOR -------------------------
  const UserProfileSection({
    super.key,
    required this.name,
    this.welcomeText = "Good to see you!",
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final icons = Assets.icons;

    return Row(
      children: [
        /// ------------------------- PROFILE IMAGE -------------------------
        CircleAvatar(
          radius: 26,
          backgroundImage: NetworkImage(image)
        ),



        SizedBox(width: 10.w),

        /// ------------------------- NAME & WELCOME -------------------------
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// User Name
            Text(
              name,
              style: AppTextStyle.sub_h3_medium_14(),
            ),

            SizedBox(height: 4.h),

            /// Location Icon + Welcome Text
            Row(
              children: [
                icons.loacation.svg(),
                SizedBox(width: 6.w),
                Text(
                  welcomeText,
                  style: AppTextStyle.p_medium_12(),
                ),
              ],
            ),
          ],
        ),

        const Spacer(),

        /// ------------------------- NOTIFICATION BUTTON -------------------------
        MakeClickable(
          onTap: onTap,
          child: Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: icons.bellRinging.svg(),
            ),
          ),
        ),
      ],
    );
  }
}
