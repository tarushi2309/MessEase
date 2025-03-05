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

  Future<void> addRebateFormDetails({
    required String hostelName,
    required DateTime rebateFrom,
    required DateTime rebateTo,
    required int numDays,
  }) async {
    try {
      await FirebaseFirestore.instance.collection("rebates").add({
        "userId": uid,
        "hostelName": hostelName,
        "rebateFrom": rebateFrom.toIso8601String(),
        "rebateTo": rebateTo.toIso8601String(),
        "numDays": numDays,
        "timestamp": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error adding rebate form: $e");
      throw e;
    }
  }
}