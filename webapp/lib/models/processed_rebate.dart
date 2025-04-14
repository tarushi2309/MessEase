import 'package:cloud_firestore/cloud_firestore.dart';

enum hostel {
  raavi,
  chenab,
  brahmaputra,
  beas, 
  satluj,
}

class ProcessedRebate {
  final String docId;
  final String studentId;
  final String name;
  final String entryNumber;
  final String year;
  final String mess;
  final String degree;
  final int numberOfDays;
  String bankAccountNumber;
  final String ifscCode;
  final int refund;
  final String email;
  final String status;

  ProcessedRebate({
    required this.docId,
    required this.studentId,
    required this.name,
    required this.entryNumber,
    required this.year,
    required this.mess,
    required this.degree,
    required this.numberOfDays,
    required this.bankAccountNumber,
    required this.ifscCode,
    required this.refund,
    required this.email,
    this.status = 'processed',
  }) ;

  factory ProcessedRebate.fromJson(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ProcessedRebate(
      docId: doc.id,
      studentId: data['studentId'] ?? '',
      name: data['name'] ?? '',
      entryNumber: data['entryNumber'] ?? '',
      year: data['year'] ?? '',
      mess: data['mess'],
      degree: data['degree'] ?? '',
      numberOfDays: data['numberOfDays'] ?? 0,
      bankAccountNumber: data['bankAccountNumber'] ?? '',
      ifscCode: data['ifscCode'] ?? '',
      refund: data['refund'] ?? 0,
      email: data['email'] ?? '',
      status: 'processed', 
    );
  }

  // Convert a Rebate instance to a map for Firestore storage
  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'name': name,
      'entryNumber': entryNumber,
      'year': year,
      'mess': mess,
      'degree': degree,
      'numberOfDays': numberOfDays,
      'bankAccountNumber': bankAccountNumber,
      'ifscCode': ifscCode,
      'refund': refund,
      'email': email,
      'status': 'processed', 
    };
  }
}