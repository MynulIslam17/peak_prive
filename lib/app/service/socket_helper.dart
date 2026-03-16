import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketHelper {
  IO.Socket? _socket;
  final String _userId;
  final String _authToken;
  final String _baseUrl;

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
    if (_socket != null) {
      if (_socket!.connected) _socket!.disconnect();
      _socket!.destroy();
      _socket = null;
    }

    print('🔌 Connecting to: $_baseUrl | User: $_userId');

    _socket = IO.io(
      _baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setQuery({'userId': _userId})
          .setAuth({'token': _authToken})
          .disableAutoConnect()         // ✅ we call .connect() manually
          .enableForceNew()
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(2000)
          .build(),
    );

    _socket!.onConnect((_) {
      print('✅ Connected! ID: ${_socket!.id}');
      onConnected?.call();
    });

    _socket!.onDisconnect((data) {
      print('❌ Disconnected: $data');
      onDisconnected?.call();
    });

    _socket!.onError((error) {
      print('💥 Error: $error');
      onError?.call(error);
    });

    _socket!.onReconnectAttempt((attempt) => print('🔄 Attempt #$attempt'));

    _socket!.onReconnect((_) {
      print('🔄 Reconnected!');
      onConnected?.call();
    });

    _socket!.onReconnectFailed((_) {           // ✅ NEW: handle total failure
      print('💀 Reconnection failed after all attempts');
      onError?.call({'error': 'reconnect_failed'});
    });

    _socket!.on('message-new',          (d) => onMessageReceived?.call(d));
    _socket!.on('chat-list',            (d) => onChatListUpdated?.call(d));
    _socket!.on('user-status',          (d) => onUserStatusChanged?.call(d));
    _socket!.on('user-typing',          (d) => onUserTyping?.call(d));
    _socket!.on('user-stopped-typing',  (d) => onUserStoppedTyping?.call(d));
    _socket!.on('messages-read',        (d) => onMessagesRead?.call(d));

    _socket!.connect(); // ✅ manual connect
  }

  void sendMessage({required String receiverId, required String content, String? tempId}) {
    if (!isReady) {
      onError?.call({'error': 'not_connected', 'action': 'send_message'});
      return;
    }
    _socket!.emit('message-send', {
      'receiverId': receiverId,
      'content': content,
      'tempId': tempId,
    });
  }

  void emitTyping({required String chatId, required String otherUserId}) {
    if (!isReady) return;
    _socket!.emit('user-typing', {'chatId': chatId, 'otherUserId': otherUserId});
  }

  void emitStoppedTyping({required String chatId, required String otherUserId}) {
    if (!isReady) return;
    _socket!.emit('user-stopped-typing', {'chatId': chatId, 'otherUserId': otherUserId});
  }

  void emitMessagesRead({required String chatId, required String otherUserId}) {
    if (!isReady) return;
    _socket!.emit('messages-read', {'chatId': chatId, 'otherUserId': otherUserId});
  }

  bool get isReady => _socket != null && _socket!.connected;  // ✅ public
  bool get isConnected => _socket?.connected ?? false;

  void disconnect() {
    if (_socket != null) {
      _socket!.off('message-new');
      _socket!.off('chat-list');
      _socket!.off('user-status');
      _socket!.off('user-typing');
      _socket!.off('user-stopped-typing');
      _socket!.off('messages-read');
      _socket!.disconnect();
      _socket!.destroy();               // ✅ fully destroy
      _socket = null;
    }
  }
}