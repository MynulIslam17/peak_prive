// UserContactCard Widget
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';
import '../constants/text-style.dart';

class UserContactCard extends StatelessWidget {
  final String userName;
  final String location;
  final String? profileImageUrl;
  final VoidCallback onTapCall;
  final VoidCallback onTapMessage;

  const UserContactCard({
    super.key,
    required this.userName,
    required this.location,
    this.profileImageUrl,
    required this.onTapCall,
    required this.onTapMessage,
  });

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required double size,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: Colors.black38,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Center(
            child: Icon(
              icon,
              color: Colors.white,
              size: size * 0.5,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double cardHeight = 80.0;
    final double avatarRadius = 30.0;
    final double iconButtonSize = 50.0;

    return Container(
      height: cardHeight,
      width: double.infinity,
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
            radius: avatarRadius,
            backgroundColor: Colors.grey.shade400,
            backgroundImage: profileImageUrl != null && profileImageUrl!.isNotEmpty
                ? NetworkImage(profileImageUrl!)
                : null,
            child: profileImageUrl == null || profileImageUrl!.isEmpty
                ? Icon(
              Icons.person,
              size: 30,
              color: Colors.white,
            )
                : null,
          ),

          SizedBox(width: 10.w),

          // Name & Location
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: AppTextStyle.p_medium_12().copyWith(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                SizedBox(height: 4.h),
                Text(
                  location,
                  style: AppTextStyle.p_regular_12()
                      .copyWith(fontSize: 14, color: AppColors.black_3),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),

          SizedBox(width: 10.w),

          // Message Button
          _buildActionButton(
            onPressed: onTapMessage,
            icon: Icons.message_outlined,
            size: iconButtonSize,
          ),
          SizedBox(width: 10.w),

          // Call Button
          _buildActionButton(
            onPressed: onTapCall,
            icon: Icons.call,
            size: iconButtonSize,
          ),
        ],
      ),
    );
  }
}