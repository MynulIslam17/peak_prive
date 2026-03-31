import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/constants/text-style.dart';
import 'package:harry_service_app/app/core/widgets/custom_image_container.dart';
import 'package:harry_service_app/app/modules/chats/controllers/chat_controller.dart';
import '../../../gen/assets.gen.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_parser.dart';

/// MessagingScreen: Chat UI between two users
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
  late final bool isOnline;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    chatId = args['chatId'] ?? '';
    otherUserId = args['otherUserId'] ?? '';
    otherUserProfileUrl = args['otherUserProfileUrl'] ?? '';
    otherUserName = args['otherUserName'] ?? '';
    isOnline = args['isOnline'] ?? false;

    // Fetch previous messages
    if (otherUserId.isNotEmpty) {
      chatController.fetchMessageHistory(otherUserId);
    }

    // Listen for new incoming messages
    chatController.listenToNewMessages(chatId);

    // Listen to typing status from the other user
    chatController.listenToTyping(chatId);

    // Listen to user status
    chatController.initOnlineStatus(isOnline, otherUserId);

    //Listen to mark as read
    chatController.emitMessagesRead(chatId);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),

            // Custom AppBar with profile and name
            buildChatAppBar(
              context,
              otherUserName: otherUserName,
              otherUserProfileUrl: otherUserProfileUrl,
            ),

            const SizedBox(height: 4),

            // Messages List
            GetBuilder<ChatController>(
              builder: (cController) {
                if (cController.isLoading) {
                  return const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary_1,
                      ),
                    ),
                  );
                }

                if(cController.messages.isEmpty){
                  return const Expanded(
                    child: Center(
                      child: Text("No messages"),
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

            // Typing indicator for the other user
            GetBuilder<ChatController>(
              builder: (cController) {
                if (!cController.isOtherUserTyping) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(left: 20, bottom: 4),
                  child: Row(
                    children: [
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Typing",
                              style: AppTextStyle.c_regular_12(color: Colors.blue),
                            ),
                            const SizedBox(width: 4),
                            SpinKitThreeBounce(
                              color: Colors.grey.shade500,
                              size: 12,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Message input field at the bottom
            messageField(messageTEController: _messageTEController),
          ],
        ),
      ),
    );
  }

  /// Custom AppBar showing the other user's profile and name
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
          Stack(
            children: [
              CustomCachedImage(
                imageUrl: otherUserProfileUrl,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                isCircle: true,
              ),
            //  🟢 Online dot
              Positioned(
                bottom: 0,
                right: 0,
                child: GetBuilder<ChatController>(
                  builder: (c) => Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: c.isOtherUserOnline == true ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                otherUserName,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),

              //🟢 Online/offline text
              GetBuilder<ChatController>(
                builder: (c) => Text(
                  c.isOtherUserOnline ? "Online" : "Offline",
                  style: TextStyle(
                    color: c.isOtherUserOnline ? Colors.green : Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Message input field with send button and typing detection
  Widget messageField({required TextEditingController messageTEController}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      color: Colors.white,
      child: Row(
        children: [
          // Text input
          Expanded(
            child: TextField(
              controller: messageTEController,
              maxLines: 4,
              minLines: 1,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  chatController.emitTyping(chatId, otherUserId);
                } else {
                  chatController.emitStoppedTyping(chatId, otherUserId);
                }
              },
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

          // Send button
          IconButton(
            icon: const Icon(Icons.send, color: AppColors.primary_1),
            onPressed: () {
              if (_messageTEController.text.trim().isEmpty) return;

              // Send message using ChatController
              chatController.sendMessage(
                receiverId: otherUserId,
                content: _messageTEController.text,
              );

              // Clear input field and stop typing
              _messageTEController.clear();
              chatController.emitStoppedTyping(chatId, otherUserId);
            },
          ),
        ],
      ),
    );
  }
}

/// Chat bubble for each message
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
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar for received messages
          if (!isMe)
            CustomCachedImage(
              imageUrl: otherUserImage,
              width: 40,
              height: 40,
              isCircle: true,
            ),

          const SizedBox(width: 6),

          // Message container
          Flexible(
            child: Column(
              crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 14),
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

                // Message time
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