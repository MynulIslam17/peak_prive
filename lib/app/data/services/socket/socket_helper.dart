// lib/service/socket_helper.dart
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'live_events.dart';

class SocketHelper {
  IO.Socket? _socket;
  final String _userId;
  final String _authToken;
  final String _baseUrl;

  // Callbacks for UI/Controller updates
  Function(dynamic)? onMessageReceived;
  Function(dynamic)? onChatListUpdated;
  Function(dynamic)? onUserStatusChanged;
  Function(dynamic)? onUserTyping;
  Function(dynamic)? onUserStoppedTyping;
  Function(dynamic)? onError;
  Function()? onConnected;
  Function()? onDisconnected;
  Function(dynamic)? onMessagesRead;

  // ── Presence ───────────────────────────────────────────────────────────
  // Several screens need `user-status` at once (chat list + open chat), so
  // they register listeners instead of overwriting one callback. The last
  // known status per user is kept so a screen opened later starts correct.
  final List<void Function(String userId, bool isOnline)> _statusListeners = [];
  final Map<String, bool> _presence = {};

  /// Last status received for [userId], or null if none seen yet.
  bool? knownOnlineStatus(String userId) => _presence[userId];

  void addUserStatusListener(void Function(String userId, bool isOnline) l) {
    if (!_statusListeners.contains(l)) _statusListeners.add(l);
  }

  void removeUserStatusListener(void Function(String userId, bool isOnline) l) {
    _statusListeners.remove(l);
  }

  void _handleUserStatus(dynamic data) {
    onUserStatusChanged?.call(data);
    if (data is! Map) return;
    final userId = data['userId']?.toString();
    if (userId == null || userId.isEmpty) return;
    final isOnline = data['isOnline'] == true;
    _presence[userId] = isOnline;
    for (final l in List.of(_statusListeners)) {
      l(userId, isOnline);
    }
  }

  SocketHelper({
    required String userId,
    required String authToken,
    required String baseUrl,
  })  : _userId = userId,
        _authToken = authToken,
        _baseUrl = baseUrl.trim();

  void connect() {
    // Disconnect any existing socket before creating a new one
    if (_socket != null) {
      if (_socket!.connected) _socket!.disconnect();
      _socket = null;
    }

    _socket = IO.io(
      _baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setQuery({'userId': _userId})
          .setAuth({'token': _authToken})
          .enableAutoConnect()
          .enableForceNew() // Prevents reusing a stale cached connection
          .enableReconnection()
          // Keep trying (Wi-Fi drops, server restarts); back off up to 30 s.
          .setReconnectionDelay(2000)
          .setReconnectionDelayMax(30000)
          .build(),
    );

    _registerConnectionEvents();
    _registerAppEvents();

    _socket!.connect();
  }

  void _registerConnectionEvents() {
    _socket!.onConnect((_) {
      print('✅ Socket connected — ID: ${_socket!.id}');
      onConnected?.call();
    });

    _socket!.onDisconnect((reason) {
      print('❌ Socket disconnected — Reason: $reason');
      onDisconnected?.call();
    });

    _socket!.onError((error) {
      print('💥 Socket error: $error');
      onError?.call(error);
    });

    _socket!.onReconnectAttempt((attempt) {
      print('🔄 Reconnection attempt #$attempt');
    });

    _socket!.onReconnect((_) {
      print('🔄 Socket reconnected — New ID: ${_socket!.id}');
      onConnected?.call();
      LiveEvents.emitReconnected();
    });

    _socket!.onReconnectFailed((_) {
      // Called after all reconnection attempts are exhausted
      print('🚫 Reconnection failed after max attempts');
      onError?.call({'error': 'reconnect_failed'});
    });
  }

  void _registerAppEvents() {
    _socket!.on('message-new', (data) {
     // print('📨 Received [message-new]: $data');
      onMessageReceived?.call(data);
      // The open conversation owns [onMessageReceived]; the chat list and
      // its unread badge follow through the app-wide stream.
      LiveEvents.emitChatMessage();
    });
    _socket!.on('chat-list', (data) {
    print('📋 Received [chat-list]: $data'); // debug
      onChatListUpdated?.call(data);
    });
    _socket!.on('user-status', _handleUserStatus);
    _socket!.on('user-typing', (data) => onUserTyping?.call(data));
    _socket!.on('user-stopped-typing', (data) => onUserStoppedTyping?.call(data));
    _socket!.on('messages-read', (data) => onMessagesRead?.call(data));

    // Live booking and notification updates go to app-wide streams; screens
    // subscribe through [LiveEvents] instead of the socket.
    _socket!.on('booking:updated', (data) {
      final u = LiveEvents.parseBookingUpdate(data);
      if (u != null) LiveEvents.emitBookingUpdate(u);
    });
    _socket!.on('notification:new', (data) {
      final n = LiveEvents.parseNotification(data);
      if (n != null) LiveEvents.emitNotification(n);
    });
  }

  /// Sends a message to the specified receiver.
  /// [tempId] is an optional client-side ID for optimistic UI updates.
  void sendMessage({
    required String receiverId,
    required String content,
    String? tempId,
  }) {
    if (!_isReady(action: 'send_message')) return;

    final payload = <String, dynamic>{
      'receiverId': receiverId,
      'content': content,
    };

    // Only include tempId if provided to avoid sending null to the server
    if (tempId != null) payload['tempId'] = tempId;

    _socket!.emit('message-send', payload);
  }

  /// Notifies the other user that the current user has started typing.
  /// Debounce this call in the controller to avoid flooding the server.
  void emitTyping({required String chatId, required String otherUserId}) {
    if (!_isReady()) return;
    _socket!.emit('user-typing', {'chatId': chatId, 'otherUserId': otherUserId});
  }

  /// Notifies the other user that the current user has stopped typing.
  void emitStoppedTyping({required String chatId, required String otherUserId}) {
    if (!_isReady()) return;
    _socket!.emit('user-stopped-typing', {'chatId': chatId, 'otherUserId': otherUserId});
  }

  /// Sends a read receipt, informing the other user their messages were seen.
  void emitMessagesRead({required String chatId,  String ? otherUserId}) {
    if (!_isReady()) return;
    _socket!.emit('messages-read', {'chatId': chatId, 'otherUserId': otherUserId});
  }

  // Silently returns false when not ready — avoids spamming errors for
  // non-critical events like typing indicators and read receipts.
  bool _isReady({String? action}) {
    if (_socket == null || !_socket!.connected) {
      if (action != null) {
        onError?.call({'error': 'not_connected', 'action': action});
      }
      return false;
    }
    return true;
  }

  bool get isConnected => _socket?.connected ?? false;

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  /// Releases all resources. Call this in your controller's onClose()
  /// or widget's dispose() to prevent callbacks firing on stale objects.
  void dispose() {
    disconnect();
    onMessageReceived = null;
    onChatListUpdated = null;
    onUserStatusChanged = null;
    onUserTyping = null;
    onUserStoppedTyping = null;
    onError = null;
    onConnected = null;
    onDisconnected = null;
    onMessagesRead = null;
    _statusListeners.clear();
    _presence.clear();
  }
}