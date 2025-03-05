class HostelModel {
  final String hostelId;
  final String hostelName;
  final String location;

  HostelModel({
    required this.hostelId,
    required this.hostelName,
    required this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      'hostelId': hostelId,
      'hostelName': hostelName,
      'location': location,
    };
  }

  factory HostelModel.fromJson(Map<String, dynamic> json) {
    return HostelModel(
      hostelId: json['hostelId'],
      hostelName: json['hostelName'],
      location: json['location'],
    );
  }
}
