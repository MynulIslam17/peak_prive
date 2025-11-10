import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../gen/assets.gen.dart';
import '../constants/app_colors.dart';
import '../constants/text-style.dart';

class ChatsContainer extends StatelessWidget {
  const ChatsContainer({
    super.key,
    required this.images,
    required this.onTap,
  });

  final $AssetsImagesGen images;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
       borderRadius: BorderRadius.circular(14),
      child: Ink(
        width: double.infinity,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              ///  Profile Image
              Stack(
                children: [
                  CircleAvatar(
                    backgroundImage: images.user2.provider(),
                    radius: 28,
                  ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.shade400,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 12),

              ///  Message Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /// Name + time (same row)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "David",
                          style: AppTextStyle.sub_h2_medium_16().copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "10:00 PM",
                          style: AppTextStyle.c_regular_12(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    /// Last message preview
                    Text(
                      "Please send the payment link as soon as possible.",
                      style: AppTextStyle.sub_h3_regular_14().copyWith(
                        color: Colors.grey.shade700,
                        height: 1.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              ///  Unread message indicator
              Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  "2",
                  style: AppTextStyle.c_regular_10(color: Colors.white),

                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
