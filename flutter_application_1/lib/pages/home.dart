
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/user_provider.dart';
import 'package:flutter_application_1/pages/messmenu.dart';
import 'package:flutter_application_1/pages/rebate_history.dart';
import 'package:flutter_application_1/pages/rebateform.dart';
import 'package:flutter_application_1/pages/user.dart';
import 'package:flutter_application_1/models/feedback.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/footer.dart';
import 'package:flutter_application_1/models/mess_menu.dart'; // Assuming you have this model defined
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';



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


  // add feedback to the firestore
  Future<void> submitFeedback({
    required String uid,
    required String text,
    XFile? image,
  }) async {
    String? imageUrl;

    try {
      // Upload image to Firebase Storage if available
      if (image != null) {
        final fileName = path.basename(image.path);
        final storageRef = FirebaseStorage.instance.ref().child('feedback_images/$fileName');
        final uploadTask = await storageRef.putFile(File(image.path));
        imageUrl = await uploadTask.ref.getDownloadURL();
      }
      // Create feedback model
      FeedbackModel feedback = FeedbackModel(
        uid: uid,
        text: text,
        imageUrl: imageUrl,
        timestamp: DateTime.now(),
      );

      // Add to Firestore
      await FirebaseFirestore.instance.collection('feedback').add(feedback.toJson());
      debugPrint("Feedback successfully submitted");
    } catch (e) {
      debugPrint("Error submitting feedback: $e");
      rethrow;
    }
  }


  // feedback form 
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  TextEditingController _feedbackController = TextEditingController();

  void _showFeedbackDialog(BuildContext context, String mealType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Container(
            height: 300,
            width: double.infinity,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Feedback Form ! You input matters :)',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: _selectedImage != null
                        ? Image.file(File(_selectedImage!.path), height: 100)
                        : const Text(''),
                  ),
                ),

                // Bottom Input + Buttons
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.grey.shade300)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _feedbackController,
                          decoration: const InputDecoration(
                            hintText: 'Type your message here',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: const Text("Attach", style: TextStyle(color: Colors.white)),
                        onPressed: () async {
                          final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                          if (image != null) {
                            _selectedImage = image;
                          }
                          Navigator.of(context).pop();
                          _showFeedbackDialog(context, mealType); // Refresh UI
                        },
                      ),
                      const SizedBox(width: 4),
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: const Text("Send", style: TextStyle(color: Colors.white)),

                        onPressed: () async {
                          final uid = Provider.of<UserProvider>(context, listen: false).uid;
                          print("Feedback: ${_feedbackController.text}");
                          print("Image Path: ${_selectedImage?.path}");
                          try {
                            await submitFeedback(
                              uid: uid!,
                              text: _feedbackController.text.trim(),
                              image: _selectedImage,
                            );
                            print("Feedback submitted successfully");
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Feedback submitted!')),
                            );
                            _feedbackController.clear();
                            _selectedImage = null;
                            Navigator.of(context).pop();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Failed to submit feedback')),
                            );
                          }
                        }
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
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
                  : _buildMenuAccordion(context),
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

  Widget _buildMenuAccordion(BuildContext context) {
    return Column(
      children: [
        _buildMenuTile(
          title: "Breakfast",
          icon: Icons.free_breakfast,
          bgColor: const Color(0xFFFFEBE0),
          items: List<String>.from(todayMenu['Breakfast'] ?? []),
          context: context,
        ),
        _buildMenuTile(
          title: "Lunch",
          icon: Icons.lunch_dining,
          bgColor: const Color(0xFFFFEBE0),
          items: List<String>.from(todayMenu['Lunch'] ?? []),
          context: context,
        ),
        _buildMenuTile(
          title: "Dinner",
          icon: Icons.dinner_dining,
          bgColor: const Color(0xFFFFEBE0),
          items: List<String>.from(todayMenu['Dinner'] ?? []),
          context: context,
        ),
      ],
    );
  }

  Widget _buildMenuTile({
    required String title,
    required IconData icon,
    required Color bgColor,
    required List<String> items,
    required BuildContext context,
  }) {
    return Card(
      color: bgColor,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.deepOrange),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.feedback, color: Colors.deepOrange),
              onPressed: () => _showFeedbackDialog(context, title),
              tooltip: 'Give Feedback',
            ),
          ],
        ),
        children: items
            .map((item) => ListTile(
                  title: Text(item),
                ))
            .toList(),
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
