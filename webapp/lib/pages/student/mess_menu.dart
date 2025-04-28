import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:webapp/components/header_student.dart';
import 'package:webapp/models/mess_menu.dart';
import 'package:webapp/services/database.dart';

class MessMenuStudentPage extends StatefulWidget {
  const MessMenuStudentPage({super.key});

  @override
  State<MessMenuStudentPage> createState() => _MessMenuStudentPageState();
}

class _MessMenuStudentPageState extends State<MessMenuStudentPage> {
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
    final screenWidth = MediaQuery.of(context).size.width;
    final useColumnLayout = screenWidth < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Header(currentPage: 'Mess Menu'),
      ),
      body: useColumnLayout 
        ? _buildColumnLayout()
        : _buildRowLayout(),
    );
  }

  // Column layout for small screens
  Widget _buildColumnLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Days selection in a horizontal list
          Container(
            height: 100,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: days.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      border: selectedIndex == index
                          ? Border.all(color: Colors.black, width: 1)
                          : null,
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 2,
                          spreadRadius: 0.5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'logos/${days[index].toLowerCase()}.png',
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          days[index],
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Main content
          Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(15),
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
                  return snapshot.data ??
                      const Center(child: Text('No data'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Original row layout with scrollable left column
  Widget _buildRowLayout() {
    return Row(
      children: [
        // Sidebar with scrolling
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
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
            // Make Days column scrollable
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      "Days",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
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
                            horizontal: 15, vertical: 10),
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
                                    color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 20), // Bottom padding
                ],
              ),
            ),
          ),
        ),

        // Main Content
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
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return snapshot.data ??
                      const Center(child: Text('No data'));
                }
              },
            ),
          ),
        ),
      ],
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

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                _buildMealSection('Breakfast', menuForDay['Breakfast'] ?? []),
                _buildMealSection('Lunch', menuForDay['Lunch'] ?? []),
                _buildMealSection('Dinner', menuForDay['Dinner'] ?? []),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMealSection(String title, List<String> items) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = screenWidth < 600 ? 100.0 : 120.0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: items.isEmpty ? 1 : items.length,
              itemBuilder: (context, index) {
                if (items.isEmpty) {
                  return Center(
                    child: Container(
                      width: screenWidth - 100,
                      alignment: Alignment.center,
                      child: Text('No items available',
                        style: TextStyle(fontSize: 16)),
                    ),
                  );
                }
                
                return Column(
                  children: [
                    Container(
                      width: itemWidth,
                      height: itemWidth,
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: const DecorationImage(
                          image: AssetImage('addon.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: itemWidth,
                      child: Text(
                        items[index],
                        style: const TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.w500
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}