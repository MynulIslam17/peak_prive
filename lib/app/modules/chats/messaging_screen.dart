import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:harry_service_app/app/core/widgets/custom_image_container.dart';
import 'package:harry_service_app/app/modules/chats/controllers/chat_controller.dart';

import '../../../gen/assets.gen.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_parser.dart';

class MessagingScreen extends StatefulWidget {
  const MessagingScreen({super.key});

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  final chatController = Get.find<ChatController>();
  final TextEditingController _messageTEController = TextEditingController();

  late final String chatId;
  late final String otherUserId;
  late final String otherUserProfileUrl;
  late final String otherUserName;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    chatId = args['chatId'] ?? '';
    otherUserId = args['otherUserId'] ?? '';
    otherUserProfileUrl = args['otherUserProfileUrl'] ?? '';
    otherUserName = args['otherUserName'] ?? '';

    if (otherUserId.isNotEmpty) {
      chatController.fetchMessageHistory(otherUserId);
    }
    chatController.listenToNewMessages(chatId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),

            /// App bar
            buildChatAppBar(
              context,
              otherUserName: otherUserName,
              otherUserProfileUrl: otherUserProfileUrl,
            ),

            const SizedBox(height: 4),

            ///Messages list
            GetBuilder<ChatController>(
              builder: (cController) {
                if (cController.isLoading) {
                  return Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary_1,
                      ),
                    ),
                  );
                }

                return Expanded(
                  child: ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemCount: cController.messages.length,
                    itemBuilder: (context, index) {
                      final msg = cController.messages[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: MessageBubble(
                          message: msg.content,
                          time: msg.createdAt,
                          isMe: cController.currentUserId == msg.sender.id,
                          otherUserImage: otherUserProfileUrl,
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            /// Input field
            messageField(messageTEController: _messageTEController)
           // MessageInputField(messageTEController: _messageTEController),
          ],
        ),
      ),
    );
  }

  /// Custom App Bar
  AppBar buildChatAppBar(
    BuildContext context, {
    required String otherUserName,
    required String otherUserProfileUrl,
  }) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          CustomCachedImage(
            imageUrl: otherUserProfileUrl,
            width: 30,
            height: 30,
            fit: BoxFit.cover,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                otherUserName,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                "Active 2 hours ago",
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  
  Widget messageField({required TextEditingController messageTEController}){
    return  Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      color: Colors.white,
      child: Row(
        children: [
          /// Text field
          Expanded(
            child: TextField(
              controller: messageTEController,
              maxLines: 4,
              minLines: 1,

              decoration: InputDecoration(
                hintText: "Type your message...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
            ),
          ),

          IconButton(
            icon: const Icon(Icons.send, color: AppColors.primary_1),
            onPressed: () {
              if (_messageTEController.text.trim().isEmpty) return;
              chatController.sendMessage(
                receiverId: otherUserId,
                content: _messageTEController.text,
              );
              _messageTEController.clear();
            },
          ),
        ],
      ),
    );
  }
  
  
  
}

/// Chat bubble
class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final String? otherUserImage;
  final String? time;

  const MessageBubble({
    required this.message,
    required this.isMe,
    this.time,
    this.otherUserImage,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateTime = DateParserHelper.parseDate(time ?? "");
    final displayTime = dateTime != null
        ? DateParserHelper.toDisplayDate(dateTime)
        : "--:--";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          /// Avatar for received messages
          if (!isMe)
            CustomCachedImage(
              imageUrl: otherUserImage,
              width: 40,
              height: 40,
              isCircle: true,
            ),

          const SizedBox(width: 6),

          /// Message Bubble
          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 17,
                    horizontal: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.primary_1 : Colors.grey.shade200,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isMe
                          ? const Radius.circular(16)
                          : const Radius.circular(4),
                      bottomRight: isMe
                          ? const Radius.circular(4)
                          : const Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    message,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayTime,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


