import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String? uid;
   UserProvider() {
    // Whenever the Firebase user state changes (login, reload, etc.),
    // update our uid and notify listeners.
    FirebaseAuth.instance.authStateChanges().listen((user) {
      uid = user?.uid;
      notifyListeners();
    });
  }
  // Set the uid after sign-in
  void setUid(String id) {
    uid = id;
    notifyListeners(); // Notify listeners that the uid has been updated
  }

  // Optionally, clear the uid on sign-out
  void clearUid() {
    uid = null;
    notifyListeners();
  }
}
