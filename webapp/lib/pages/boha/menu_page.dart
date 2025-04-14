import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:webapp/components/header_boha.dart';
import 'package:webapp/models/mess_menu.dart';
import 'package:webapp/services/database.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  int selectedIndex = 0; // Tracks selected day

  DatabaseModel db = DatabaseModel(uid: FirebaseAuth.instance.currentUser!.uid);

  final List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Header(currentPage: 'Menu Page'),
      ),
      body: Row(
        children: [
          // Left Sidebar Menu
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 180, // Fixed width for sidebar
              height: MediaQuery.of(context).size.height - 40,
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 0.5,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      "Days",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 140,
                      child: Divider(color: Color(0xFFF0753C), thickness: 1),
                    ),
                  ),
                  ...List.generate(days.length, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          border:
                              selectedIndex == index
                                  ? Border.all(color: Colors.black, width: 1)
                                  : null,
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Row(
                            children: [
                              Image.asset(
                                'logos/${days[index].toLowerCase()}.png',
                                width: 24,
                                height: 24,
                              ),
                              const SizedBox(
                                width: 10,
                              ), // Space between icon and text
                              Text(
                                days[index],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Main Content Area (Dynamically changing)
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 0.5,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: FutureBuilder<Widget>(
                future: _buildMainContent(days[selectedIndex]),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    return snapshot.data ?? Center(child: Text('No data'));
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Widget> _buildMainContent(String day) async {
    return FutureBuilder<MessMenuModel?>(
      future: db.getMenu(),
      builder: (context, menuSnapshot) {
        if (menuSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (menuSnapshot.hasError) {
          return Center(child: Text('Error: ${menuSnapshot.error}'));
        }

        // Default to empty menu if data is null
        MessMenuModel messMenu = menuSnapshot.data ?? MessMenuModel(menu: {});
        Map<String, List<String>> menuForDay =
            messMenu.menu[day] ?? {'Breakfast': [], 'Lunch': [], 'Dinner': []};

        if (messMenu.menu.containsKey(day)) {
          menuForDay = messMenu.menu[day]!;
        }

        return Column(
          children: [
            Text(
              'MESS MENU',
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 24),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMealCard(
                    'Breakfast',
                    menuForDay['Breakfast'] ?? [],
                    day,
                  ),
                  _buildMealCard('Lunch', menuForDay['Lunch'] ?? [], day),
                  _buildMealCard('Dinner', menuForDay['Dinner'] ?? [], day),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMealCard(String mealType, List<String> items, String day) {
    TextEditingController addItemInput = TextEditingController();

    return Expanded(
      child: Card(
        color: Colors.white,
        elevation: 3,
        margin: EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mealType,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 5),
              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 140,
                  child: Divider(color: Color(0xFFF0753C), thickness: 1),
                ),
              ),

              // List of food items
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Image.asset('logos/arrow.png', width: 24, height: 24),
                          SizedBox(width: 8.0),
                          Text(
                            items[index],
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Spacer(),
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle,
                              size: 24,
                              color: Color(0xFFF0753C),
                            ),
                            onPressed: () async {
                              await db.removeItem(day, mealType, items[index]);
                              setState(() {}); // Refresh UI
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              // Add Item Section (Fixed)
              Row(
                children: [
                  // Fix TextField taking too much space
                  Expanded(
                    child: TextField(
                      controller: addItemInput,
                      decoration: InputDecoration(
                        labelText: 'Add Item',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical:8, horizontal: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Add Button
                  IconButton(
                    icon: const Icon(
                      Icons.add_circle,
                      size: 24,
                      color: Color(0xFFF0753C),
                    ),
                    onPressed: () async {
                      if (addItemInput.text.isNotEmpty) {
                        await db.addItem(day, mealType, addItemInput.text);
                        setState(() {}); // Refresh UI
                        addItemInput.clear();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
