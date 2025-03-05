import 'package:cloud_firestore/cloud_firestore.dart';


class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role_; 

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role_,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'name': name,
        'email': email,
        'role': role_,
      };

  factory UserModel.fromJson(DocumentSnapshot doc) {

    return UserModel(
      uid: doc['uid'] as String,
      name: doc['name'] as String,
      email: doc['email'] as String,
      role_: doc['role'] as String,
    );
    
  }
}
