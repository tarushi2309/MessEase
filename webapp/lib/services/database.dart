import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webapp/models/student.dart';
import 'package:webapp/models/user.dart';
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
  Future<String> getMessId() async {
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

  // to get pending rebates
  Future<List<Rebate>> getPendingRebates() async {
    try{
      String? messId = await getMessId();
      if(messId == null) throw Exception("Mess ID not found");

      Map<String, String> messMapping = {
        "1": "Konark",
        "2": "Anusha",
        "3": "Ideal",
      };

      String? messName = messMapping[messId];
      if(messName == null) throw Exception("Invalid uid");

      //Query firestore getting the pending requests for the uid 
      QuerySnapshot rebateQuery = await _firestore
        .collection("rebates")
        .where("mess", isEqualTo: messName)
        .where("status", isEqualTo: pending)
        .get()
      return rebateQuery.docs.map((doc) => Rebate.fromJson(doc)).toList();
    } catch (e) {
      print("Error fetching the pending rebated for this query $e");
      return [];
    }
  }

  
}