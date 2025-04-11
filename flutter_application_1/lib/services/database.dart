import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/mess_menu.dart';
import 'package:flutter_application_1/models/student.dart';
class DatabaseModel{
  final String uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DatabaseModel({required this.uid});

  

  Future<dynamic> addStudentDetails(StudentModel student) async {
    return await FirebaseFirestore.instance
        .collection("students")
        .doc(uid)
        .set(student.toJson());
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
      rethrow;
    }
  }

  Future<DocumentSnapshot> getRebateHistory(String uid) async{
    try{
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
    .collection('rebates')
    .where('user_id', isEqualTo: FirebaseFirestore.instance.collection('students').doc(uid))
    .orderBy('start_date', descending: true) // Ensure indexing supports ordering
    .get();
if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs[0];  // Return the DocumentSnapshot
      } else {
        throw Exception("No student found for the provided uid");
      }
    } catch (e) {
      print("Error fetching rebate history: $e");
      rethrow;
    }
  }

  Future<MessMenuModel?> getMenu() async {
    DocumentSnapshot doc =
        await _firestore.collection('mess_menu').doc('current_menu').get();
    if (doc.exists) {
      return MessMenuModel.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }
}