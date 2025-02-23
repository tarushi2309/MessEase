class StudentModel {
  final String uid;
  final String name;
  final String email;
  final String degree;
  final String password;
  final String entryNumber;
  final int year;

  StudentModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.degree,
    required this.entryNumber,
    required this.year,
    required this.password
  }) ;

  // Convert a UserModel into a Map for storing in Firestore or Realtime Database.
  Map<String, dynamic> toJson() => {
        'uid': uid,
        'name': name,
        'email': email,
        'degree': degree,
        'entryNumber': entryNumber,
        'year': year,
        'password': password
      };

  // Create a UserModel instance from a Map.
  factory StudentModel.fromJson(Map<String, dynamic> json) => StudentModel(
        uid: json['uid'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        degree: json['degree'] as String,
        entryNumber: json['entryNumber'] as String,
        year: json['year'] as int,
        password: json['password'] as String
      );
}
