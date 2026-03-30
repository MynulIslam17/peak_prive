// lib/modules/chat/models/chat_list_model.dart

class ChatListModel {
  final String chatId;
  final ChatOtherUser otherUser;
  final ChatLastMessage lastMessage;
  final int unreadCount;
  final String lastMessageAt;
  final String? lastMessageTime;

  ChatListModel({
    required this.chatId,
    required this.otherUser,
    required this.lastMessage,
    required this.unreadCount,
    required this.lastMessageAt,
    this.lastMessageTime,
  });

  // REST response
  static List<ChatListModel> fromRestJson(Map<String, dynamic> json) {
    final List data = json['data'] ?? [];
    return data.map((e) => ChatListModel.fromJson(e)).toList();
  }

  // Socket response
  static List<ChatListModel> fromSocketJson(Map<String, dynamic> json) {
    final List chats = json['chats'] ?? [];
    return chats.map((e) => ChatListModel.fromJson(e)).toList();
  }

  factory ChatListModel.fromJson(Map<String, dynamic> json) {
    return ChatListModel(
      chatId: json['chatId'] ?? '',
      otherUser: ChatOtherUser.fromJson(json['otherUser']),
      lastMessage: ChatLastMessage.fromJson(json['lastMessage']),
      unreadCount: json['unreadCount'] ?? 0,
      lastMessageAt: json['lastMessageAt'] ?? '',
      lastMessageTime: json['lastMessageTime'],
    );
  }
}

class ChatOtherUser {
  final String id;
  final String? fullName;
  final String email;
  final String? profileUrl;
  final bool isOnline;

  ChatOtherUser({
    required this.id,
    this.fullName,
    required this.email,
    this.profileUrl,
    required this.isOnline,
  });

  factory ChatOtherUser.fromJson(Map<String, dynamic> json) {
    return ChatOtherUser(
      id: json['_id'] ?? '',
      fullName: (json['fullName'] as String?)?.isEmpty == true
          ? null
          : json['fullName'],
      email: json['email'] ?? '',
      profileUrl: (json['profileUrl'] as String?)?.isEmpty == true
          ? null
          : json['profileUrl'],
      isOnline: json['isOnline'] ?? false,
    );
  }
}

class ChatLastMessage {
  final String id;
  final String content;
  final String createdAt;
  final ChatMessageSender sender;

  ChatLastMessage({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.sender,
  });

  factory ChatLastMessage.fromJson(Map<String, dynamic> json) {
    return ChatLastMessage(
      id: json['_id'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] ?? '',
      sender: ChatMessageSender.fromJson(json['sender']),
    );
  }
}

class ChatMessageSender {
  final String id;
  final String? fullName;
  final String email;
  final String? profileUrl;

  ChatMessageSender({
    required this.id,
    this.fullName,
    required this.email,
    this.profileUrl,
  });

  factory ChatMessageSender.fromJson(Map<String, dynamic> json) {
    return ChatMessageSender(
      id: json['_id'] ?? '',
      fullName: (json['fullName'] as String?)?.isEmpty == true
          ? null
          : json['fullName'],
      email: json['email'] ?? '',
      profileUrl: (json['profileUrl'] as String?)?.isEmpty == true
          ? null
          : json['profileUrl'],
    );
  }
}