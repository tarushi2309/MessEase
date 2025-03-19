import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:webapp/components/header.dart';
import 'package:webapp/models/addon.dart';
import 'package:webapp/services/database.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DatabaseModel db = DatabaseModel(uid: FirebaseAuth.instance.currentUser!.uid);




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Header(currentPage: 'Home'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 35.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Konark Mess',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text(
                            "Today's Add Ons",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle, size: 24),
                            onPressed:
                                () => _showAddItemDialog(context, "Add-On"),
                          ),
                        ],
                      ),
                      Row(
                        children: List.generate(
                          2,
                          (index) => Column(
                            children: [
                              Container(
                                width: 150,
                                height: 150,
                                margin: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    image: AssetImage('addon.jpg'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Text(
                                'Addon ${index + 1}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Announcements",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle, size: 24),
                            onPressed: () => _showAnnouncementDialog(context),
                          ),
                        ],
                      ),
                      Container(
                        height: 150,
                        margin: const EdgeInsets.only(top: 20),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Scrollbar(
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: List.generate(
                                4,
                                (index) => _generateAnnouncement(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "Today's Menu",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            _buildMealSection("Breakfast"),
            _buildMealSection("Lunch"),
            _buildMealSection("Dinner"),
          ],
        ),
      ),
    );
  }

  Widget _buildMealSection(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200, // Make sure height is large enough
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: AssetImage('addon.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$title Item ${index + 1}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
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

  Widget _generateAnnouncement() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Text(
        "Lorem Ipsum is simply dummy text of the printing and typesetting industry. "
        "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s.",
      ),
    );
  }

  void _showAddItemDialog(BuildContext context, String title) {
    TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add $title',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Item Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: priceController,
                    decoration: InputDecoration(
                      labelText: 'Price',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              Colors.grey[100],
                            ),
                            foregroundColor: MaterialStateProperty.all(
                              Colors.black,
                            ),
                            padding: MaterialStateProperty.all(
                              const EdgeInsets.all(8),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () async {
                            String name = nameController.text.trim();
                            String price = priceController.text.trim();
                            
                            DatabaseModel db = DatabaseModel(uid: FirebaseAuth.instance.currentUser!.uid);
                            String message = await db.addAddon(name, price);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(message),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                            Navigator.pop(context);
                            setState(() {
                              // Refresh the UI
                            });
                          },
                          child: const Text('Add'),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              Color(0xFFF0753C),
                            ),
                            foregroundColor: MaterialStateProperty.all(
                              Colors.white,
                            ),
                            padding: MaterialStateProperty.all(
                              const EdgeInsets.all(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAnnouncementDialog(BuildContext context) {
    TextEditingController announcementController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width:
                MediaQuery.of(context).size.width * 0.5, // 60% of screen width
            height: 250, // Adjust height as needed
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Add Announcement',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: TextField(
                    controller: announcementController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your announcement...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: null, // Allows multi-line input
                    keyboardType: TextInputType.multiline,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: () {
                        String announcementText =
                            announcementController.text.trim();
                        if (announcementText.isNotEmpty) {
                          print("Announcement Saved: $announcementText");
                          Navigator.pop(context);
                        }
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFF0753C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
