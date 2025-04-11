import 'package:cloud_firestore/cloud_firestore.dart';

class AddonModel{
  String name;
  int price;
  String messId;
  DateTime date;

  AddonModel({required this.name, required this.price, required this.messId, required this.date});

  Map<String, dynamic> toJson(){
    return {
      'name': name,
      'price': price,
      'messId': messId,
      'date': DateTime.now(),
    };
  }

  factory AddonModel.fromJson(Map<String, dynamic> json){
    return AddonModel(
      name: json['name'] as String,
      price: json['price'] as int,
      messId: json['messId'] as String,
      date: json['date'] != null
        ? (json['date'] as Timestamp).toDate()
        : DateTime.now(),
    );
  }
}