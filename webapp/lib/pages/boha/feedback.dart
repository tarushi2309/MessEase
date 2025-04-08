import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webapp/models/feedback.dart';
import 'package:webapp/components/header_boha.dart';

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

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
    late String messName;
    late Future<List<FeedbackModelUI>> _feedbacks;

    @override
    void didChangeDependencies() {
        super.didChangeDependencies();
        final args = ModalRoute.of(context)!.settings.arguments;
        if (args is String) {
            messName = args.toLowerCase();
            print(messName);
        } else {
            messName = "Unknown";
        }
        _feedbacks = fetchFeedbacks(messName);
    }

    /*Future<List<FeedbackModelUI>> fetchFeedbacks(String messName) async {
        final List<FeedbackModelUI> feedbackList = [];
        print("Fetching feedbacks");

        final DateTime now = DateTime.now();
        final DateTime oneMonthAgo = DateTime(now.year, now.month - 1, now.day);

        print(now);
        print(oneMonthAgo);

        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                        .collection("feedback")
                        .where('mess', isEqualTo: messName)
                        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(oneMonthAgo))
                        .orderBy('timestamp', descending: true)
                        .get();

        for (QueryDocumentSnapshot feedbackDoc in querySnapshot.docs){
            final data = feedbackDoc.data() as Map<String, dynamic>;

            final String uid = data['uid'];
            final String text = data['text'];
            final String? imageUrl = data['imageUrl'];
            final DateTime timestamp = DateTime.parse(data['timestamp']);

            // Now fetch student data using uid
            DocumentSnapshot studentSnapshot = await FirebaseFirestore.instance
                .collection('students')
                .doc(uid)
                .get();
            
            DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
                .collection('user')
                .doc(uid)
                .get();
            
            final studentData = studentSnapshot.data() as Map<String, dynamic>;
            final userData = userSnapshot.data() as Map<String, dynamic>;
            
            final String studentName = userData['name'] ?? 'Unknown';
            final String studentEntryNum = studentData['entryNumber'] ?? 'Unknown';
            final String studentEmail = userData['email'] ?? 'Unknown';

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
        }  
        return feedbackList;  
    }*/

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
            final String text = data['text'];
            final String? imageUrl = data['imageUrl'];
            final String timestampStr = data['timestamp'];

            // Parse string to DateTime
            final DateTime timestamp = DateTime.parse(timestampStr);

            // Only add if within last 1 month
            if (timestamp.isAfter(oneMonthAgo)) {
                DocumentSnapshot studentSnapshot = await FirebaseFirestore.instance
                    .collection('students')
                    .doc(uid)
                    .get();

                DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
                    .collection('user')
                    .doc(uid)
                    .get();

                final studentDataRaw = studentSnapshot.data();
                final userDataRaw = userSnapshot.data();

                if (studentDataRaw == null || userDataRaw == null) {
                    continue; 
                }

                final studentData = studentSnapshot.data() as Map<String, dynamic>;
                final userData = userSnapshot.data() as Map<String, dynamic>;

                final String studentName = userData['name'] ?? 'Unknown';
                final String studentEntryNum = studentData['entryNumber'] ?? 'Unknown';
                final String studentEmail = userData['email'] ?? 'Unknown';

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
                // Header remains unchanged
                const Header(currentPage: 'Feedback'),

                // Body containing the committee members list
                Expanded( 
                child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: FutureBuilder<List<FeedbackModelUI>>(
                                future: _feedbacks,
                                builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const Center(child: CircularProgressIndicator());
                                    } else if (snapshot.hasError) {
                                        return Center(
                                            child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                                const Text("Error loading feedbacks"),
                                                Text(snapshot.error.toString(), style: const TextStyle(color: Colors.red)),
                                            ],
                                            ),
                                        );
                                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                        return const Center(child: Text("No feedback found"));
                                    } else{
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
                                                        feedback.imageUrl != null && feedback.imageUrl!.isNotEmpty
                                                            ? InkWell(
                                                                onTap: () {
                                                                    showDialog(
                                                                        context: context,
                                                                        builder: (_) => AlertDialog(
                                                                            content: Image.network(feedback.imageUrl!),
                                                                        ),
                                                                    );
                                                                },
                                                                child: const Icon(Icons.image, color: Colors.blue),
                                                                )
                                                            : const Text("No image"),
                                                        ),
                                                        DataCell(Text(
                                                        "${feedback.timestamp.day}-${feedback.timestamp.month}-${feedback.timestamp.year} ${feedback.timestamp.hour}:${feedback.timestamp.minute.toString().padLeft(2, '0')}",
                                                        )),
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