import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/messmenu.dart';
import 'package:flutter_application_1/pages/rebate_history.dart';
import 'package:flutter_application_1/pages/rebateform.dart';
import 'package:flutter_application_1/pages/user.dart';

//import 'package:flutter_application_1/pages/RebateForm.dart';
import '../components/footer.dart';
import '../pages/user.dart'; // Import Profile Page

class HomeScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  HomeScreen({super.key, User? user});

  @override
Widget build(BuildContext context) {
  return Scaffold(
    key: scaffoldKey,
    drawer: _buildDrawer(context),
    body: Stack(
      children: [
        Column(
          children: [
            _buildHeader(context), // Fixed header
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 15),
                      _buildContent(context), // Scrollable content
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
    bottomNavigationBar: const CustomNavigationBar(),
  );
}

  /// Builds the header section with the background image and custom app bar.
  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/IndianFood.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          height: 200,
          color: Colors.black.withOpacity(0.3),
        ),
        _buildCustomAppBar(context),
      ],
    );
  }


  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              "TODAY'S MENU",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildMenuAccordion(),
          const SizedBox(height: 10),
          _buildAddOns(),
        ],
      ),
    );
  }

  /// Builds the Today's Add-Ons section.
  Widget _buildAddOns() {
    final List<Map<String, String>> addOns = [
      {"image": "assets/addon.jpg", "label": "Gulab Jamun"},
      {"image": "assets/addon.jpg", "label": "Ice Cream"},
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "TODAY'S ADD-ONS",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: addOns.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(4), // Border thickness
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Color(0xFFF0753C), width: 1), // Border color & width
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          item["image"]!,
                          height: 90, // Adjust for proper size
                          width: 90,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item["label"]!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Builds the menu accordion containing Breakfast, Lunch, and Dinner sections.
  Widget _buildMenuAccordion() {
    return Column(
      children: [
        _buildMenuTile(
          title: "Breakfast",
          icon: Icons.free_breakfast,
          bgColor: const Color(0xFFFFEBE0),
          items: ["Poha", "Idli Sambhar", "Paratha", "Tea/Coffee"],
        ),
        _buildMenuTile(
          title: "Lunch",
          icon: Icons.lunch_dining,
          bgColor: const Color(0xFFFFEBE0),
          items: ["Dal Tadka", "Paneer Butter Masala", "Rice", "Roti", "Salad"],
        ),
        _buildMenuTile(
          title: "Dinner",
          icon: Icons.dinner_dining,
          bgColor: const Color(0xFFFFEBE0),
          items: ["Rajma", "Aloo Gobi", "Jeera Rice", "Tandoori Roti"],
        ),
      ],
    );
  }

  /// Builds an individual accordion tile for the menu.
  Widget _buildMenuTile({
    required String title,
    required IconData icon,
    required List<String> items,
    required Color bgColor,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          backgroundColor: bgColor,
          collapsedBackgroundColor: bgColor.withOpacity(0.8),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          leading: Icon(icon, color: const Color(0xFFF0753C), size: 28),
          title: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          children: items
              .map(
                (item) => Padding(
              padding: const EdgeInsets.fromLTRB(16,0,16,16),
              child: Row(
                children: [
                  const Icon(Icons.fastfood, color: Color(0xFFF0753C), size: 20),
                  const SizedBox(width: 10),
                  Text(item, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          )
              .toList(),
        ),
      ),
    );
  }

  /// Builds the custom navigation drawer.
  Widget _buildDrawer(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      child: Drawer(
        child: Column(
          children: [
            SizedBox(height: statusBarHeight),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 5, 5),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Navigation Bar',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
                ),
              ),
            ),
            const Divider(thickness: 2),
            Expanded(
              child: ListView(
                children: [
                  _buildDrawerItem(Icons.receipt_long, 'Rebate Form', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RebateFormPage()),
                    );
                  }),
                  _buildDrawerItem(Icons.restaurant_menu, 'Mess Menu', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MessMenuScreen()),
                    );
                  }),
                  _buildDrawerItem(Icons.history, 'Rebate History', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RebateHistoryScreen()),
                    );
                  }),
                  _buildDrawerItem(Icons.chat, 'Community Chat', () {}),
                  _buildDrawerItem(Icons.home, 'Home', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  }),
                  _buildDrawerItem(Icons.person, 'Profile', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserPage()),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds an individual item for the drawer.
  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFF0753C)),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }

  /// Builds the custom app bar with a menu button, logo, and profile icon.
  Widget _buildCustomAppBar(BuildContext context) {
    return Positioned(
      top: 35,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              scaffoldKey.currentState?.openDrawer();
            },
            icon: const Icon(Icons.menu, color: Colors.white, size: 30),
          ),
          Center(
            child: Image.asset(
              'assets/MessEaseWhite.png',
              height: 50,
              width: 150,
              fit: BoxFit.contain,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white, size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
