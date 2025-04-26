import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:webapp/components/header_student.dart';
import 'package:webapp/components/user_provider.dart';
import 'package:webapp/models/addon.dart';
import 'package:webapp/models/announcement.dart';
import 'package:webapp/models/mess_menu.dart';
import 'package:webapp/services/database.dart';

import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:webapp/models/feedback.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseModel db = DatabaseModel();
  String? uid;
  String messName = "";
  bool isLoading = true;
  bool isError = false;
  String? errorMessage;
  String messNameAnnouncement = "";
  String formAnnouncement = "";
  Future<List<AnnouncementModel>>? announcementFuture;
  final String _imgbbApiKey = "321e92bce52209a8c6c4f1271bbec58f";

  @override
  void initState() {
    super.initState();
    // Do not fetch UID here; wait for the provider in build.
  }

  Future<void> _initFetch(String uid) async {
    // Wait for the user name to be fetched so that messName is set properly
    await fetchUserName(uid);
    setState(() {
      announcementFuture = _fetchAnnouncementHistory(messNameAnnouncement);
    });
  }

  Future<void> fetchUserName(String uid) async {
    try {
      DocumentSnapshot studentDoc = await FirebaseFirestore.instance
          .collection('students')
          .doc(uid)
          .get();
      if (studentDoc.exists) {
        messName = studentDoc['mess'];
        messNameAnnouncement =
            messName[0].toUpperCase() + messName.substring(1).toLowerCase();
      } else {
        print("Student not found");
      }
    } catch (e) {
      print("Error fetching user: $e");
    }
  }

  Future<List<AnnouncementModel>> _fetchAnnouncementHistory(
      String messId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('announcements')
          .where('mess', arrayContains: messId)
          .get();

      final List<AnnouncementModel> loadedAnnouncements = snapshot.docs
          .map((doc) =>
              AnnouncementModel.fromJson(doc.data() as Map<String, dynamic>))
          .where((announcement) {
        final announcementDate = DateTime.parse(announcement.date);
        return announcementDate.isAfter(startOfDay) &&
            announcementDate.isBefore(startOfDay.add(const Duration(days: 1)));
      }).toList();
      //print(loadedAnnouncements);
      return loadedAnnouncements;
    } catch (e) {
      print("Error fetching announcements: $e");
      throw Exception("Failed to load the announcements.");
    }
  }

  Future<void> addHostelLeavingData(
      BuildContext context, DateTime selectedDate) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;

      if (uid == null) {
        throw Exception("User not logged in");
      }

      DocumentSnapshot studentDoc = await FirebaseFirestore.instance
          .collection('students')
          .doc(uid)
          .get();

      if (!studentDoc.exists) {
        throw Exception("Student data not found");
      }

      String name = studentDoc['name'];
      String entryNum = studentDoc['entryNumber'];
      String messName = studentDoc['mess'];
      print("Mess Name: $messName");

      int numOfDays = 0;
      if (selectedDate.month == 11 || selectedDate.month == 12) {
        DateTime endDate = DateTime(selectedDate.year, 12, 31);
        numOfDays = endDate.difference(selectedDate).inDays + 1;
      } else if (selectedDate.month == 4 || selectedDate.month == 5) {
        DateTime endDate = DateTime(selectedDate.year, 5, 31);
        numOfDays = endDate.difference(selectedDate).inDays + 1;
      }

      await FirebaseFirestore.instance.collection('hostel_leaving_data').add({
        'uid': uid,
        'name': name,
        'entryNumber': entryNum,
        'mess': messName,
        'selectedDate': selectedDate,
        'numberOfRebateDaysAdded': numOfDays,
        'timestamp': FieldValue.serverTimestamp(),
      });

      final querySnapshot = await FirebaseFirestore.instance
          .collection('students')
          .where('uid', isEqualTo: uid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final docId = doc.id;

        int currentHostelLeavingDays =
            (doc.data()['hostel_leaving_days'] ?? 0) as int;
        int currentRebateDays = (doc.data()['days_of_rebate'] ?? 0) as int;
        int updatedHostelLeavingDays =
            currentHostelLeavingDays + currentRebateDays;
        int refundAmount = updatedHostelLeavingDays * 133;

        // Now update
        await FirebaseFirestore.instance
            .collection('students')
            .doc(docId)
            .update({
          'hostel_leaving_days': updatedHostelLeavingDays,
          'refund': refundAmount,
        });

        print('Hostel leaving days and refund updated successfully!');
      } else {
        print('No student found with UID: $uid');
      }

      print("Hostel leaving data added successfully");
    } catch (e) {
      print("Error adding hostel leaving data: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit leaving date: $e")),
      );
    }
  }

  void _showLeavingDatePopup(BuildContext context, String messName) async {
    final DateTime today = DateTime.now();
    final DateTime firstDate = DateTime(today.year, today.month, today.day);

    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: firstDate,
      firstDate: firstDate,
      lastDate: today.add(Duration(days: 60)),
      helpText: 'Select Leaving Date',
      confirmText: 'Submit',
      cancelText: 'Cancel',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.deepPurple,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      print("Student selected date: ${selectedDate.toString()}");
      await addHostelLeavingData(context, selectedDate);

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Leaving Date Confirmed'),
          content: Text(
              "You're set to leave on ${selectedDate.day}/${selectedDate.month}/${selectedDate.year} from $messName mess. Please submit your messId card to the manager"),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No date selected.")),
      );
    }
  }

  // add feedback to the firestore
  Future<void> submitFeedback({
    required String uid,
    required String text,
    File? image,
    required String mess,
    required String meal,
  }) async {
    String? imageUrl;
    print("Submitting feedback: $text");

    try {
      // Upload image to Firebase Storage if available
      if (image != null) {
        final Dio dio = Dio();
        final formData = FormData.fromMap({
          'key': _imgbbApiKey,
          'image': await MultipartFile.fromFile(image.path),
        });

        final response = await dio.post(
          "https://api.imgbb.com/1/upload",
          data: formData,
        );

        print("Response: ${response.statusCode}");

        if (response.statusCode == 200) {
          imageUrl = response.data['data']['url'];
        }
      }
      // Create feedback model
      FeedbackModel feedback = FeedbackModel(
        uid: uid,
        text: text,
        imageUrl: imageUrl,
        mess: mess,
        timestamp: DateTime.now(),
        meal: meal,
      );

      // Add to Firestore
      await FirebaseFirestore.instance
          .collection('feedback')
          .add(feedback.toJson());
      print("Feedback successfully submitted to Firestore");
    } catch (e) {
      print("Error submitting feedback: $e");
      rethrow;
    }
  }

  bool _isFeedbackAllowed(String mealType) {
    final now = DateTime.now();
    switch (mealType) {
      case 'Breakfast':
        return now.hour > 7 || (now.hour == 7 && now.minute >= 45);
      case 'Lunch':
        return now.hour > 12 || (now.hour == 12 && now.minute >= 45);
      case 'Dinner':
        return now.hour > 19 || (now.hour == 19 && now.minute >= 45);
      default:
        return false;
    }
  }

  void _showFeedbackDialog(BuildContext context, String mealType, String uid) {
    TextEditingController feedbackController = TextEditingController();
    File? selectedImage;
    Uint8List? webImageBytes;
    // feedback form
    final ImagePicker _picker = ImagePicker();

    selectedImage = null;
    webImageBytes = null;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final dialogWidth = constraints.maxWidth * 0.5;
                  return SizedBox(
                    height: 380,
                    width: dialogWidth,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF0753C),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Feedback Form ! Your input matters :)',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(12),
                            child: kIsWeb
                                ? (webImageBytes != null
                                    ? Stack(
                                        alignment: Alignment.topRight,
                                        children: [
                                          Image.memory(webImageBytes!,
                                              height: 200),
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: IconButton(
                                              icon: Icon(Icons.close,
                                                  color: Color(0xFFF0753C)),
                                              onPressed: () {
                                                setState(
                                                    () => webImageBytes = null);
                                              },
                                            ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox.shrink())
                                : (selectedImage != null
                                    ? Stack(
                                        alignment: Alignment.topRight,
                                        children: [
                                          Image.file(selectedImage!,
                                              height: 200),
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: IconButton(
                                              icon: Icon(Icons.close,
                                                  color: Color(0xFFF0753C)),
                                              onPressed: () {
                                                setState(
                                                    () => selectedImage = null);
                                              },
                                            ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox.shrink()),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border(
                                top: BorderSide(color: Colors.grey.shade300)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: feedbackController,
                                  decoration: const InputDecoration(
                                    hintText: 'Type your message here',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: Color(0xFFF0753C),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                ),
                                child: const Text("Attach",
                                    style: TextStyle(color: Colors.white)),
                                onPressed: () async {
                                  if (kIsWeb) {
                                    Uint8List? bytes =
                                        await ImagePickerWeb.getImageAsBytes();
                                    if (bytes != null) {
                                      setState(() => webImageBytes = bytes);
                                    }
                                  } else {
                                    final XFile? image = await _picker
                                        .pickImage(source: ImageSource.gallery);
                                    if (image != null) {
                                      setState(() =>
                                          selectedImage = File(image.path));
                                    }
                                  }
                                },
                              ),
                              const SizedBox(width: 4),
                              TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: Color(0xFFF0753C),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                ),
                                child: const Text("Send",
                                    style: TextStyle(color: Colors.white)),
                                onPressed: () async {
                                  print("feedback: $uid");
                                  try {
                                    await submitFeedback(
                                      uid: uid,
                                      text: feedbackController.text.trim(),
                                      image: kIsWeb ? null : selectedImage,
                                      meal: mealType,
                                      mess: messName,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Feedback submitted!')),
                                    );
                                    Navigator.of(context).pop();
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Failed to submit feedback')),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Future<bool> checkForm(BuildContext context, String? uid) async {
    if (uid == null) return false;
    bool closed = false;
    final doc = await FirebaseFirestore.instance
        .collection('hostel_leaving_data')
        .where('uid', isEqualTo: uid)
        .get();

    String mess = "";
    if (doc.docs.isNotEmpty) {
      mess = doc.docs[0]['mess'];
      formAnnouncement = "You've already submitted the hostel leaving form.";
      return true;
    } else {
      final studentdoc = await FirebaseFirestore.instance
          .collection('students')
          .where('uid', isEqualTo: uid)
          .get();

      if (studentdoc.docs.isNotEmpty) {
        mess = studentdoc.docs[0]['mess'];
      }
    }
    mess = mess[0].toUpperCase() + mess.substring(1);

    final data = await FirebaseFirestore.instance
        .collection('hostel_leaving')
        .doc(mess)
        .get();

    if (data.exists) {
      closed = !data['isReleased'];
      //isReleased = true - form exists
      if (closed == true) {
        formAnnouncement =
            "This form has been closed. Please contact BOHA for any discrepancy.";
        return true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final uid = userProvider.uid;
        print("Current UID: $uid");
        if (uid == null) {
          // Show loading or login prompt until UID is available
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // Only initialize data when UID changes
        if (announcementFuture == null) {
          print("Initializing fetch for UID: $uid");
          _initFetch(uid);
        }
        return FutureBuilder(
          future: db.getMenu(),
          builder: (context, menusnapshot) {
            if (menusnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (menusnapshot.hasError) {
              return Center(child: Text("Error: ${menusnapshot.error}"));
            }
            final String today = DateFormat('EEEE').format(DateTime.now());
            final MessMenuModel messMenu =
                menusnapshot.data ?? MessMenuModel(menu: {});
            Map<String, List<String>> menuForDay = messMenu.menu[today] ??
                {'Breakfast': [], 'Lunch': [], 'Dinner': []};

            return Scaffold(
              backgroundColor: Colors.white,
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Header(currentPage: 'Home'),
              ),
              body: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 35),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${messNameAnnouncement} mess',
                        style: TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    LayoutBuilder(builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 600;
                      if (isNarrow) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildAddOnsSection(),
                            const SizedBox(height: 24),
                            _buildAnnouncementsBlock(uid),
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: _buildAddOnsSection()),
                          const SizedBox(width: 16),
                          Expanded(
                              flex: 4, child: _buildAnnouncementsBlock(uid)),
                        ],
                      );
                    }),
                    const SizedBox(height: 16),
                    const Text("Today's Menu",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    _buildMealSection(
                        "Breakfast", menuForDay['Breakfast']!, uid),
                    _buildMealSection("Lunch", menuForDay['Lunch']!, uid),
                    _buildMealSection("Dinner", menuForDay['Dinner']!, uid),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMealSection(String title, List<String> items, String? uid) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.feedback, color: Color(0xFFF0753C)),
                  onPressed: () {
                    if (!_isFeedbackAllowed(title)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('Feedback for $title hasn\'t opened yet'),
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.only(bottom: 70),
                        ),
                      );
                      return;
                    }
                    _showFeedbackDialog(context, title, uid!);
                  },
                  tooltip: 'Give Feedback',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              itemBuilder: (context, index) => Column(
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: const DecorationImage(
                        image: AssetImage('addon.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(items[index],
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500)),
                ],
              ),
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
          children: [
            const Text("Today's Add Ons",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
        FutureBuilder<List<AddonModel>>(
          future: db.fetchAddons(messName),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No add‑ons available"));
            }

            final addons = snapshot.data!;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: addons
                    .map((addon) => Column(
                          children: [
                            Container(
                              width: 150,
                              height: 150,
                              margin: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: const DecorationImage(
                                  image: AssetImage('addon.jpg'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Text('${addon.name}  –  ₹${addon.price}',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500)),
                          ],
                        ))
                    .toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAnnouncementsBlock(String? uid) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Announcements",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildAnnouncementsSection(uid),
        ],
      );

  Widget _buildAnnouncementsSection(String? uid) {
    return Container(
      height: 150,
      width: double.infinity,
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: FutureBuilder<List<AnnouncementModel>>(
        future: announcementFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final announcements = snapshot.data ?? [];
          if (announcements.isEmpty) {
            return const Center(child: Text("No announcements found"));
          }
          return Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: announcements.map(
                  (a) {
                    final text = a.announcement;
                    final isClickable = text
                        .toLowerCase()
                        .contains("hostel leaving form is now live");

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('➤', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: isClickable
                                ? GestureDetector(
                                    onTap: () async {
                                      try {
                                        bool alreadySubmitted =
                                            await checkForm(context, uid);
                                        if (alreadySubmitted) {
                                          showDialog(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                              title: Text("Sorry!"),
                                              content: Text(formAnnouncement),
                                              actions: [
                                                TextButton(
                                                  child: Text("OK"),
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(),
                                                ),
                                              ],
                                            ),
                                          );
                                        } else {
                                          _showLeavingDatePopup(
                                              context, messName);
                                        }
                                      } catch (e) {
                                        print("Error in link");
                                      }
                                    },
                                    child: Text(
                                      text,
                                      style: const TextStyle(
                                        color: Colors.blueAccent,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  )
                                : Text(text),
                          ),
                        ],
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
