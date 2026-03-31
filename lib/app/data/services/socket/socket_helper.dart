// lib/service/socket_helper.dart
import 'package:socket_io_client/socket_io_client.dart' as IO;

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
          .setReconnectionAttempts(5)
          .setReconnectionDelay(2000)
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
    });
    _socket!.on('chat-list', (data) {
    print('📋 Received [chat-list]: $data'); // debug
      onChatListUpdated?.call(data);
    });
    _socket!.on('user-status', (data) => onUserStatusChanged?.call(data));
    _socket!.on('user-typing', (data) => onUserTyping?.call(data));
    _socket!.on('user-stopped-typing', (data) => onUserStoppedTyping?.call(data));
    _socket!.on('messages-read', (data) => onMessagesRead?.call(data));
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
  }
}