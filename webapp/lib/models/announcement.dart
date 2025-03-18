class AnnouncementModel {
  final String announcement;
  final String messId;
  final String date;

  AnnouncementModel({required this.announcement, required this.messId, required this.date});

  Map<String, dynamic> toJson() {
    return {
      'announcement': announcement,
      'messId': messId,
      'date': date,
    };
  }

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      announcement: json['announcement'],
      messId: json['messId'],
      date: json['date'],
    );
  }
}