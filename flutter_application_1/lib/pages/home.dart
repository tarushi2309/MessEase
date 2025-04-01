
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/user_provider.dart';
import 'package:flutter_application_1/pages/messmenu.dart';
import 'package:flutter_application_1/pages/rebate_history.dart';
import 'package:flutter_application_1/pages/rebateform.dart';
import 'package:flutter_application_1/pages/user.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/footer.dart';
import 'package:flutter_application_1/models/mess_menu.dart'; // Assuming you have this model defined

class HomeScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, List<String>> todayMenu = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMenu();
  }

  void fetchMenu() async {
  String today = getTodayDay(); // Get today's day
  try {
    // Fetch the Firestore document
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('mess_menu')
        .doc('current_menu')
        .get();

    if (doc.exists) {
      // Convert the document data to a Map
      var menuData = doc.data() as Map<String, dynamic>;

      // Ensure the 'menu' field is properly handled
      if (menuData.containsKey('menu')) {
        var menuMap = menuData['menu'] as Map<String, dynamic>;
        print("menuMap: $menuMap");

        // Ensure that the day's menu is a List<String>
        if (menuMap.containsKey(today)) {
          var dailyMenu = menuMap[today] as Map<String, dynamic>;

        // Extract each meal type (Breakfast, Lunch, Dinner)
        setState(() {
          todayMenu = {
            "Breakfast": List<String>.from(dailyMenu['Breakfast'] ?? []),
            "Lunch": List<String>.from(dailyMenu['Lunch'] ?? []),
            "Dinner": List<String>.from(dailyMenu['Dinner'] ?? []),
          };
          isLoading = false;
        });
      } else {
        setState(() {
          todayMenu = {}; // No menu for today in Firestore
          isLoading = false;
        });
      }
    
      }
    }
  } catch (e) {
    print("Error fetching menu: $e");
    setState(() {
      isLoading = false;
    });
  }
}



  // Get today's day in short format (Mon, Tue, etc.)
  String getTodayDay() {
    List<String> shortDays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
    DateTime now = DateTime.now();
    return shortDays[now.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    String? uid = Provider.of<UserProvider>(context).uid;
    print("\nuser is : $uid");

    return Scaffold(
      key: widget.scaffoldKey,
      backgroundColor: Colors.white,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
          isLoading
              ? Center(child: CircularProgressIndicator())
              : todayMenu.isEmpty
                  ? Text("No menu available today", style: TextStyle(fontSize: 18))
                  : _buildMenuAccordion(),
          const SizedBox(height: 10),
          _buildAddOns(),
        ],
      ),
    );
  }

  // Add On section for today’s menu
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

  Widget _buildMenuAccordion() {
    return Column(
      children: [
        _buildMenuTile(
          title: "Breakfast",
          icon: Icons.free_breakfast,
          bgColor: const Color(0xFFFFEBE0),
          items: List<String>.from(todayMenu['Breakfast'] ?? []),
        ),
        _buildMenuTile(
          title: "Lunch",
          icon: Icons.lunch_dining,
          bgColor: const Color(0xFFFFEBE0),
          items: List<String>.from(todayMenu['Lunch'] ?? []),
        ),
        _buildMenuTile(
          title: "Dinner",
          icon: Icons.dinner_dining,
          bgColor: const Color(0xFFFFEBE0),
          items: List<String>.from(todayMenu['Dinner'] ?? []),
        ),
      ],
    );
  }

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

  Widget _buildDrawer(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      child: Drawer(
        backgroundColor: Colors.white,
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

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFF0753C)),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }

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
              widget.scaffoldKey.currentState?.openDrawer();
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
