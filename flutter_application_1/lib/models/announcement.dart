class AnnouncementModel {
  final String announcement;
  final List<String> mess; // Changed to List<String>
  final String date;

  AnnouncementModel({
    required this.announcement,
    required this.mess,
    required this.date,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      announcement: json['announcement']?.toString() ?? '',
      mess: (json['mess'] as List<dynamic>?)?.cast<String>() ?? [],
      date: json['date']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'announcement': announcement,
      'mess': mess,
      'date': date,
    };
  }
}