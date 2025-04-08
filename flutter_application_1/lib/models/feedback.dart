class FeedbackModel {
  final String uid;
  final String text;
  final String? imageUrl;
  final DateTime timestamp;
  final String mess;

  FeedbackModel({
    required this.uid,
    required this.text,
    this.imageUrl,
    required this.timestamp,
    required this.mess,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'text': text,
      'imageUrl': imageUrl,
      'timestamp': timestamp.toIso8601String(), 
      'mess': mess,
    };
  }

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      uid: json['uid'],
      text: json['text'],
      imageUrl: json['imageUrl'],
      timestamp: DateTime.parse(json['timestamp']),
      mess: json['mess'],
    );
  }
}
