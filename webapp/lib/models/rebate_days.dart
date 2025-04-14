import 'package:cloud_firestore/cloud_firestore.dart';

class RebateDates {
  final String studentId;
  final List<RebatePeriod> rebatePeriods;
  final int totalNumDays;

  RebateDates({
    required this.studentId,
    required this.rebatePeriods,
    required this.totalNumDays,
  });

  factory RebateDates.fromJson(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final periods = (data['rebatePeriods'] as List<dynamic>? ?? [])
        .map((p) => RebatePeriod.fromJson(p as Map<String, dynamic>))
        .toList();

    return RebateDates(
      studentId: data['studentId']?.toString() ?? '',
      rebatePeriods: periods,
      totalNumDays: data['totalNumDays'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'rebatePeriods': rebatePeriods.map((p) => p.toJson()).toList(),
      'totalNumDays': totalNumDays,
    };
  }
}

class RebatePeriod {
  final Timestamp startDate;
  final Timestamp endDate;

  RebatePeriod({
    required this.startDate,
    required this.endDate,
  });

  factory RebatePeriod.fromJson(Map<String, dynamic> json) {
    return RebatePeriod(
      startDate: json['startDate'] as Timestamp,
      endDate: json['endDate'] as Timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate,
      'endDate': endDate,
    };
  }
}