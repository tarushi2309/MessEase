

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

   factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      name: json['name'],
      email: json['email'],
      role_: json['role'],
    );
  }
}
