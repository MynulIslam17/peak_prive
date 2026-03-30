// lib/modules/chats/controllers/chat_controller.dart
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/controllers/auth_controller.dart';
import 'package:harry_service_app/app/data/models/network_response.dart';
import 'package:harry_service_app/app/data/services/network_caller.dart';
import 'package:harry_service_app/app/modules/chats/models/message_model.dart';
import '../../../core/constants/api_urls.dart';
import '../../../data/services/socket/socket_service.dart';

class ChatController extends GetxController {
  bool _isLoading = false;
  String? _errorMessage;
  List<MessageModel> _messages = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<MessageModel> get messages => _messages;

  String get currentUserId =>
      Get.find<AuthController>().userModel?.id ?? '';

  Future<void> fetchMessageHistory(String otherUserId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      update();

      NetworkResponse response = await Get.find<NetworkCaller>()
          .getRequest(url: AppUrls.messageHistory(otherUserId));

      if (response.isSuccess) {
        _messages = MessageModel.fromRestJson(response.body!);
      } else {
        _errorMessage = response.errorMessage ?? 'Failed to load messages';
      }
    } finally {
      _isLoading = false;
      update();
    }
  }



  /// this emits new message to the chat screen
  void listenToNewMessages(String chatId) {
    Get.find<SocketService>().helper.onMessageReceived = (data) {
      final message = MessageModel.fromJson(data['message']);
      if (message.chatId != chatId) return;

      // 1. Check if temp message exists
      final tempId = data['tempId'] as String?;
      if (tempId != null) {
        final index = _messages.indexWhere((m) => m.id == tempId);
        if (index != -1) {
          // Replace temp message with server message
          _messages[index] = message;
          update();
          return;
        }
      }

      // 2. If no temp message, just add normally
      _messages.insert(0, message);
      update();
    };
  }
  /// this emits sending new message to other user
  void sendMessage({required String receiverId, required String content}) {
    if (content.trim().isEmpty) return;

    // 1. Generate a temporary ID for optimistic UI
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();

    // 2. Create a temp MessageModel
    final tempMessage = MessageModel(
      id: tempId,
      chatId: '', // যদি chatId এখনও না থাকে
      sender: MessageUser(
        id: currentUserId,
        email: '', // optional
      ),
      receiver: MessageUser(
        id: receiverId,
        email: '',
      ),
      content: content.trim(),
      messageType: 'text',
      status: 'sending', // optimistic status
      createdAt: DateTime.now().toIso8601String(),
    );

    // 3. Add temp message to UI
    _messages.insert(0, tempMessage);
    update();

    // 4. Send message to server
    Get.find<SocketService>().helper.sendMessage(
      receiverId: receiverId,
      content: content.trim(),
      tempId: tempId, // important for server to echo back tempId
    );
  }




}