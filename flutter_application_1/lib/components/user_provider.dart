import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String? _uid;

  String? get uid => _uid;

  // Set the uid after sign-in
  void setUid(String uid) {
    _uid = uid;
    notifyListeners(); // Notify listeners that the uid has been updated
  }

  // Optionally, clear the uid on sign-out
  void clearUid() {
    _uid = null;
    notifyListeners();
  }
}
