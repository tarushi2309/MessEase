class MessModel {
  Map<String,String> messAllot;

  MessModel({
    required this.messAllot,
  });

  Map<String,dynamic> toJson() {
    return {
      'messAllot': messAllot,
    };
  }

  factory MessModel.fromJson(Map<String, dynamic> json) {
    return MessModel(
      messAllot: Map<String,String>.from(json['messAllot'] as Map<String, dynamic>),
    );
  }
}
