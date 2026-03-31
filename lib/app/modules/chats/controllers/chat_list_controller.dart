import 'package:get/get.dart';
import 'package:harry_service_app/app/data/models/network_response.dart';
import 'package:harry_service_app/app/modules/chats/models/chat_list_model.dart';
import '../../../core/constants/api_urls.dart';
import '../../../data/services/network_caller.dart';
import '../../../data/services/socket/socket_service.dart';

/// ------------------------------------------------------------
/// ChatListController
/// ------------------------------------------------------------
/// This controller manages the chat list (conversation list).
///
/// Responsibilities:
/// 1. Fetch chat list from REST API
/// 2. Listen for real-time chat list updates via Socket
/// 3. Update user online/offline status dynamically
///
/// NOTE:
/// - Uses GetX state management (`update()` for UI refresh)
/// - REST API is used for initial data load
/// - Socket is used for real-time updates
/// - Chat list is fully replaced when socket sends updated list
/// ------------------------------------------------------------
class ChatListController extends GetxController {

  // -------------------- State Variables --------------------

  /// Indicates loading state for API calls
  bool _isLoading = false;

  /// Holds error message if API fails
  String? _errorMessage;

  /// Stores list of all chats
  List<ChatListModel> _chatList = [];

  // -------------------- Getters --------------------

  /// Public getter for loading state
  bool get isLoading => _isLoading;

  /// Public getter for error message
  String? get errorMessage => _errorMessage;

  /// Public getter for chat list
  List<ChatListModel> get chatList => _chatList;

  // -------------------- Lifecycle --------------------

  @override
  void onInit() {
    super.onInit();

    /// Fetch initial chat list when controller is initialized
    fetchChatList();
  }

  // -------------------- API Call --------------------

  /// ------------------------------------------------------------
  /// Fetch all chat list from server (REST API)
  /// ------------------------------------------------------------
  /// - Called on controller initialization
  /// - Updates chat list and UI state
  /// - Handles loading and error states
  Future<void> fetchChatList() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      update();

      NetworkResponse response = await Get.find<NetworkCaller>()
          .getRequest(url: AppUrls.allChatList);

      if (response.isSuccess) {
        _chatList = ChatListModel.fromRestJson(response.body!);
      } else {
        _errorMessage = response.errorMessage ?? 'Failed to load chats';
      }
    } finally {
      _isLoading = false;
      update();
    }
  }

  // -------------------- Socket Listeners --------------------

  /// ------------------------------------------------------------
  /// Listen for real-time chat list updates
  /// ------------------------------------------------------------
  /// - Triggered when server sends updated chat list
  /// - Replaces entire chat list with latest data
  /// - Useful for new messages, unread count updates, etc.
  ///
  /// IMPORTANT:
  /// Call this method after socket connection is established
  void setSocketListener() {
    if (!Get.isRegistered<SocketService>()) return;

    Get.find<SocketService>().helper.onChatListUpdated = (data) {
      // Replace chat list with updated data from socket
      _chatList = ChatListModel.fromSocketJson(data);
      update();
    };
  }

  /// ------------------------------------------------------------
  /// Listen to user online/offline status updates
  /// ------------------------------------------------------------
  /// - Updates only the specific user's online status
  /// - Does NOT replace the full chat list
  /// - Keeps other chat data intact
  void listenToUserStatus() {
    if (!Get.isRegistered<SocketService>()) return;

    Get.find<SocketService>().helper.onUserStatusChanged = (data) {
      final userId = data['userId'];
      final isOnline = data['isOnline'] ?? false;

      // Find the chat item that matches this user
      final index = _chatList.indexWhere(
            (c) => c.otherUser.id == userId,
      );

      if (index != -1) {

        /// Update only the user's online status
        /// (Re-create object to keep immutability)
        _chatList[index] = ChatListModel(
          chatId: _chatList[index].chatId,
          otherUser: ChatOtherUser(
            id: _chatList[index].otherUser.id,
            fullName: _chatList[index].otherUser.fullName,
            email: _chatList[index].otherUser.email,
            profileUrl: _chatList[index].otherUser.profileUrl,
            isOnline: isOnline,
          ),
          lastMessage: _chatList[index].lastMessage,
          unreadCount: _chatList[index].unreadCount,
          lastMessageAt: _chatList[index].lastMessageAt,
          lastMessageTime: _chatList[index].lastMessageTime,
        );

        /// Trigger UI update
        update();
      }
    };
  }
}