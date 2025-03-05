class MessageModel {
  final String messageId;
  final String userId; // Reference to User
  final String chatRoomId;
  final String messageText;
  final DateTime sentAt;

  MessageModel({
    required this.messageId,
    required this.userId,
    required this.chatRoomId,
    required this.messageText,
    required this.sentAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'userId': userId,
      'chatRoomId': chatRoomId,
      'messageText': messageText,
      'sentAt': sentAt.toIso8601String(),
    };
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      messageId: json['messageId'],
      userId: json['userId'],
      chatRoomId: json['chatRoomId'],
      messageText: json['messageText'],
      sentAt: DateTime.parse(json['sentAt']),
    );
  }
}
