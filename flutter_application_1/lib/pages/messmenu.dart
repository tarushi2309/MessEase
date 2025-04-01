/*import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/mess_menu.dart';
import 'package:flutter_application_1/services/database.dart';

import '../components/footer.dart';
import '../components/header.dart';
import '../components/navbar.dart';

class MessMenuScreen extends StatefulWidget {
  const MessMenuScreen({super.key});

  @override
  _MessMenuScreenState createState() => _MessMenuScreenState();
}

class _MessMenuScreenState extends State<MessMenuScreen>  {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int selectedDay = 0;
  bool isLoading = true;
  MessMenuModel? messMenu;

  final List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  Future<void> fetchMenu() async {
    try{
  DocumentSnapshot doc = await FirebaseFirestore.instance.collection('mess_menu').doc('current_menu').get();
   if (doc.exists) {
        setState(() {
          messMenu = MessMenuModel.fromJson(doc.data() as Map<String, dynamic>);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching menu: $e");
      setState(() {
        isLoading = false;
      });
    }
  
  final List<Map<String, List<Map<String, String>>>> weeklyMenu = [
    //MONDAY
    {
      "BREAKFAST": [
        {"image": "assets/addon.jpg", "name": "Poha"},
        {"image": "assets/addon.jpg", "name": "Omelette"},
        {"image": "assets/addon.jpg", "name": "Bread & Butter"},
        {"image": "assets/addon.jpg", "name": "Tea"},
      ],
      "LUNCH": [
        {"image": "assets/addon.jpg", "name": "Chapati"},
        {"image": "assets/addon.jpg", "name": "Dal"},
        {"image": "assets/addon.jpg", "name": "Rice"},
        {"image": "assets/addon.jpg", "name": "Salad"},
      ],
      "DINNER": [
        {"image": "assets/addon.jpg", "name": "Paneer"},
        {"image": "assets/addon.jpg", "name": "Roti"},
        {"image": "assets/addon.jpg", "name": "Curd"},
        {"image": "assets/addon.jpg", "name": "Sweet"},
      ],
    },

    //TUESDAY
    {
      "BREAKFAST": [
        {"image": "assets/addon.jpg", "name": "Omelette"},
        {"image": "assets/addon.jpg", "name": "Bread & Butter"},
        {"image": "assets/addon.jpg", "name": "Tea"},
      ],
      "LUNCH": [
        {"image": "assets/addon.jpg", "name": "Chapati"},
        {"image": "assets/addon.jpg", "name": "Dal"},
        {"image": "assets/addon.jpg", "name": "Rice"},
        {"image": "assets/addon.jpg", "name": "Salad"},
      ],
      "DINNER": [
        {"image": "assets/addon.jpg", "name": "Paneer"},
        {"image": "assets/addon.jpg", "name": "Roti"},
        {"image": "assets/addon.jpg", "name": "Curd"},
        {"image": "assets/addon.jpg", "name": "Sweet"},
      ],
    },

    //WEDNESDAY
    {
      "BREAKFAST": [
        {"image": "assets/addon.jpg", "name": "Poha"},
        {"image": "assets/addon.jpg", "name": "Omelette"},
        {"image": "assets/addon.jpg", "name": "Bread & Butter"},
        {"image": "assets/addon.jpg", "name": "Tea"},
      ],
      "LUNCH": [
        {"image": "assets/addon.jpg", "name": "Chapati"},
        {"image": "assets/addon.jpg", "name": "Dal"},
        {"image": "assets/addon.jpg", "name": "Rice"},
        {"image": "assets/addon.jpg", "name": "Salad"},
      ],
      "DINNER": [
        {"image": "assets/addon.jpg", "name": "Paneer"},
        {"image": "assets/addon.jpg", "name": "Roti"},
        {"image": "assets/addon.jpg", "name": "Curd"},
        {"image": "assets/addon.jpg", "name": "Sweet"},
      ],
    },

    //THURSDAY
    {
      "BREAKFAST": [
        {"image": "assets/addon.jpg", "name": "Omelette"},
        {"image": "assets/addon.jpg", "name": "Bread & Butter"},
        {"image": "assets/addon.jpg", "name": "Tea"},
      ],
      "LUNCH": [
        {"image": "assets/addon.jpg", "name": "Chapati"},
        {"image": "assets/addon.jpg", "name": "Dal"},
        {"image": "assets/addon.jpg", "name": "Rice"},
        {"image": "assets/addon.jpg", "name": "Salad"},
      ],
      "DINNER": [
        {"image": "assets/addon.jpg", "name": "Paneer"},
        {"image": "assets/addon.jpg", "name": "Roti"},
        {"image": "assets/addon.jpg", "name": "Curd"},
        {"image": "assets/addon.jpg", "name": "Sweet"},
      ],
    },

    //FRIDAY
    {
      "BREAKFAST": [
        {"image": "assets/addon.jpg", "name": "Poha"},
        {"image": "assets/addon.jpg", "name": "Omelette"},
        {"image": "assets/addon.jpg", "name": "Bread & Butter"},
        {"image": "assets/addon.jpg", "name": "Tea"},
      ],
      "LUNCH": [
        {"image": "assets/addon.jpg", "name": "Chapati"},
        {"image": "assets/addon.jpg", "name": "Dal"},
        {"image": "assets/addon.jpg", "name": "Rice"},
        {"image": "assets/addon.jpg", "name": "Salad"},
      ],
      "DINNER": [
        {"image": "assets/addon.jpg", "name": "Paneer"},
        {"image": "assets/addon.jpg", "name": "Roti"},
        {"image": "assets/addon.jpg", "name": "Curd"},
        {"image": "assets/addon.jpg", "name": "Sweet"},
      ],
    },

    //SATURDAY
    {
      "BREAKFAST": [
        {"image": "assets/addon.jpg", "name": "Poha"},
        {"image": "assets/addon.jpg", "name": "Omelette"},
        {"image": "assets/addon.jpg", "name": "Bread & Butter"},
        {"image": "assets/addon.jpg", "name": "Tea"},
      ],
      "LUNCH": [
        {"image": "assets/addon.jpg", "name": "Chapati"},
        {"image": "assets/addon.jpg", "name": "Dal"},
        {"image": "assets/addon.jpg", "name": "Rice"},
        {"image": "assets/addon.jpg", "name": "Salad"},
      ],
      "DINNER": [
        {"image": "assets/addon.jpg", "name": "Paneer"},
        {"image": "assets/addon.jpg", "name": "Roti"},
        {"image": "assets/addon.jpg", "name": "Curd"},
        {"image": "assets/addon.jpg", "name": "Sweet"},
      ],
    },

    //SUNDAY
    {
      "BREAKFAST": [
        {"image": "assets/addon.jpg", "name": "Poha"},
        {"image": "assets/addon.jpg", "name": "Omelette"},
        {"image": "assets/addon.jpg", "name": "Bread & Butter"},
        {"image": "assets/addon.jpg", "name": "Tea"},
      ],
      "LUNCH": [
        {"image": "assets/addon.jpg", "name": "Chapati"},
        {"image": "assets/addon.jpg", "name": "Dal"},
        {"image": "assets/addon.jpg", "name": "Rice"},
        {"image": "assets/addon.jpg", "name": "Salad"},
      ],
      "DINNER": [
        {"image": "assets/addon.jpg", "name": "Paneer"},
        {"image": "assets/addon.jpg", "name": "Roti"},
        {"image": "assets/addon.jpg", "name": "Curd"},
        {"image": "assets/addon.jpg", "name": "Sweet"},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56),
        child: Header(scaffoldKey: scaffoldKey),
      ),
      drawer: Navbar(),
      body: Column(
        children: [
          SizedBox(height: 10),
          Container( 
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Even spacing
              children: List.generate(days.length, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDay = index;
                    });
                  },
                  child: Text(
                    days[index],
                    style: TextStyle(
                      fontSize: 16, // Adjust font size for a subtle look
                      fontWeight: FontWeight.w400, // Medium font weight
                      color: selectedDay == index
                          ? Colors.black
                          : Colors.grey, // Highlight selected day
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(10),
              children: weeklyMenu[selectedDay].entries.map((entry) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  //elevation: 1,
                  color: Colors.white,
                  
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Meal Title
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 20, 10, 4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Horizontally Scrollable Food Items
                        SizedBox(
                          height: 110,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: entry.value.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 35,
                                      backgroundImage:
                                          AssetImage(entry.value[index]['image']!),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      entry.value[index]['name']!,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomNavigationBar(),
    );
  }
}*/
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/mess_menu.dart';
import '../components/footer.dart';
import '../components/header.dart';
import '../components/navbar.dart';

class MessMenuScreen extends StatefulWidget {
  const MessMenuScreen({super.key});

  @override
  _MessMenuScreenState createState() => _MessMenuScreenState();
}

class _MessMenuScreenState extends State<MessMenuScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int selectedDay = 0;
  bool isLoading = true;
  MessMenuModel? messMenu;

  // Changed days format to short form
  final List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  final List<String> fullDays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
  final String defaultImage = "assets/addon.jpg";

  @override
  void initState() {
    super.initState();
    fetchMenu();
  }

  Future<void> fetchMenu() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('mess_menu').doc('current_menu').get();
      if (doc.exists) {
        setState(() {
          messMenu = MessMenuModel.fromJson(doc.data() as Map<String, dynamic>);
        });
      }
    } catch (e) {
      print("Error fetching menu: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Header(scaffoldKey: scaffoldKey),
      ),
      drawer: Navbar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : messMenu == null
              ? const Center(child: Text("No menu available"))
              : Column(
                  children: [
                    const SizedBox(height: 10),

                    // Days Row (Now showing short forms)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(days.length, (index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedDay = index;
                              });
                            },
                            child: Text(
                              days[index], // Short form days
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: selectedDay == index ? Colors.black : Colors.grey,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    // Meal Cards (Changed order to Breakfast → Lunch → Dinner)
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(10),
                        children: ["Breakfast", "Lunch", "Dinner"].map((meal) {
                          // Get meal items for the selected day
                          var dayMenu = messMenu!.menu[fullDays[selectedDay]] ?? {};
                          var mealItems = dayMenu[meal] ?? [];

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Meal Title
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      meal, // Display meal name
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 20, 10, 4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  // Food Items (Horizontally Scrollable)
                                  SizedBox(
                                    height: 110,
                                    width: double.infinity,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: List.generate(mealItems.length, (index) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                            child: Column(
                                              children: [
                                                CircleAvatar(
                                                  radius: 35,
                                                  backgroundImage: AssetImage(defaultImage),
                                                ),
                                                const SizedBox(height: 5),
                                                Text(
                                                  mealItems[index],
                                                  style: const TextStyle(fontSize: 14),
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: CustomNavigationBar(),
    );
  }
}
