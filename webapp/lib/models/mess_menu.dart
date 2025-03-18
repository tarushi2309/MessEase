class MessMenuModel {
  final Map<String, Map<String, List<String>>> menu; // Nested map with a list of dishes for each meal

  MessMenuModel({
    required this.menu,
  });

  Map<String, dynamic> toJson() {
    return {
      'menu': menu,  // Nested map for menu with lists of dishes
    };
  }

  factory MessMenuModel.fromJson(Map<String, dynamic> json) {
    return MessMenuModel(
      menu: Map<String, Map<String, List<String>>>.from(json['menu']),
    );
  }
}
