class MessMenuModel {
  final Map<String, Map<String, List<String>>> menu; 

  MessMenuModel({
    required this.menu,
  });

  Map<String, dynamic> toJson() {
    return {
      'menu': menu,  
    };
  }

  factory MessMenuModel.fromJson(Map<String, dynamic> json) {
    return MessMenuModel(
      menu: Map<String, Map<String, List<String>>>.from(json['menu']),
    );
  }
}
