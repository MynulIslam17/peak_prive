import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../gen/assets.gen.dart';
import '../constants/app_colors.dart';
import '../constants/text-style.dart';

class ProviderInfo extends StatelessWidget {
  final String providerName;
  final String rating;
  final String reviewCount;

  final VoidCallback onTapCall;
  final VoidCallback onTapMessage;

  final icon = Assets.icons;
  final image = Assets.images;

  const ProviderInfo({
    super.key,
    this.providerName = "Md Billu",
    this.rating = "0.0",
    this.reviewCount = "0",
    required this.onTapCall,
    required this.onTapMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 353.w,
      height: 80.h,
      decoration: BoxDecoration(
        color: const Color(0xfffdfbf6),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            offset: const Offset(1, 1),
            blurRadius: 3,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          // Profile Image
          CircleAvatar(
            radius: 30,
            backgroundImage: image.user2.provider(),
          ),
          SizedBox(width: 10.w),

          // Name & Rating Column
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Provider Name
                Text(
                  providerName,
                  style: AppTextStyle.p_medium_12().copyWith(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                SizedBox(height: 4.h),
                // Rating Row
                Row(
                  children: [
                    icon.star.svg(width: 14.w, height: 14.h),
                    SizedBox(width: 5.w),
                    Text(
                      rating,
                      style: AppTextStyle.p_regular_12().copyWith(fontSize: 16),
                    ),
                    SizedBox(width: 5.w),
                    Flexible(
                      child: Text(
                        "($reviewCount reviews)",
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

          // Action Icons
          IconButton(
            onPressed: onTapMessage,
            icon: icon.chats.svg(),
          ),
          SizedBox(width: 10.w),
          IconButton(
            onPressed: onTapCall,
            icon: icon.callCircle.svg(),
          ),
        ],
      ),
    );
  }
}
