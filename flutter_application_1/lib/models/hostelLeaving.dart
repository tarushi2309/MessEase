class HostelLeavingModel {
  final String uid;
  final String name;
  final String entryNumber;
  final String mess;
  final Timestamp selectedDate;
  final Timestamp timestamp;

  HostelLeavingModel({
    required this.uid,
    required this.name,
    required this.entryNumber,
    required this.mess,
    required this.selectedDate,
    required this.timestamp,
  }) ;

  // Convert a UserModel into a Map for storing in Firestore or Realtime Database.
  Map<String, dynamic> toJson() => {
        'uid': uid,
        'name':name,
        'entryNumber': entryNumber,
        'mess': mess,
        'selectedDate': selectedDate,
        'timestamp': timestamp,
      };

  // Create a UserModel instance from a Map.
  factory HostelLeavingModel.fromJson(Map<String, dynamic> json) => HostelLeavingModel(
        uid: json['uid'] as String,
        name: json['name'] as String,
        entryNumber: json['entryNumber'] as String,
        mess:json['mess'] as String,
        selectedDate: json['selectedDate'] as Timestamp,
        timestamp: json['timestamp'] as Timestamp,
      );
}
