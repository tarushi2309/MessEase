import 'package:cloud_firestore/cloud_firestore.dart';

enum status {
  pending,
  approve,
  reject,
}

enum hostel {
  raavi,
  chenab,
  brahmaputra,
  beas, 
  satluj,
}



class Rebate {
  final String req_id;
  final DocumentReference student_id;
  final Timestamp start_date;
  final Timestamp end_date;
  final status status_;
  final hostel hostel_;
  final String mess_;

  Rebate({
    required this.req_id,
    required this.student_id,
    required this.start_date,
    required this.end_date,
    required this.status_,
    required this.hostel_,
    required this.mess_,
  }) ;

  factory Rebate.fromJson(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Convert the status field from a string to an enum
    status status_= status.values.firstWhere(
      (e) => e.toString() == 'status.${data['status']}',
      orElse: () => status.pending, // Default to 'pending' if not found
    );

    hostel hostel_= hostel.values.firstWhere(
      (e) => e.toString() == 'hostel.${data['hostel']}',
    );

    
    return Rebate(
      req_id: doc.id,
      student_id: data['student_id'],
      start_date: data['start_date'],
      end_date: data['end_date'],
      status_: status_,
      hostel_: hostel_,
      mess_ :data['mess'],
    );
  }

  // Convert a Rebate instance to a map for Firestore storage
  Map<String, dynamic> toJson() {
    return {
      'req_id': req_id,
      'student_id': student_id,
      'start_date': start_date,
      'end_date': end_date,
      'status': status_.toString().split('.').last, // Convert enum to string
      'hostel': hostel_.toString().split('.').last,
      'mess': mess_,
    };
  }

}