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
      "Breakfast": [
        {"image": "assets/poha.png", "name": "Poha"},
        {"image": "assets/omelette.png", "name": "Omelette"},
        {"image": "assets/bread.png", "name": "Bread & Butter"},
        {"image": "assets/tea.png", "name": "Tea"},
      ],
      "Lunch": [
        {"image": "assets/chapati.png", "name": "Chapati"},
        {"image": "assets/dal.png", "name": "Dal"},
        {"image": "assets/rice.png", "name": "Rice"},
        {"image": "assets/salad.png", "name": "Salad"},
      ],
      "Dinner": [
        {"image": "assets/paneer.png", "name": "Paneer"},
        {"image": "assets/roti.png", "name": "Roti"},
        {"image": "assets/curd.png", "name": "Curd"},
        {"image": "assets/sweet.png", "name": "Sweet"},
      ],
    },

    //TUESDAY
    {
      "Breakfast": [
        {"image": "assets/omelette.png", "name": "Omelette"},
        {"image": "assets/bread.png", "name": "Bread & Butter"},
        {"image": "assets/tea.png", "name": "Tea"},
      ],
      "Lunch": [
        {"image": "assets/chapati.png", "name": "Chapati"},
        {"image": "assets/dal.png", "name": "Dal"},
        {"image": "assets/rice.png", "name": "Rice"},
        {"image": "assets/salad.png", "name": "Salad"},
      ],
      "Dinner": [
        {"image": "assets/paneer.png", "name": "Paneer"},
        {"image": "assets/roti.png", "name": "Roti"},
        {"image": "assets/curd.png", "name": "Curd"},
        {"image": "assets/sweet.png", "name": "Sweet"},
      ],
    },

    //WEDNESDAY
    {
      "Breakfast": [
        {"image": "assets/poha.png", "name": "Poha"},
        {"image": "assets/omelette.png", "name": "Omelette"},
        {"image": "assets/bread.png", "name": "Bread & Butter"},
        {"image": "assets/tea.png", "name": "Tea"},
      ],
      "Lunch": [
        {"image": "assets/chapati.png", "name": "Chapati"},
        {"image": "assets/dal.png", "name": "Dal"},
        {"image": "assets/rice.png", "name": "Rice"},
        {"image": "assets/salad.png", "name": "Salad"},
      ],
      "Dinner": [
        {"image": "assets/paneer.png", "name": "Paneer"},
        {"image": "assets/roti.png", "name": "Roti"},
        {"image": "assets/curd.png", "name": "Curd"},
        {"image": "assets/sweet.png", "name": "Sweet"},
      ],
    },

    //THURSDAY
    {
      "Breakfast": [
        {"image": "assets/omelette.png", "name": "Omelette"},
        {"image": "assets/bread.png", "name": "Bread & Butter"},
        {"image": "assets/tea.png", "name": "Tea"},
      ],
      "Lunch": [
        {"image": "assets/chapati.png", "name": "Chapati"},
        {"image": "assets/dal.png", "name": "Dal"},
        {"image": "assets/rice.png", "name": "Rice"},
        {"image": "assets/salad.png", "name": "Salad"},
      ],
      "Dinner": [
        {"image": "assets/paneer.png", "name": "Paneer"},
        {"image": "assets/roti.png", "name": "Roti"},
        {"image": "assets/curd.png", "name": "Curd"},
        {"image": "assets/sweet.png", "name": "Sweet"},
      ],
    },
    
    //FRIDAY
    {
      "Breakfast": [
        {"image": "assets/poha.png", "name": "Poha"},
        {"image": "assets/omelette.png", "name": "Omelette"},
        {"image": "assets/bread.png", "name": "Bread & Butter"},
        {"image": "assets/tea.png", "name": "Tea"},
      ],
      "Lunch": [
        {"image": "assets/chapati.png", "name": "Chapati"},
        {"image": "assets/dal.png", "name": "Dal"},
        {"image": "assets/rice.png", "name": "Rice"},
        {"image": "assets/salad.png", "name": "Salad"},
      ],
      "Dinner": [
        {"image": "assets/paneer.png", "name": "Paneer"},
        {"image": "assets/roti.png", "name": "Roti"},
        {"image": "assets/curd.png", "name": "Curd"},
        {"image": "assets/sweet.png", "name": "Sweet"},
      ],
    },

    //SATURDAY
    {
      "Breakfast": [
        {"image": "assets/poha.png", "name": "Poha"},
        {"image": "assets/omelette.png", "name": "Omelette"},
        {"image": "assets/bread.png", "name": "Bread & Butter"},
        {"image": "assets/tea.png", "name": "Tea"},
      ],
      "Lunch": [
        {"image": "assets/chapati.png", "name": "Chapati"},
        {"image": "assets/dal.png", "name": "Dal"},
        {"image": "assets/rice.png", "name": "Rice"},
        {"image": "assets/salad.png", "name": "Salad"},
      ],
      "Dinner": [
        {"image": "assets/paneer.png", "name": "Paneer"},
        {"image": "assets/roti.png", "name": "Roti"},
        {"image": "assets/curd.png", "name": "Curd"},
        {"image": "assets/sweet.png", "name": "Sweet"},
      ],
    },

    //SUNDAY
    {
      "Breakfast": [
        {"image": "assets/poha.png", "name": "Poha"},
        {"image": "assets/omelette.png", "name": "Omelette"},
        {"image": "assets/bread.png", "name": "Bread & Butter"},
        {"image": "assets/tea.png", "name": "Tea"},
      ],
      "Lunch": [
        {"image": "assets/chapati.png", "name": "Chapati"},
        {"image": "assets/dal.png", "name": "Dal"},
        {"image": "assets/rice.png", "name": "Rice"},
        {"image": "assets/salad.png", "name": "Salad"},
      ],
      "Dinner": [
        {"image": "assets/paneer.png", "name": "Paneer"},
        {"image": "assets/roti.png", "name": "Roti"},
        {"image": "assets/curd.png", "name": "Curd"},
        {"image": "assets/sweet.png", "name": "Sweet"},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56),
        child: Header(scaffoldKey: scaffoldKey),
      ),
      drawer: Navbar(),
      body: Column(
        children: [
          SizedBox(height: 10),
          Container(
            color: Color(0xFFF0753C),
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                      color: selectedDay == index ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: ListView(
              children: weeklyMenu[selectedDay].entries.map((entry) {
                return ExpansionTile(
                  title: Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF0753C),
                    ),
                  ),
                  children: [
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: entry.value.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage: AssetImage(entry.value[index]['image']!),
                                ),
                                SizedBox(height: 5),
                                Text(entry.value[index]['name']!),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomNavigationBar(selectedIndex: 2),
    );
  }
}
