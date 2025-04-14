import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webapp/models/announcement.dart';
import 'package:webapp/components/header_boha.dart';
import 'package:webapp/services/database.dart';

class AnnouncementPage extends StatefulWidget {
  const AnnouncementPage({super.key});

  @override
  _AnnouncementPageState createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends State<AnnouncementPage> {
  // Fetch announcements from Firestore
  late Future<List<AnnouncementModel>> _announcements;

  DatabaseModel db = DatabaseModel();

  // Fetch announcements when this screen is accessed
  @override
  void initState() {
    super.initState();
    _announcements = db.fetchAnnouncements();
  }

  // Add announcements
  void _showAddAnnouncementDialog() {
    TextEditingController announcementController = TextEditingController();
    List<String> messes = ['Konark', 'Anusha', 'Ideal'];

    List<String> selectedMesses = [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              title: const Text("Add Announcement"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: announcementController,
                      decoration: const InputDecoration(labelText: "Announcement"),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Select Mess:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Column(
                      children: messes.map((messName) {
                        return CheckboxListTile(
                          title: Text(messName),
                          value: selectedMesses.contains(messName),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                selectedMesses.add(messName);
                              } else {
                                selectedMesses.remove(messName);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  child: const Text("Submit"),
                  onPressed: () async {
                    if (announcementController.text.isEmpty || selectedMesses.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              "Please fill all fields and select at least one mess"),
                        ),
                      );
                      return;
                    }

                    String currentDateTime = DateTime.now().toString();

                    // Save one document with all selected messes as an array
                    await FirebaseFirestore.instance
                        .collection("announcements")
                        .add({
                      'announcement': announcementController.text,
                      'date': currentDateTime,
                      'mess': selectedMesses, // Store as array
                    });

                    setState(() {
                      _announcements = db.fetchAnnouncements();
                    });

                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const Header(currentPage: 'Announcements'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FutureBuilder<List<AnnouncementModel>>(
                future: _announcements,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Error loading announcements"),
                          Text(
                            snapshot.error.toString(),
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No announcements found"));
                  }

                  List<AnnouncementModel> announcements = snapshot.data!;

                  // Sorting announcements (latest first)
                  announcements.sort((a, b) => b.date.compareTo(a.date));

                  return ListView.builder(
                    itemCount: announcements.length,
                    itemBuilder: (context, index) {
                      AnnouncementModel announcement = announcements[index];

                      return Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: const BorderSide(color: Colors.black, width: 1.5),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Announcement Text
                              Text(
                                announcement.announcement,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              // Date
                              Text(
                                "Date: ${announcement.date}",
                                style: const TextStyle(color: Colors.black),
                              ),
                              // Mess Names
                              Text(
                                "Mess: ${announcement.mess.join(', ')}", // Display array
                                style: const TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddAnnouncementDialog,
        label: const Text(
          "Add Announcement",
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 10,
      ),
    );
  }
}