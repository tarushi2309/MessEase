import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:webapp/components/header_boha.dart';
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
  DatabaseModel db = DatabaseModel( uid: FirebaseAuth.instance.currentUser!.uid);
  
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
}
