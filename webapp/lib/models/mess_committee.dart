class MessCommitteeModel{
  String name;
  String entryNumber;
  String email;
  String phoneNumber;
  String messName;

  MessCommitteeModel({required this.name, required this.entryNumber, required this.email, required this.phoneNumber, required this.messName});

  Map<String, dynamic> toJson(){
    return {
      'name': name,
      'entryNumber': entryNumber,
      'email': email,
      'phoneNumber': phoneNumber,
      'messName': messName,
    };
  }

  factory MessCommitteeModel.fromJson(Map<String, dynamic> json){
    return MessCommitteeModel(
      name: json['name'],
      entryNumber: json['entryNumber'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      messName: json['messName'],
    );
  }
}