class ChatRoomModel {
  final String chatRoomId;
  final String messId;
  final String lastMessage;
  final DateTime lastUpdated;

  ChatRoomModel({
    required this.chatRoomId,
    required this.messId,
    required this.lastMessage,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() {
    return {
      'chatRoomId': chatRoomId,
      'messId': messId,
      'lastMessage': lastMessage,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      chatRoomId: json['chatRoomId'],
      messId: json['messId'],
      lastMessage: json['lastMessage'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
}
