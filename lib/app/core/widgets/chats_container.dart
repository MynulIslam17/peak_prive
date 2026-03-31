import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/widgets/custom_image_container.dart';
import '../constants/app_colors.dart';
import '../constants/text-style.dart';
import '../controllers/auth_controller.dart';
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
    this.senderId,
  });

  final String? image;
  final String? userName;
  final String lastText;
  final String unReadCount;
  final String lastMessageTime;
  final String? senderId;
  final bool isOnline;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Parse time for display
    final DateTime? dateTime = DateParserHelper.parseDate(lastMessageTime);
    final String displayTime = dateTime != null
        ? DateParserHelper.toDisplayDate(dateTime)
        : "";

    // Check if the current user is the sender
    final bool isMessageFromMe = senderId == Get.find<AuthController>().userModel?.id;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildAvatar(),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildHeader(displayTime),
                  const SizedBox(height: 4),
                  _buildMessagePreview(isMessageFromMe),
                ],
              ),
            ),

            const SizedBox(width: 8),
            _buildTrailingIndicator(),
          ],
        ),
      ),
    );
  }

  /// Builds the user profile image with online status indicator
  Widget _buildAvatar() {
    return Stack(
      children: [
        CustomCachedImage(
          imageUrl: image,
          isCircle: true,
          width: 55,
          height: 55,
        ),
        if (isOnline)
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.greenAccent.shade700,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  /// Builds the top row containing the name and the time
  Widget _buildHeader(String displayTime) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            userName ?? "Unknown User",
            style: AppTextStyle.sub_h2_medium_16().copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          displayTime,
          style: AppTextStyle.c_regular_10(
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  /// Builds the message preview with status icons (Sent/Received)
  Widget _buildMessagePreview(bool isMe) {
    if (lastText.isEmpty) {
      return Text(
        "No messages yet",
        style: AppTextStyle.sub_h3_regular_14().copyWith(
          color: Colors.grey.shade400,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Row(
      children: [
        // Using check icons for sent messages, and arrow for received
        Icon(
          isMe ? Icons.done_all : Icons.south_west,
          size: 14,
          color: isMe ? Colors.blue : Colors.grey,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            lastText,
            style: AppTextStyle.sub_h3_regular_14().copyWith(
              color: Colors.grey.shade600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Builds the unread count badge
  Widget _buildTrailingIndicator() {
    final int count = int.tryParse(unReadCount) ?? 0;
    if (count <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(6),
      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
      decoration: BoxDecoration(
        color: AppColors.primary_1,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          count > 99 ? "99+" : unReadCount,
          style: AppTextStyle.c_regular_10(color: Colors.white).copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 9,
          ),
        ),
      ),
    );
  }
}