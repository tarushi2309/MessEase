class MessManagerModel {
  final String uid; // Reference to User
  final String messId;
  final String phoneNumber;

  MessManagerModel({
    required this.uid,
    required this.messId,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'messId': messId,
      'phoneNumber': phoneNumber,
    };
  }

  factory MessManagerModel.fromJson(Map<String, dynamic> json) {
    return MessManagerModel(
      uid: json['uid'],
      messId: json['messId'],
      phoneNumber: json['phoneNumber'],
    );
  }
}
