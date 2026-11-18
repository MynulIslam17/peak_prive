// lib/modules/chats/models/message_model.dart

class MessageModel {
  final String id;
  final String chatId;
  final MessageUser sender;
  final MessageUser receiver;
  final String content;
  final String messageType;
  final String status;
  final String createdAt;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.sender,
    required this.receiver,
    required this.content,
    required this.messageType,
    required this.status,
    required this.createdAt,
  });

  static List<MessageModel> fromRestJson(Map<String, dynamic> json) {
    final List data = json['data'] ?? [];
    return data.map((e) => MessageModel.fromJson(e)).toList();
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['_id'] ?? '',
      chatId: json['chatId'] ?? '',
      sender: MessageUser.fromJson(json['sender']),
      receiver: MessageUser.fromJson(json['receiver']),
      content: json['content'] ?? '',
      messageType: json['messageType'] ?? 'text',
      status: json['status'] ?? 'sent',
      createdAt: json['createdAt'] ?? '',
    );
  }
}

class MessageUser {
  final String id;
  final String email;
  final String? fullName;
  final String? profileUrl;
  final String? phoneNumber;

  MessageUser({
    required this.id,
    required this.email,
    this.fullName,
    this.profileUrl,
    this.phoneNumber,
  });

  factory MessageUser.fromJson(Map<String, dynamic> json) {
    return MessageUser(
      id: json['_id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'],
      profileUrl: (json['profileUrl'] as String?)?.isEmpty == true
          ? null
          : json['profileUrl'],
      phoneNumber: (json['phoneNumber'] as String?)?.isEmpty == true
          ? null
          : json['phoneNumber'],
    );
  }
}