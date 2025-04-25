import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:webapp/models/addon.dart';
import 'package:webapp/models/announcement.dart';
import 'package:webapp/models/mess.dart';
import 'package:webapp/models/mess_menu.dart';
import '../models/student.dart';
import '../models/user.dart';

class DatabaseModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String?messId;

  Future<dynamic> addStudentDetails(StudentModel student,String uid) async {
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

  Future<dynamic> addUserDetails(UserModel user) async {
    return await FirebaseFirestore.instance
        .collection("user")
        .doc(user.uid)
        .set(user.toJson());
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
  Future<void> getMessId(String uid) async {
    try {
      DocumentSnapshot messManagerDoc = await getMessManagerInfo(uid);
      if (messManagerDoc.exists) {
        messId= messManagerDoc['messId']; //extracted the messId
        //print("messId: $messId");
      } else {
        print("No mess manager found for this uid");
        return;
      }
    } catch (e) {
      print("Error getting the messId: $e");
      return;
    }
  }

  // to get the messId from the uid
  Future<void> getMessIdStudent(String uid) async {
    try {
      DocumentSnapshot studentDoc = await getStudentInfo(uid);
      if (studentDoc.exists) {
        messId= studentDoc['mess'];
        //print("messId: $messId");
      } else {
        print("No student found for this uid");
        return;
      }
    } catch (e) {
      print("Error getting the messId: $e");
      return;
    }
  }

  //function to add the addon into the database
  Future<String> addAddon(String name, String price) async {
    if (name.isEmpty || price.isEmpty) {
      return "Please fill in all fields.";
    }

    try {
      int parsedPrice = int.parse(price); // Convert price to double
      print("messId: $messId");
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

        await existingDoc.update({'price': parsedPrice});

        return "Add-on updated successfully!";
      } else {
        // If the add-on doesn't exist, create a new one
        AddonModel addon = AddonModel(
          name: name,
          price: parsedPrice,
          messId: messId!,
          date: DateTime.now(),
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

  Future<void> removePrevAddons() async{
    print("messId: $messId");
    if (messId == null) {
      return;
    }
    QuerySnapshot querySnapshot =
          await _firestore
              .collection('addons').where('date', isLessThan: Timestamp.fromDate(DateTime.now())).get();
    print(querySnapshot.docs);
    for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }
  //function to remove the addon into the database
  Future<String> removeAddon(String name) async {
    if (name.isEmpty) {
      return "Please fill in all fields.";
    }

    try {
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
        existingDoc.delete();

        return "Add-on removed successfully!";
      } else {
        // If the add-on doesn't exist, create a new one
        return "Add-on not found!";
      }
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }
  Future<List<AddonModel>> fetchAddons() async {

    if (messId == null) {
      print("No messId found.");
      return [];
    }

    QuerySnapshot query =
        await _firestore
            .collection('addons')
            .where('messId', isEqualTo: messId)
            .get();

    return query.docs
        .map((doc) => AddonModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  

   Future<dynamic> addMessDetails(MessModel mess) async {
    return await FirebaseFirestore.instance
        .collection("mess").doc('messAllotment')
        .set(mess.toJson());
  }


  Future<List<AnnouncementModel>> fetchAnnouncements() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('announcements')
          .get();
      return querySnapshot.docs
          .map((doc) => AnnouncementModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching announcements: $e');
      return [];
    }
  }

  Future<List<AnnouncementModel>> fetchAnnouncementsRecent() async {
    try {
      final twoWeeksAgo = DateTime.now().subtract(const Duration(days: 14));
      final querySnapshot = await FirebaseFirestore.instance
          .collection('announcements')
          .where('date', isGreaterThanOrEqualTo: twoWeeksAgo.toIso8601String())
          .get();

      return querySnapshot.docs
          .map((doc) => AnnouncementModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching recent announcements: $e');
      return [];
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

  Future<void> addItem(String day, String meal, String item) async {
    DocumentReference docRef = _firestore
        .collection('mess_menu')
        .doc('current_menu');
    DocumentSnapshot doc = await docRef.get();

    // If the document is empty or doesn't exist, initialize it
    Map<String, dynamic> menuData = {};

    if (doc.exists && doc.data() != null) {
      menuData = doc.data() as Map<String, dynamic>;
    }

    // Ensure the "menu" structure exists
    menuData.putIfAbsent('menu', () => {});
    menuData['menu'].putIfAbsent(day, () => {});
    menuData['menu'][day].putIfAbsent(meal, () => []);

    // Add item only if it doesn't already exist
    List<dynamic> mealItems = List.from(menuData['menu'][day][meal]);
    if (!mealItems.contains(item)) {
      mealItems.add(item);
    }
    menuData['menu'][day][meal] = mealItems;

    // Update Firestore
    await docRef.set(menuData);
  }

  Future<void> removeItem(String day, String meal, String item) async {
    DocumentReference docRef = _firestore
        .collection('mess_menu')
        .doc('current_menu');
    DocumentSnapshot doc = await docRef.get();

    if (doc.exists) {
      MessMenuModel menu = MessMenuModel.fromJson(
        doc.data() as Map<String, dynamic>,
      );
      menu.menu[day]?[meal]?.remove(item);
      await docRef.update({'menu': menu.menu});
    }
  }
}
