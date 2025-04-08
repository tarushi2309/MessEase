import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:webapp/components/header_manager.dart';
import 'package:webapp/models/addon.dart';
import 'package:webapp/models/announcement.dart';
import 'package:webapp/models/mess_menu.dart';
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
    return FutureBuilder<MessMenuModel?>(
      future: db.getMenu(),
      builder: (context, menusnapshot) {
        if (menusnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (menusnapshot.hasError) {
          return Center(child: Text("Error: ${menusnapshot.error}"));
        }
        String today = DateFormat('EEEE').format(DateTime.now());
        MessMenuModel messMenu = menusnapshot.data ?? MessMenuModel(menu: {});
        Map<String, List<String>> menuForDay = messMenu.menu[today] ??
            {'Breakfast': [], 'Lunch': [], 'Dinner': []};

        if (messMenu.menu.containsKey(today)) {
          menuForDay = messMenu.menu[today]!;
        }
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Header(currentPage: 'Home'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 35.0,
            ),
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
                    Expanded(flex: 3, child: _buildAddOnsSection()),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 4,
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
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildAnnouncementsSection(),
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
                _buildMealSection("Breakfast", menuForDay['Breakfast']!),
                _buildMealSection("Lunch", menuForDay['Lunch']!),
                _buildMealSection("Dinner", menuForDay['Dinner']!),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMealSection(String title, List<String> items) {
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
              itemCount: items.length,
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
                      items[index],
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

  Widget _buildAddOnsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text(
              "Today's Add Ons",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle, size: 24),
              onPressed: () => _showAddItemDialog(context, "Add-On"),
            ),
            IconButton(
              icon: const Icon(Icons.remove_circle, size: 24),
              onPressed: () => _showRemoveItemDialog(context, "Add-On"),
            ),
          ],
        ),
        FutureBuilder<List<AddonModel>>(
          future: db.fetchSelectedAddons(), // Call function from database.dart
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 50),
                  Center(child: Text("No add-ons available")),
                  
      ]);
            }

            List<AddonModel> addons = snapshot.data!;

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: addons.map((addon) {
                  return Column(
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
                        '${addon.name} -  ₹ ${addon.price}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAnnouncementsSection() {
  return Container(
    height: 150,
    width: double.infinity,
    margin: const EdgeInsets.only(top: 4),
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(10),
    ),
    child: FutureBuilder<List<AnnouncementModel>>(
      future: db.fetchAnnouncements(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No announcements available"));
        }

        // Get only today's announcements
        DateTime today = DateTime.now();
        List<AnnouncementModel> announcements = snapshot.data!
            .where((a) {
              try {
                DateTime announcementDate = DateTime.parse(a.date);
                return announcementDate.year == today.year &&
                    announcementDate.month == today.month &&
                    announcementDate.day == today.day;
              } catch (e) {
                return false;
              }
            })
            .toList()
            .reversed
            .toList();

        if (announcements.isEmpty) {
          return const Center(child: Text("No announcements for today"));
        }

        return Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: announcements.map((doc) {
                String announcementText = doc.announcement;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("➤", style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(announcementText)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
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

                            DatabaseModel db = DatabaseModel(
                              uid: FirebaseAuth.instance.currentUser!.uid,
                            );
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

  void _showRemoveItemDialog(BuildContext context, String title) {
    TextEditingController nameController = TextEditingController();

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
                    'Remove $title',
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

                            DatabaseModel db = DatabaseModel(
                              uid: FirebaseAuth.instance.currentUser!.uid,
                            );
                            String message = await db.removeAddon(name);
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
                          child: const Text('Remove'),
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
}
