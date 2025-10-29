import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../gen/assets.gen.dart';
import '../constants/text-style.dart';
import 'make_clickable.dart';

class UserProfileSection extends StatelessWidget {

  final AssetGenImage  image;

  final String location;
  final VoidCallback onTap;

  const UserProfileSection({
    super.key,
    required this.image,

    required this.location,
    required this.onTap,

  });

final icons=Assets.icons;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        /// Profile Image
        CircleAvatar(radius: 20, backgroundImage: image.provider()),

        SizedBox(width: 10.w),

        /// Location Info
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text("Select Location", style: AppTextStyle.c_regular_12()),
                icons.arrowBottom.svg(),
              ],
            ),
            Row(
              children: [
                icons.loacation.svg(),
                SizedBox(width: 10.w),
                Text(location, style: AppTextStyle.c_regular_12()),
              ],
            ),
          ],
        ),

        const Spacer(),

        /// Notification
        MakeClickable(
          onTap:onTap,
          child: Container(
            width: 40.w,
            height: 40.h,
            decoration: const BoxDecoration(
              color: Colors.grey,
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