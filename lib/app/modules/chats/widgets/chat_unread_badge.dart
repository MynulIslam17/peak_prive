import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../controllers/chat_list_controller.dart';

/// Chats tab icon with the total of unread messages.
class ChatUnreadBadge extends StatelessWidget {
  const ChatUnreadBadge(this.icon, {super.key});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ChatListController>()) return Icon(icon);
    return GetBuilder<ChatListController>(
      builder: (c) {
        final n = c.totalUnread;
        return Badge(
          isLabelVisible: n > 0,
          backgroundColor: AppColors.error,
          label: Text(n > 99 ? '99+' : '$n'),
          child: Icon(icon),
        );
      },
    );
  }
}
