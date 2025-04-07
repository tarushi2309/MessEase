class FeedbackModel {
  final String uid;
  final String text;
  final String? imageUrl;
  final DateTime timestamp;

  FeedbackModel({
    required this.uid,
    required this.text,
    this.imageUrl,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'text': text,
      'imageUrl': imageUrl,
      'timestamp': timestamp.toIso8601String(), 
    };
  }

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      uid: json['uid'],
      text: json['text'],
      imageUrl: json['imageUrl'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
