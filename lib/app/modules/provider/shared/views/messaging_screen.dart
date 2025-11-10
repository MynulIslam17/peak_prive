import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../gen/assets.gen.dart';
import '../../../../core/constants/app_colors.dart';



class MessagingScreen extends StatefulWidget {
  const MessagingScreen({super.key});

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  final TextEditingController _messageTEController = TextEditingController();

  final images=Assets.images;
  final icons=Assets.icons;

  // Dummy messages
  final List<Map<String, dynamic>> messages = [
    {"text": "Hello, is the oven still available for booking?", "time": "8:28 PM", "isMe": true},
    {"text": "Yes, it is! You can send your booking request now.", "time": "8:29 PM", "isMe": false},   {"text": "Hello, is the oven still available for booking?", "time": "8:28 PM", "isMe": true},
    {"text": "Yes, it is! You can send your booking request now.", "time": "8:29 PM", "isMe": false},   {"text": "Hello, is the oven still available for booking?", "time": "8:28 PM", "isMe": true},
    {"text": "Yes, it is! You can send your booking request now.", "time": "8:29 PM", "isMe": false},   {"text": "Hello, is the oven still available for booking?", "time": "8:28 PM", "isMe": true},
    {"text": "Yes, it is! You can send your booking request now.", "time": "8:29 PM", "isMe": false},   {"text": "Hello, is the oven still available for booking?", "time": "8:28 PM", "isMe": true},
    {"text": "Yes, it is! You can send your booking request now.", "time": "8:29 PM", "isMe": false},   {"text": "Hello, is the oven still available for booking?", "time": "8:28 PM", "isMe": true},
    {"text": "Yes, it is! You can send your booking request now.", "time": "8:29 PM", "isMe": false},   {"text": "Hello, is the oven still available for booking?", "time": "8:28 PM", "isMe": true},
    {"text": "Yes, it is! You can send your booking request now.", "time": "8:29 PM", "isMe": false},   {"text": "Hello, is the oven still available for booking?", "time": "8:28 PM", "isMe": true},
    {"text": "Yes, it is! You can send your booking request now.", "time": "8:29 PM", "isMe": false},   {"text": "Hello, is the oven still available for booking?", "time": "8:28 PM", "isMe": true},
    {"text": "Yes, it is! You can send your booking request now.", "time": "8:29 PM", "isMe": false},   {"text": "Hello, is the oven still available for booking?", "time": "8:28 PM", "isMe": true},
    {"text": "Yes, it is! You can send your booking request now.", "time": "8:29 PM", "isMe": false},   {"text": "Hello, is the oven still available for booking?", "time": "8:28 PM", "isMe": true},
    {"text": "Yes, it is! You can send your booking request now.", "time": "8:29 PM", "isMe": false},   {"text": "Hello, is the oven still available for booking?", "time": "8:28 PM", "isMe": true},
    {"text": "Yes, it is! You can send your booking request now.", "time": "8:29 PM", "isMe": false},   {"text": "Hello, is the oven still available for booking?", "time": "8:28 PM", "isMe": true},
    {"text": "Yes, it is! You can send your booking request now.", "time": "8:29 PM", "isMe": false},   {"text": "Hello, is the oven still available for booking?", "time": "8:28 PM", "isMe": true},
    {"text": "Yes, it is! You can send your booking request now.", "time": "8:29 PM", "isMe": false},   {"text": "Hello, is the oven still available for booking?", "time": "8:28 PM", "isMe": true},
    {"text": "Yes, it is! You can send your booking request now.", "time": "8:29 PM", "isMe": false},   {"text": "Hello, is the oven still available for booking?", "time": "8:28 PM", "isMe": true},
    {"text": "Yes, it is! You can send your booking request now.", "time": "8:29 PM", "isMe": false},   {"text": "Hello, is the oven still available for booking?", "time": "8:28 PM", "isMe": true},
    {"text": "Yes, it is! You can send your booking request now.", "time": "8:29 PM", "isMe": false},
    {"text": "Great, sending it over!", "time": "8:30 PM", "isMe": true},{"text": "Great, sending it over!", "time": "8:30 PM", "isMe": true},{"text": "Great, sending it over!", "time": "8:30 PM", "isMe": true},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),

            /// App bar
            buildChatAppBar(context),

            const SizedBox(height: 4),

            ///Messages list
            Expanded(
              child: ListView.builder(
                reverse: true,
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[messages.length - 1 - index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: MessageBubble(
                      message: msg["text"]!,
                      time: msg["time"]!,
                      isMe: msg["isMe"]!,
                    ),
                  );
                },
              ),
            ),

            /// Input field
            MessageInputField(controller: _messageTEController),
          ],
        ),
      ),
    );
  }

  /// Custom App Bar
  AppBar buildChatAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Gustaf Chef Cleaner",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(
            "Active 2 hours ago",
            style: TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.black),
          onPressed: () {},
        ),
      ],
    );
  }
}

/// Chat bubble
class MessageBubble extends StatelessWidget {
  final String message;
  final String time;
  final bool isMe;

  const MessageBubble({
    required this.message,
    required this.time,
    required this.isMe,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final images = Assets.images;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          /// Avatar for received messages
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: CircleAvatar(
                radius: 16,
                backgroundImage: images.user2.provider(),
              ),
            ),

          /// Message Bubble
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 14),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.primary_1 : Colors.grey.shade200,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
                      bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
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
                  time,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),


        ],
      ),
    );
  }
}

/// Input field at the bottom
class MessageInputField extends StatelessWidget {
  final TextEditingController controller;

  const MessageInputField({required this.controller, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      color: Colors.white,
      child: Row(
        children: [
          IconButton( /// attachedfiled icon
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary_1),
            onPressed: () {},
          ),

          /// Text field
          Expanded(
            child: TextField(
              controller: controller,
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
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                suffixIcon: Icon(Icons.face_6_sharp,color:Colors.black,)
              ),
            ),
          ),

          IconButton(
            icon: const Icon(Icons.send, color: AppColors.primary_1),
            onPressed: () {
              controller.clear();
            },
          ),
        ],
      ),
    );
  }
}
