import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/core/controllers/nav_controller.dart';
import 'package:harry_service_app/app/core/widgets/custom_appbar.dart';
import 'package:harry_service_app/app/modules/chats/controllers/chat_list_controller.dart';
import 'package:shimmer/shimmer.dart';
import '../../../gen/assets.gen.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/chats_container.dart';
import '../../routes/app_routes.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// Custom app bar
      appBar: CustomAppBar(
        title: "Chat list",
        onBackPressed: () {
          Get.find<NavController>().changeIndex(0);
        },
      ),

      /// Body
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Column(
          children: [
            // /// Search bar
            // Container(
            //   width: double.infinity,
            //   height: 52,
            //   decoration: BoxDecoration(
            //     borderRadius: BorderRadius.circular(16),
            //     color: Colors.white,
            //     boxShadow: [
            //       BoxShadow(
            //         color: Colors.grey.withOpacity(0.15),
            //         blurRadius: 8,
            //         offset: const Offset(1, 3),
            //       ),
            //     ],
            //   ),
            //   child: TextField(
            //     cursorColor: AppColors.primary_1,
            //     decoration: InputDecoration(
            //       hintText: "Search by name...",
            //       hintStyle: AppTextStyle.sub_h3_medium_14(color: Colors.grey),
            //       prefixIcon: Padding(
            //         padding: const EdgeInsets.symmetric(horizontal: 12),
            //         child: Icon(Icons.search, color: Colors.grey.shade600),
            //       ),
            //       prefixIconConstraints: const BoxConstraints(minWidth: 35),
            //       contentPadding: const EdgeInsets.symmetric(
            //         horizontal: 10,
            //         vertical: 14,
            //       ),
            //       border: InputBorder.none,
            //       enabledBorder: InputBorder.none,
            //       focusedBorder: InputBorder.none,
            //     ),
            //   ),
            // ),

            const SizedBox(height: 16),

            /// Chat list
            GetBuilder<ChatListController>(
              builder: (controller) {
                // Loading state
                if (controller.isLoading) {
                  return Expanded(
                    child: Center(
                      child:_shimmerBox()
                    ),
                  );
                }

                // Error state
                if (controller.errorMessage != null) {
                  return Expanded(
                    child: Center(
                      child: Text(controller.errorMessage!),
                    ),
                  );
                }

                // Empty state
                if (controller.chatList.isEmpty) {
                  return const Expanded(
                    child: Center(
                      child: Text("No chat found"),
                    ),
                  );
                }

                // Chat list with pull-to-refresh
                return Expanded(
                  child: RefreshIndicator(
                    color: AppColors.primary_1,
                    onRefresh: () async {
                      await chatListController.fetchChatList();
                    },
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: controller.chatList.length,
                      itemBuilder: (context, index) {
                        final chat = controller.chatList[index];
                        final otherUser = chat.otherUser;
                        final lastMessage = chat.lastMessage;
                        final senderId = lastMessage.sender.id;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: ChatsContainer(
                            image: otherUser.profileUrl,
                            lastText: lastMessage.content,
                            lastMessageTime: chat.lastMessageAt,
                            unReadCount: chat.unreadCount.toString(),
                            userName: otherUser.fullName,
                            isOnline: otherUser.isOnline,
                            senderId: senderId,
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
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }


  Widget _shimmerBox() {
    return ListView.builder(
      itemCount: 8,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),

                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


}