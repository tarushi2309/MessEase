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

  DatabaseModel db = DatabaseModel();

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
                          border: selectedIndex == index
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
                              const SizedBox(width: 10),
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

          // Main Content Area with responsive GridView
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

        MessMenuModel messMenu = menuSnapshot.data ?? MessMenuModel(menu: {});
        Map<String, List<String>> menuForDay =
            messMenu.menu[day] ?? {'Breakfast': [], 'Lunch': [], 'Dinner': []};

        if (messMenu.menu.containsKey(day)) {
          menuForDay = messMenu.menu[day]!;
        }

        // List of meal types to display
        final List<String> mealTypes = ['Breakfast', 'Lunch', 'Dinner'];

        return Column(
          children: [
            Text(
              'MESS MENU',
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 24),
            ),
            const SizedBox(height: 20),
            Expanded(
              // Using LayoutBuilder to determine column count based on width
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Determine column count based on available width
                  int columnCount = 1; // Default to 1 column
                  if (constraints.maxWidth > 800) {
                    columnCount = 3; // 3 columns for wide screens
                  } else if (constraints.maxWidth > 600) {
                    columnCount = 2; // 2 columns for medium screens
                  }
                  
                  // Using GridView for responsive layout
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columnCount,
                      childAspectRatio: 0.85, // Adjust based on your content
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: mealTypes.length,
                    itemBuilder: (context, index) {
                      String mealType = mealTypes[index];
                      return _buildMealCard(
                        mealType, 
                        menuForDay[mealType] ?? [], 
                        day
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMealCard(String mealType, List<String> items, String day) {
    TextEditingController addItemInput = TextEditingController();

    return Card(
      color: Colors.white,
      elevation: 3,
      margin: EdgeInsets.all(10),
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
            // List of food items - makes text wrap and list scrollable
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset('logos/arrow.png', width: 24, height: 24),
                        SizedBox(width: 8.0),
                        // Make text wrap for long item names
                        Expanded(
                          child: Text(
                            items[index],
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            softWrap: true,
                            overflow: TextOverflow.visible,
                          ),
                        ),
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
            // Add Item Section
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: addItemInput,
                    decoration: InputDecoration(
                      labelText: 'Add Item',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
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
    );
  }
}
