import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/student.dart';
import 'package:flutter_application_1/models/user.dart';
class DatabaseModel{
  final String uid;

  DatabaseModel({required this.uid});

  Future<dynamic> addUserDetails(UserModel user) async {
    return await FirebaseFirestore.instance
        .collection("user")
        .doc(uid)
        .set(user.toJson());
  }

   Future<dynamic> addStudentDetails(StudentModel student) async {
    return await FirebaseFirestore.instance
        .collection("students")
        .doc(uid)
        .set(student.toJson());
  }
}