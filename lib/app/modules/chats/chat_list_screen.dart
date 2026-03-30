import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/core/controllers/nav_controller.dart';
import 'package:harry_service_app/app/core/widgets/appbar_with_title.dart';
import 'package:harry_service_app/app/core/widgets/custom_appbar.dart';
import 'package:harry_service_app/app/modules/chats/controllers/chat_list_controller.dart';

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
    // TODO: implement initState
    super.initState();
    chatListController.fetchChatList();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: CustomAppBar(
        title: "Chat list",
        onBackPressed: () {
          Get.find<NavController>().changeIndex(0);
        },
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: Column(
          children: [
            /// search bar
            Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(1, 3),
                  ),
                ],
              ),
              child: TextField(
                cursorColor: AppColors.primary_1,
                decoration: InputDecoration(
                  hintText: "Search by name...",
                  hintStyle: AppTextStyle.sub_h3_medium_14(color: Colors.grey),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(Icons.search, color: Colors.grey.shade600),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 35),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 14,
                  ),

                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),

            SizedBox(height: 16),

            /// recent chat list
            GetBuilder<ChatListController>(

              builder: (controller) {

                if(controller.isLoading){
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary_1,
                    ),
                  );
                }

                if(controller.errorMessage!=null){
                  return Center(
                    child: Text(controller.errorMessage!),
                  );
                }


                if(controller.chatList.length==0){
                  return Center(
                    child: Text("No chat found"),
                  );
                }


                return Expanded(
                  child: ListView.builder(
                    itemCount: controller.chatList.length,
                    itemBuilder: (context, index) {
                      final chat = controller.chatList[index];
                      final otherUser = chat.otherUser;
                      final lastMessage = chat.lastMessage;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: ChatsContainer(
                          image: otherUser.profileUrl,
                          lastText: lastMessage.content,
                          lastMessageTime: chat.lastMessageAt,
                           unReadCount: chat.unreadCount.toString(),
                           userName: otherUser.fullName,

                          onTap: () {
                            Get.toNamed(
                              Routes.messagingScreen,
                              arguments: {
                                'otherUserId': otherUser.id,
                                 "chatId" : chat.chatId,
                                  "otherUserName" : otherUser.fullName,
                                  'otherUserProfileUrl': otherUser.profileUrl ?? '',

                              }

                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
