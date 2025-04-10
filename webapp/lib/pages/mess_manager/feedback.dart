import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webapp/models/feedback.dart';
import 'package:webapp/components/header_manager.dart';
import '../../components/user_provider.dart';
import 'package:provider/provider.dart';

class FeedbackModelUI {
  final String text;
  final String? imageUrl;
  final DateTime timestamp;
  final String uid;
  final String studentName;
  final String studentEntryNum;
  final String studentEmail;

  FeedbackModelUI({
    required this.text,
    required this.timestamp,
    required this.uid,
    required this.studentName,
    required this.studentEntryNum,
    required this.studentEmail,
    this.imageUrl,
  });
}

class FeedbackMessScreen extends StatefulWidget {
  const FeedbackMessScreen({super.key});

  @override
  _FeedbackMessScreenState createState() => _FeedbackMessScreenState();
}

class _FeedbackMessScreenState extends State<FeedbackMessScreen> {
  late Future<List<FeedbackModelUI>> _feedbacks;
  String? uid;
  String messName = "";

  @override
  void initState() {
    super.initState();
    uid = Provider.of<UserProvider>(context, listen: false).uid;
    print("UID: $uid");
    fetchUserNameAndFeedbacks(); // Call the new function to chain fetches
  }

  Future<void> fetchUserNameAndFeedbacks() async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('user').doc(uid).get();

      if (userDoc.exists) {
        messName = userDoc['name'];
        print("Mess name: $messName");

        // Once messName is fetched, fetch feedbacks and set state
        setState(() {
          _feedbacks = fetchFeedbacks(messName);
        });
      } else {
        print("User document not found");
      }
    } catch (e) {
      print("Error fetching user/mess name: $e");
    }
  }

  Future<List<FeedbackModelUI>> fetchFeedbacks(String messName) async {
    final List<FeedbackModelUI> feedbackList = [];
    final DateTime now = DateTime.now();
    final DateTime oneMonthAgo = DateTime(now.year, now.month - 1, now.day);

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("feedback")
        .where('mess', isEqualTo: messName)
        .orderBy('timestamp', descending: true)
        .get();

    for (QueryDocumentSnapshot feedbackDoc in querySnapshot.docs) {
      final data = feedbackDoc.data() as Map<String, dynamic>;

      final String uid = data['uid'];
      print("debugging the feedbacks");
      print(uid);
      final String text = data['text'];
      final String? imageUrl = data['imageUrl'];
      final String timestampStr = data['timestamp'];

      final DateTime timestamp = DateTime.parse(timestampStr);

      if (timestamp.isAfter(oneMonthAgo)) {
        print("Entering in month range");
        DocumentSnapshot studentSnapshot = await FirebaseFirestore.instance
            .collection('students')
            .doc(uid)
            .get();

        final studentDataRaw = studentSnapshot.data();

        if (studentDataRaw == null) {
          print("got null data");
          continue;
        }

        final studentData = studentDataRaw as Map<String, dynamic>;

        final String studentName = studentData['name'] ?? 'Unknown';
        final String studentEntryNum = studentData['entryNumber'] ?? 'Unknown';
        final String studentEmail = studentData['email'] ?? 'Unknown';

        feedbackList.add(
          FeedbackModelUI(
            text: text,
            timestamp: timestamp,
            uid: uid,
            studentName: studentName,
            studentEntryNum: studentEntryNum,
            studentEmail: studentEmail,
            imageUrl: imageUrl,
          ),
        );
        print("added in the list for the uid $uid");
      }
    }

    return feedbackList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const Header(currentPage: 'Feedback'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _feedbacks == null
                  ? const Center(child: CircularProgressIndicator())
                  : FutureBuilder<List<FeedbackModelUI>>(
                      future: _feedbacks,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Error loading feedbacks"),
                                Text(snapshot.error.toString(),
                                    style: const TextStyle(color: Colors.red)),
                              ],
                            ),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(child: Text("No feedback found"));
                        } else {
                          List<FeedbackModelUI> feedbacks = snapshot.data!;
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('Name')),
                                DataColumn(label: Text('Entry No.')),
                                DataColumn(label: Text('Email')),
                                DataColumn(label: Text('Feedback')),
                                DataColumn(label: Text('Image')),
                                DataColumn(label: Text('Timestamp')),
                              ],
                              rows: feedbacks.map((feedback) {
                                return DataRow(cells: [
                                  DataCell(Text(feedback.studentName)),
                                  DataCell(Text(feedback.studentEntryNum)),
                                  DataCell(Text(feedback.studentEmail)),
                                  DataCell(Text(feedback.text)),
                                  DataCell(
                                    feedback.imageUrl != null &&
                                            feedback.imageUrl!.isNotEmpty
                                        ? InkWell(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (_) => AlertDialog(
                                                  content: Image.network(
                                                      feedback.imageUrl!),
                                                ),
                                              );
                                            },
                                            child: const Icon(Icons.image,
                                                color: Colors.blue),
                                          )
                                        : const Text("No image"),
                                  ),
                                  DataCell(Text(
                                      "${feedback.timestamp.day}-${feedback.timestamp.month}-${feedback.timestamp.year} ${feedback.timestamp.hour}:${feedback.timestamp.minute.toString().padLeft(2, '0')}")),
                                ]);
                              }).toList(),
                            ),
                          );
                        }
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
