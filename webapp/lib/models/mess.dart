class MessModel {
  final String messId;
  final String messName;
  final String location;

  MessModel({
    required this.messId,
    required this.messName,
    required this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      'messId': messId,
      'messName': messName,
      'location': location,
    };
  }

  factory MessModel.fromJson(Map<String, dynamic> json) {
    return MessModel(
      messId: json['messId'],
      messName: json['messName'],
      location: json['location'],
    );
  }
}
