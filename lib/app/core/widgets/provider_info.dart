import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../gen/assets.gen.dart';
import '../constants/app_colors.dart';
import '../constants/text-style.dart';

class ProviderInfo extends StatelessWidget {


  final icon=Assets.icons;
  final image=Assets.images;

  final VoidCallback onTapCall;
  final VoidCallback onTapMessage;
  const ProviderInfo({
    super.key,

    required this.onTapCall,
    required this.onTapMessage,
  });

  // final $AssetsImagesGen image;
  // final $AssetsIconsGen icons;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 353.w,
      height: 80.h,
      decoration: BoxDecoration(
        color: Color(0xfffdfbf6),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            offset: Offset(1, 1),
            blurRadius: 3,
          ),
        ],
      ),

      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            /// --- Profile Image ---
            CircleAvatar(
              radius: 30,
              backgroundImage: image.user2.provider(),
            ),

            SizedBox(width: 10.w),

            /// --- Name & Rating Column ---
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// --- User Name ---
                  Text(
                    "Md. Billu Miya",
                    style: AppTextStyle.p_medium_12().copyWith(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),

                  /// --- Rating Row ---
                  Row(
                    children: [
                      /// Star Icon
                      icon.star.svg(width: 14.w, height: 14.h),
                      SizedBox(width: 5.w),

                      /// Rating Value
                      Text(
                        "4.5",
                        style: AppTextStyle.p_regular_12().copyWith(fontSize: 16),
                      ),
                      SizedBox(width: 5.w),

                      /// Number of Reviews
                      Flexible(
                        child: Text(
                          "(150+)",
                          style: AppTextStyle.p_regular_12()
                              .copyWith(fontSize: 16, color: AppColors.black_3),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// --- Action Icons (Chat & Call) ---
            IconButton(onPressed: onTapMessage,
                icon: icon.chats.svg()),
            SizedBox(width: 10.w),

            IconButton(onPressed: onTapCall,
                icon: icon.callCircle.svg()),

          ],
        ),
      ),
    );
  }
}