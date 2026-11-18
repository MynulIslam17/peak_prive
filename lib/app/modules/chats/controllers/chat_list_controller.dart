import 'dart:async';

import 'package:get/get.dart';
import 'package:harry_service_app/app/data/models/network_response.dart';
import 'package:harry_service_app/app/modules/chats/models/chat_list_model.dart';
import '../../../core/constants/api_urls.dart';
import '../../../data/services/network/network_caller.dart';
import '../../../data/services/socket/live_events.dart';
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

  /// Unread messages across all chats (Chats tab badge).
  int get totalUnread => _chatList.fold(0, (sum, c) => sum + c.unreadCount);

  StreamSubscription<void>? _messageSub;
  Timer? _refreshDebounce;

  // -------------------- Lifecycle --------------------

  @override
  void onInit() {
    super.onInit();

    /// Fetch initial chat list when controller is initialized
   // fetchChatList();

    // Keep the online dots live (this was never wired up).
    listenToUserStatus();

    // New messages arrive in any conversation: refresh the list (last
    // message, unread counts) without a loading state.
    _messageSub = LiveEvents.chatMessages.listen((_) => refreshSoon());
  }

  /// Quiet refresh, batched when several messages arrive at once.
  void refreshSoon() {
    _refreshDebounce?.cancel();
    _refreshDebounce = Timer(const Duration(milliseconds: 400), () => fetchChatList(quiet: true));
  }

  // -------------------- API Call --------------------

  /// ------------------------------------------------------------
  /// Fetch all chat list from server (REST API)
  /// ------------------------------------------------------------
  /// - Called on controller initialization
  /// - Updates chat list and UI state
  /// - Handles loading and error states
  Future<void> fetchChatList({bool quiet = false}) async {
    try {
      _isLoading = !quiet;
      if (!quiet) _errorMessage = null;
      update();

      NetworkResponse response = await Get.find<NetworkCaller>()
          .getRequest(url: AppUrls.allChatList);

      if (response.isSuccess) {
        _chatList = ChatListModel.fromRestJson(response.body!);
        _errorMessage = null;
      } else if (!quiet) {
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
    try {
      // The helper is recreated on login, so (re)attach to the current one.
      final helper = Get.find<SocketService>().helper;
      helper.removeUserStatusListener(_onUserStatus);
      helper.addUserStatusListener(_onUserStatus);
    } catch (_) {
      // Socket not initialised yet (e.g. before login) — the chat list
      // screen calls this again when it opens.
    }
  }

  void _onUserStatus(String userId, bool isOnline) {
    final index = _chatList.indexWhere((c) => c.otherUser.id == userId);
    if (index == -1 || _chatList[index].otherUser.isOnline == isOnline) return;

    // Re-create the item (models are immutable); keep everything else.
    final old = _chatList[index];
    _chatList[index] = ChatListModel(
      chatId: old.chatId,
      otherUser: ChatOtherUser(
        id: old.otherUser.id,
        fullName: old.otherUser.fullName,
        email: old.otherUser.email,
        profileUrl: old.otherUser.profileUrl,
        isOnline: isOnline,
      ),
      lastMessage: old.lastMessage,
      unreadCount: old.unreadCount,
      lastMessageAt: old.lastMessageAt,
      lastMessageTime: old.lastMessageTime,
    );
    update();
  }

  @override
  void onClose() {
    _messageSub?.cancel();
    _refreshDebounce?.cancel();
    try {
      if (Get.isRegistered<SocketService>()) {
        Get.find<SocketService>().helper.removeUserStatusListener(_onUserStatus);
      }
    } catch (_) {}
    super.onClose();
  }
}