import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/student.dart';
import 'package:flutter_application_1/models/user.dart';
class DatabaseModel{
  final String uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  Future<DocumentSnapshot> getUserInfo(String uid) async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection("user")
      .where("uid", isEqualTo: uid)
      .limit(1)  // Ensure only one document is returned
      .get();

  // Return the first document in the QuerySnapshot (if exists)
  if (querySnapshot.docs.isNotEmpty) {
    return querySnapshot.docs[0];  // Return the DocumentSnapshot
  } else {
    throw Exception("No student found for the provided uid");
  }
}

  Future<DocumentSnapshot> getStudentInfo(String uid) async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection("students")
      .where("uid", isEqualTo: uid)
      .limit(1)  // Ensure only one document is returned
      .get();

  // Return the first document in the QuerySnapshot (if exists)
  if (querySnapshot.docs.isNotEmpty) {
    return querySnapshot.docs[0];  // Return the DocumentSnapshot
  } else {
    throw Exception("No student found for the provided uid");
  }
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

  Future<List<Map<String, dynamic>>> getRebateHistory(String userId) async{
    try{
      QuerySnapshot querySnapshot = await _firestore
          .collection('rebates')
          .where('userId', isEqualTo: userId)
          .orderBy('from', descending: true)
          .get();
      return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch(e){
      print("Error fetching the history: $e");
      return [];
    }
  }
}