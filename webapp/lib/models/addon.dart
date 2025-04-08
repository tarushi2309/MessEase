import 'package:cloud_firestore/cloud_firestore.dart';

class AddonModel{
  String name;
  double price;
  bool isSelected;
  String messId;
  DateTime date;

  AddonModel({required this.name, required this.price, required this.isSelected, required this.messId, required this.date});

  Map<String, dynamic> toJson(){
    return {
      'name': name,
      'price': price,
      'isSelected': isSelected,
      'messId': messId,
      'date': DateTime.now(),
    };
  }

  factory AddonModel.fromJson(Map<String, dynamic> json){
    return AddonModel(
      name: json['name'],
      price: json['price'],
      isSelected: false,
      messId: json['messId'],
      date: json['date'] != null
        ? (json['date'] as Timestamp).toDate()
        : DateTime.now(),
    );
  }
}