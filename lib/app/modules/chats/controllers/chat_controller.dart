// lib/modules/chats/controllers/chat_controller.dart

import 'package:get/get.dart';
import 'package:harry_service_app/app/core/controllers/auth_controller.dart';
import 'package:harry_service_app/app/data/models/network_response.dart';
import 'package:harry_service_app/app/data/services/network/network_caller.dart';
import 'package:harry_service_app/app/modules/chats/models/message_model.dart';
import '../../../core/constants/api_urls.dart';
import '../../../data/services/socket/socket_service.dart';

/// ------------------------------------------------------------
/// ChatController
/// ------------------------------------------------------------
/// This controller manages all chat-related functionalities:
///
/// 1. Fetching message history from REST API
/// 2. Sending messages (with optimistic UI update)
/// 3. Receiving messages via Socket
/// 4. Handling typing indicators (start/stop)
/// 5. Handling message read events
/// 6. Tracking online/offline status of other user
///
/// NOTE:
/// - Uses GetX state management (`update()` for UI refresh)
/// - Socket events are handled via SocketService
/// - Messages are stored in reverse order (latest at index 0)
/// - New chat IDs are fetched from the first message in the history
///   or from the first incoming socket message if no messages exist
/// ------------------------------------------------------------
class ChatController extends GetxController {
  /// -------------------- STATE --------------------

  bool _isLoading = false;
  String? _errorMessage;
  List<MessageModel> _messages = [];
  String _currentChatId = '';

  /// -------------------- GETTERS --------------------

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<MessageModel> get messages => _messages;
  String get currentChatId => _currentChatId;

  /// Current logged-in user ID from AuthController
  String get currentUserId =>
      Get.find<AuthController>().userModel?.id ?? '';

  /// ------------------------------------------------------------
  /// Fetch message history from REST API
  /// ------------------------------------------------------------
  /// Loads previous messages between current user and other user
  /// and updates local message list.
  ///
  /// **New Chat ID Logic:**
  /// - If `_currentChatId` is empty, fetch it from the first message
  ///   in the history.
  Future<void> fetchMessageHistory(String otherUserId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      update();

      NetworkResponse response = await Get.find<NetworkCaller>()
          .getRequest(url: AppUrls.messageHistory(otherUserId));

      if (response.isSuccess) {
        _messages = MessageModel.fromRestJson(response.body!);

        // Fetch chatId for new chat (if first message exists)
        if (_messages.isNotEmpty && _currentChatId.isEmpty) {
          _currentChatId = _messages.first.chatId;
        }
      } else {
        _errorMessage = response.errorMessage ?? 'Failed to load messages';
      }
    } finally {
      _isLoading = false;
      update();
    }
  }

  /// ------------------------------------------------------------
  /// Listen to new incoming messages from socket
  /// ------------------------------------------------------------
  /// - Receives real-time messages
  /// - Matches chatId before inserting
  /// - Removes temporary "sending" message if exists
  ///
  /// **New Chat ID Logic:**
  /// - If `_currentChatId` is empty, fetch it from the first incoming message
  void listenToNewMessages(String chatId) {
    // Screen provides chatId (may be empty for new chat)
    if (chatId.isNotEmpty) _currentChatId = chatId;

    Get.find<SocketService>().helper.onMessageReceived = (data) {
      final message = MessageModel.fromJson(data['message']);

      // For new chats, set chatId from the first message
      if (_currentChatId.isEmpty) {
        _currentChatId = message.chatId;
      }

      if (message.chatId == _currentChatId) {
        // Remove temporary sending message if it matches
        _messages.removeWhere(
                (m) => m.status == 'sending' && m.content == message.content);

        // Insert the new message at the top
        _messages.insert(0, message);
        update();
      }
    };
  }

  /// ------------------------------------------------------------
  /// Send message (Optimistic UI approach)
  /// ------------------------------------------------------------
  /// - Instantly shows message in UI
  /// - Sends via socket
  /// - Uses temporary ID until confirmed by server
  void sendMessage({required String receiverId, required String content}) {
    if (content.trim().isEmpty) return;

    /// Create temporary message for instant UI feedback
    final tempMessage = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: '',
      sender: MessageUser(
        id: currentUserId,
        email: '',
      ),
      receiver: MessageUser(
        id: receiverId,
        email: '',
      ),
      content: content.trim(),
      messageType: 'text',
      status: 'sending', // pending state
      createdAt: DateTime.now().toIso8601String(),
    );

    /// Insert into UI immediately
    _messages.insert(0, tempMessage);
    update();

    /// Send actual message via socket
    Get.find<SocketService>().helper.sendMessage(
      receiverId: receiverId,
      content: content.trim(),
      tempId: tempMessage.id,
    );
  }

  /// -------------------- TYPING STATUS --------------------

  bool _isOtherUserTyping = false;
  bool get isOtherUserTyping => _isOtherUserTyping;

  /// Listen when other user starts typing
  void listenToTyping(String chatId) {
    Get.find<SocketService>().helper.onUserTyping = (data) {
      if (data['chatId'] == chatId) {
        _isOtherUserTyping = true;
        update();
      }
    };

    /// Listen when other user stops typing
    Get.find<SocketService>().helper.onUserStoppedTyping = (data) {
      if (data['chatId'] == chatId) {
        _isOtherUserTyping = false;
        update();
      }
    };
  }

  /// Emit typing event
  void emitTyping(String chatId, String otherUserId) {
    Get.find<SocketService>().helper.emitTyping(
      chatId: chatId,
      otherUserId: otherUserId,
    );
  }

  /// Emit stop typing event
  void emitStoppedTyping(String chatId, String otherUserId) {
    Get.find<SocketService>().helper.emitStoppedTyping(
      chatId: chatId,
      otherUserId: otherUserId,
    );
  }

  /// ------------------------------------------------------------
  /// Emit "messages read" event
  /// ------------------------------------------------------------
  /// Notifies backend that all messages in this chat are read
  void emitMessagesRead(String chatId) {
    final id = chatId.isNotEmpty ? chatId : _currentChatId;
    if (id.isEmpty) return;

    Get.find<SocketService>().helper.emitMessagesRead(chatId: id);
  }

  /// -------------------- ONLINE STATUS --------------------

  bool _isOtherUserOnline = false;
  bool get isOtherUserOnline => _isOtherUserOnline;

  /// Initialize and listen for online/offline status updates
  void initOnlineStatus(bool isOnline, String otherUserId) {
    _isOtherUserOnline = isOnline;

    Get.find<SocketService>().helper.onUserStatusChanged = (data) {
      if (data['userId'] == otherUserId) {
        _isOtherUserOnline = data['isOnline'] ?? false;
        update();
      }
    };
  }
}