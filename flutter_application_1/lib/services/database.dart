import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/student.dart';
class DatabaseModel{
  final String uid;

  DatabaseModel({required this.uid});

   Future<dynamic> addStudentDetails(StudentModel student) async {
    return await FirebaseFirestore.instance
        .collection("students")
        .doc(uid)
        .set(student.toJson());
  }
}