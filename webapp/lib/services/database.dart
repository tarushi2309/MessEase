import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webapp/models/addon.dart';
import '../models/student.dart';
import '../models/user.dart';
import '../models/rebate.dart';
import '../models/mess_manager.dart';
import '../models/mess.dart';
import 'package:provider/provider.dart';

class DatabaseModel {
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
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance
            .collection("user")
            .where("uid", isEqualTo: uid)
            .limit(1) // Ensure only one document is returned
            .get();

    // Return the first document in the QuerySnapshot (if exists)
    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs[0]; // Return the DocumentSnapshot
    } else {
      throw Exception("No user found for the provided uid");
    }
  }

  //to get the mess manager info
  Future<DocumentSnapshot> getMessManagerInfo(String uid) async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance
            .collection("mess_manager")
            .where("uid", isEqualTo: uid)
            .limit(1) // Ensure only one document is returned
            .get();

    // Return the first document in the QuerySnapshot (if exists)
    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs[0]; // Return the DocumentSnapshot
    } else {
      throw Exception("No Mess Manager found for the provided uid");
    }
  }

  // to get the messId from the uid
  Future<String?> getMessId() async {
    try {
      DocumentSnapshot messManagerDoc = await getMessManagerInfo(uid);
      if (messManagerDoc.exists) {
        return messManagerDoc['messId']; //extracted the messId
      } else {
        print("No mess manager found for this uid");
        return null;
      }
    } catch (e) {
      print("Error getting the messId: $e");
      return null;
    }
  }

  //function to add the addon into the database
  Future<String> addAddon(String name, String price) async {
    if (name.isEmpty || price.isEmpty) {
      return "Please fill in all fields.";
    }

    try {
      double parsedPrice = double.parse(price); // Convert price to double
      String? messId = await getMessId();
      if (messId == null) {
        return "Error: Mess ID not found";
      }

      // Query Firestore to check if the addon already exists
      QuerySnapshot querySnapshot =
          await _firestore
              .collection('addons')
              .where('name', isEqualTo: name)
              .where('messId', isEqualTo: messId)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        // If the add-on exists, update the price and set isSelected to true
        DocumentReference existingDoc = querySnapshot.docs.first.reference;

        await existingDoc.update({'price': parsedPrice, 'isSelected': true});

        return "Add-on updated successfully!";
      } else {
        // If the add-on doesn't exist, create a new one
        AddonModel addon = AddonModel(
          name: name,
          price: parsedPrice,
          isSelected: true,
          messId: messId,
        );

        DocumentReference docRef = await _firestore
            .collection('addons')
            .add(addon.toJson());
        //await docRef.update({'id': docRef.id}); // Store Firestore ID in the document

        return "Add-on added successfully!";
      }
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }

  Future<List<AddonModel>> fetchSelectedAddons() async {
    String? messId = await getMessId();

    if (messId == null) {
      print("No messId found.");
      return [];
    }

    QuerySnapshot query =
        await _firestore
            .collection('addons')
            .where('messId', isEqualTo: messId)
            .where('isSelected', isEqualTo: true)
            .get();

    return query.docs
        .map((doc) => AddonModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
