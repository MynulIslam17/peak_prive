import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/modules/chats/controllers/chat_list_controller.dart';
import 'package:harry_service_app/app/core/widgets/shimmer/skeleton.dart';
import '../../../gen/assets.gen.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/chats_container.dart';
import '../../core/widgets/collapsing_header.dart';
import '../../routes/app_routes.dart';
import '../provider/shared/widgets/provider_ui.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final chatListController = Get.find<ChatListController>();
  final icons = Assets.icons;
  final images = Assets.images;

  @override
  void initState() {
    super.initState();
    // Initial fetch of chat list
    chatListController.fetchChatList();
    chatListController.listenToUserStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: CollapsingHeaderLayout(
        expandedHeight: 76,
        collapsedHeight: 56,
        header: (_, t) => GetBuilder<ChatListController>(
          builder: (c) =>
              LargeTitleHeader(title: 'Messages', t: t, count: c.chatList.isEmpty ? null : c.chatList.length),
        ),
        body: (_, insets) => GetBuilder<ChatListController>(
          builder: (controller) {
            final chats = controller.chatList;

            Widget body;
            if (controller.isLoading && chats.isEmpty) {
              body = _shimmerBox(insets);
            } else if (controller.errorMessage != null && chats.isEmpty) {
              body = _message(
                insets,
                ProviderEmptyState(
                  icon: Icons.wifi_off_rounded,
                  title: "Couldn't load your messages",
                  message: controller.errorMessage,
                  actionLabel: 'Try again',
                  onAction: chatListController.fetchChatList,
                ),
              );
            } else if (chats.isEmpty) {
              body = _message(
                insets,
                const ProviderEmptyState(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'No messages yet',
                  message: 'Conversations about your bookings show up here.',
                ),
              );
            } else {
              body = ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24) + insets,
                itemCount: chats.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  final otherUser = chat.otherUser;
                  final lastMessage = chat.lastMessage;

                  return ChatsContainer(
                    image: otherUser.profileUrl,
                    lastText: lastMessage.content,
                    // The message's own time; `lastMessageAt` can differ.
                    lastMessageTime: lastMessage.createdAt.isNotEmpty ? lastMessage.createdAt : chat.lastMessageAt,
                    unReadCount: chat.unreadCount.toString(),
                    userName: otherUser.fullName,
                    isOnline: otherUser.isOnline,
                    senderId: lastMessage.sender.id,
                    onTap: () {
                      Get.toNamed(
                        Routes.messagingScreen,
                        arguments: {
                          'otherUserId': otherUser.id,
                          'chatId': chat.chatId,
                          'otherUserName': otherUser.fullName,
                          'otherUserProfileUrl': otherUser.profileUrl ?? '',
                          'isOnline': otherUser.isOnline,
                        },
                      );
                    },
                  );
                },
              );
            }

            return RefreshIndicator(
              color: AppColors.primary_1,
              edgeOffset: CollapsingHeaderLayout.refreshEdge(context),
              onRefresh: chatListController.fetchChatList,
              child: body,
            );
          },
        ),
      ),
    );
  }

  /// Scrollable so pull-to-refresh still works on empty / error states.
  Widget _message(EdgeInsets insets, Widget child) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24) + insets,
    children: [child],
  );

  /// Shaped like [ChatsContainer]: white card, 55 avatar, name + time,
  /// message preview.
  Widget _shimmerBox(EdgeInsets insets) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24) + insets,
      itemCount: 7,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: SkeletonShimmer(
          child: Row(
            children: [
              const SkeletonBox(height: 55, circle: true),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      SkeletonBox(width: i.isEven ? 120 : 90, height: 14),
                      const Spacer(),
                      const SkeletonBox(width: 34, height: 9),
                    ]),
                    const SizedBox(height: 10),
                    SkeletonBox(width: i.isEven ? 180 : 140, height: 11),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
