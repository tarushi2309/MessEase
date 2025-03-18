import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';
import '../models/user.dart';
import '../models/rebate.dart';
import '../models/mess_manager.dart';
import '../models/mess.dart';
import 'package:provider/provider.dart';

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
      throw Exception("No user found for the provided uid");
    }
  }

  //to get the mess manager info
  Future<DocumentSnapshot> getMessManagerInfo(String uid) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("mess_manager")
        .where("uid", isEqualTo: uid)
        .limit(1)  // Ensure only one document is returned
        .get();

    // Return the first document in the QuerySnapshot (if exists)
    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs[0];  // Return the DocumentSnapshot
    } else {
      throw Exception("No Mess Manager found for the provided uid");
    }
  }

  // to get the messId from the uid 
  Future<String?> getMessId() async {
    try{
      DocumentSnapshot messManagerDoc = await getMessManagerInfo(uid);
      if(messManagerDoc.exists){
        return messManagerDoc['messId']; //extracted the messId
      } else {
        print("No mess manager found for this uid");
        return null;
      }
    } catch(e){
      print("Error getting the messId: $e");
      return null;
    }
  }

  

  
}