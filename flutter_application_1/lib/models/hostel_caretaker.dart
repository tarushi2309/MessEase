class HostelCareTakerModel {
  final String uid; // Reference to User
  final String hostelId;
  final String phoneNumber;

  HostelCareTakerModel({
    required this.uid,
    required this.hostelId,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'hostelId': hostelId,
      'phoneNumber': phoneNumber,
    };
  }

  factory HostelCareTakerModel.fromJson(Map<String, dynamic> json) {
    return HostelCareTakerModel(
      uid: json['uid'],
      hostelId: json['hostelId'],
      phoneNumber: json['phoneNumber'],
    );
  }
}
