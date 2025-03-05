import 'package:flutter/material.dart';

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

  final List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

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
}
