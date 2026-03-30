import 'package:flutter/material.dart';
import 'package:harry_service_app/app/core/widgets/custom_image_container.dart';
import '../constants/app_colors.dart';
import '../constants/text-style.dart';
import '../utils/date_parser.dart';

class ChatsContainer extends StatelessWidget {
  const ChatsContainer({
    super.key,
    required this.onTap,
    this.image,
    this.userName,
    this.lastText = "",
    this.unReadCount = "0",
    this.lastMessageTime = "",
    this.isOnline = false,
  });

  final String? image;
  final String? userName;
  final String lastText;
  final String unReadCount;
  final String lastMessageTime;
  final bool isOnline;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final DateTime? dateTime = DateParserHelper.parseDate(lastMessageTime);
    final String displayTime = dateTime != null
        ? DateParserHelper.toDisplayDate(dateTime)
        : "--:--";

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
              /// Profile Image with Online Indicator
              Stack(
                children: [
                  CustomCachedImage(
                    imageUrl: image,
                    isCircle: true,
                    width: 60,
                    height: 60,
                  ),
                  if (isOnline)
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

              /// Message Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /// Name + Time
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            userName ?? "__",
                            style: AppTextStyle.sub_h2_medium_16()
                                .copyWith(fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          displayTime,
                          style: AppTextStyle.c_regular_10(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    /// Last message preview
                    Text(
                      lastText.isNotEmpty ? lastText : "No messages yet",
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

              /// Unread message indicator
              if (unReadCount != "0" && unReadCount.isNotEmpty)
                Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    unReadCount,
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