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

    // Extract "menu" key before processing
    if (!json.containsKey('menu') || json['menu'] == null) {
      return MessMenuModel(menu: {}); // Return empty if missing
    }

    Map<String, dynamic> menuData = json['menu'];

    return MessMenuModel(
      menu: menuData.map((day, meals) {
        return MapEntry(
          day,
          (meals as Map<String, dynamic>?)?.map((mealType, items) {
                return MapEntry(
                  mealType,
                  items is List<dynamic> ? List<String>.from(items) : [],
                );
              }) ??
              {
                "Breakfast": [],
                "Lunch": [],
                "Dinner": []
              }, // Default structure
        );
      }),
    );
  }
}
