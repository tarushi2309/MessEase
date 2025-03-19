import 'package:flutter/material.dart';
import '../../components/header_admin.dart'; //import header

class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  // Menu data structure: Map<Day, Map<MealType, List<Items>>>
  Map<String, Map<String, List<TextEditingController>>> menu = {};

  final List<String> days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
  final List<String> mealTypes = ["Breakfast", "Lunch", "Dinner"];

  String selectedDay = "Monday"; // Default selected day

  @override
  void initState() {
    super.initState();
    initializeMenu();
  }

  void initializeMenu() {
    for (var day in days) {
      menu[day] = {};
      for (var meal in mealTypes) {
        menu[day]![meal] = [
          TextEditingController(text: "Item 1"),
          TextEditingController(text: "Item 2"),
          TextEditingController(text: "Item 3"),
        ];
      }
    }
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    for (var day in menu.keys) {
      for (var meal in menu[day]!.keys) {
        for (var controller in menu[day]![meal]!) {
          controller.dispose();
        }
      }
    }
    super.dispose();
  }

  void saveMenu() {
    // For now, just printing to console (Backend can be added later)
    print("Updated Menu for $selectedDay:");
    menu[selectedDay]!.forEach((mealType, controllers) {
      print("$mealType: ${controllers.map((c) => c.text).toList()}");
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Menu for $selectedDay saved successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
    preferredSize: Size.fromHeight(60.0),  // Adjust height if needed
    child: Header(currentPage: "menu"),  // Pass currentPage value
  ),
      body: Column(
        children: [
          // Row Layout for Days
          Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: days.map((day) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDay = day;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: selectedDay == day ? Colors.orange : Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        day.substring(0, 3), // Show Mon, Tue, etc.
                        style: TextStyle(
                          color: selectedDay == day ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Animated Menu Items
          Expanded(
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              transitionBuilder: (widget, animation) {
                return FadeTransition(opacity: animation, child: widget);
              },
              child: Column(
                key: ValueKey<String>(selectedDay),
                children: mealTypes.map((mealType) {
                  return Card(
                    margin: EdgeInsets.all(10),
                    elevation: 3,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mealType.toUpperCase(),
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Column(
                            children: List.generate(menu[selectedDay]![mealType]!.length, (index) {
                              return TextField(
                                controller: menu[selectedDay]![mealType]![index],
                                decoration: InputDecoration(
                                  hintText: "Enter item",
                                  suffixIcon: Icon(Icons.edit, color: Colors.orange),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Save Button
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton(
              onPressed: saveMenu,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: Text("Save Changes"),
            ),
          ),
        ],
      ),
    );
  }
}
