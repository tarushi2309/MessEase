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
  int selectedIndex = 0;
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWide = constraints.maxWidth > 800;
          // Use SingleChildScrollView to make the whole page scrollable vertically
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSidebar(context, vertical: true),
                        Expanded(child: _buildMainContentArea(context)),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSidebar(context, vertical: false),
                        _buildMainContentArea(context),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, {required bool vertical}) {
    if (vertical) {
      // Desktop/tablet: vertical sidebar
      return Container(
        width: 180,
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
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
                          style: const TextStyle(
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
      );
    } else {
      // Mobile: horizontal scrollable days
      return Container(
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
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12),
                child: Text(
                  "Days",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
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
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      border: selectedIndex == index
                          ? Border.all(color: Colors.black, width: 1)
                          : null,
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          'logos/${days[index].toLowerCase()}.png',
                          width: 24,
                          height: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          days[index],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildMainContentArea(BuildContext context) {
    return Container(
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
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return snapshot.data ?? const Center(child: Text('No data'));
          }
        },
      ),
    );
  }

  Future<Widget> _buildMainContent(String day) async {
    return FutureBuilder<MessMenuModel?>(
      future: db.getMenu(),
      builder: (context, menuSnapshot) {
        if (menuSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (menuSnapshot.hasError) {
          return Center(child: Text('Error: ${menuSnapshot.error}'));
        }

        MessMenuModel messMenu = menuSnapshot.data ?? MessMenuModel(menu: {});
        Map<String, List<String>> menuForDay =
            messMenu.menu[day] ?? {'Breakfast': [], 'Lunch': [], 'Dinner': []};

        final List<String> mealTypes = ['Breakfast', 'Lunch', 'Dinner'];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'MESS MENU',
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 24),
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                int columnCount = 1;
                if (constraints.maxWidth > 800) {
                  columnCount = 3;
                } else if (constraints.maxWidth > 500) {
                  columnCount = 2;
                }
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columnCount,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: mealTypes.length,
                  itemBuilder: (context, index) {
                    String mealType = mealTypes[index];
                    return _buildMealCard(
                      mealType,
                      menuForDay[mealType] ?? [],
                      day,
                    );
                  },
                );
              },
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
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mealType,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset('logos/arrow.png', width: 24, height: 24),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            items[index],
                            style: const TextStyle(
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
                            setState(() {});
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
                    decoration: const InputDecoration(
                      labelText: 'Add Item',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 8),
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
                      setState(() {});
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
