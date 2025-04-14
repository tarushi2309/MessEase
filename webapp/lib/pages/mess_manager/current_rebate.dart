import 'package:flutter/material.dart';
import 'package:webapp/components/header_manager.dart';
import '../../models/rebate.dart';
import '../../models/user.dart';
import '../../services/database.dart';
import '../../components/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class CurrentRebate {
  final DateTime startDate;
  final DateTime endDate;
  final String hostel;
  final String studentId;
  final String entryNumber;
  final String studentName;
  final String req_id;
  final String? url;

  CurrentRebate({
    required this.startDate,
    required this.endDate,
    required this.hostel,
    required this.entryNumber,
    required this.studentName,
    required this.studentId,
    required this.req_id,
    required this.url,
  });
}

class CurrentRequestPage extends StatefulWidget {
  const CurrentRequestPage({super.key});
  @override
  _CurrentRequestsPageState createState() => _CurrentRequestsPageState();
}

class _CurrentRequestsPageState extends State<CurrentRequestPage> {
  bool isLoading = true;
  late DatabaseModel db;
  String? uid;
  String messName = "";
  List<CurrentRebate> Rebates = [];
  List<CurrentRebate> CurrentRebates = [];

  @override
  void initState() {
    super.initState();
    // Fetch uid from provider
    uid = Provider.of<UserProvider>(context, listen: false).uid;
    print(uid);
    fetchUserName();
  }

  // Fetch mess name using uid
  void fetchUserName() async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('user').doc(uid).get();
      if (userDoc.exists) {
        messName = userDoc['name'];
      } else {
        print("User not found");
      }
    } catch (e) {
      print("Error fetching user: $e");
    }
    print(messName);
  }

  String reqId = "";

  Future<List<CurrentRebate>> getCurrentRebates(String messName) async {
    List<CurrentRebate> currentRebates = [];
    QuerySnapshot rebateSnapshot = await FirebaseFirestore.instance
        .collection('rebates')
        .where('mess', isEqualTo: messName)
        .where('status', isEqualTo: 'approve')
        .get();
    for (var doc in rebateSnapshot.docs) {
      Map<String, dynamic> rebate = doc.data() as Map<String, dynamic>;
      Timestamp startTimestamp = rebate['start_date'] as Timestamp;
      Timestamp endTimestamp = rebate['end_date'] as Timestamp;
      // Only include rebates active on the current date
      if (startTimestamp.compareTo(Timestamp.now()) <= 0 &&
          endTimestamp.compareTo(Timestamp.now()) >= 0) {
        String studentId = rebate['student_id'].path.split('/').last;
        reqId = rebate['req_id'];
        // Fetch student data using studentId
        DocumentSnapshot studentDoc = await FirebaseFirestore.instance
            .collection('students')
            .doc(studentId)
            .get();
        if (studentDoc.exists) {
          String entryNumber = studentDoc['entryNumber'];
          String studentName = studentDoc['name'];
          currentRebates.add(
            CurrentRebate(
              startDate: startTimestamp.toDate(),
              endDate: endTimestamp.toDate(),
              hostel: rebate['hostel'],
              entryNumber: entryNumber,
              studentName: studentName,
              studentId: studentId,
              req_id: reqId,
              url: studentDoc['url'],
            ),
          );
        }
      }
    }
    return currentRebates;
  }

  Future<void> fetchCurrentRebates() async {
    try {
      Rebates = await getCurrentRebates(messName);
      setState(() {
        CurrentRebates = Rebates;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching the rebates $e");
      setState(() => isLoading = false);
    }
  }

  String searchQuery = "";
  String selectedHostel = "";
  String selectedYear = "";

  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    fetchCurrentRebates();
    List<CurrentRebate> filteredRequests = CurrentRebates.where((rebate) {
      return rebate.studentName
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          rebate.entryNumber.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    double maxWidth = MediaQuery.of(context).size.width * 0.95;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Header(currentPage: 'Current Rebates'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                //crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: SizedBox(
                      width: maxWidth,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                "Current Rebates",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: searchController,
                              decoration: InputDecoration(
                                hintText: "Search by Name or Entry Number",
                                prefixIcon: Icon(Icons.search),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  searchQuery = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          searchController.clear();
                          searchQuery = '';
                        });
                      },
                      icon: Icon(Icons.clear),
                      label: Text("Clear Filters"),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          int crossAxisCount;
                          if (constraints.maxWidth > 1000) {
                            crossAxisCount = 3; // large screens
                          } else if (constraints.maxWidth > 600) {
                            crossAxisCount = 2; // medium screens
                          } else {
                            crossAxisCount = 1; // small screens
                          }

                          return GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 24,
                              mainAxisSpacing: 24,
                              childAspectRatio: 2,
                            ),
                            itemCount: filteredRequests.length,
                            itemBuilder: (context, index) {
                              final rebate = filteredRequests[index];
                              return _buildStudentCard(context, rebate);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStudentCard(BuildContext context, CurrentRebate rebate) {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          // Orange vertical accent stripe on the left
          Container(
            width: 6,
            height: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFFF7643),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
          ),
          // Main card content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  // Student image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      rebate.url ?? '',
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 150,
                        height: 150,
                        color: Colors.grey[300],
                        child: Icon(Icons.person, color: Colors.grey[700]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Student details
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rebate.studentName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          rebate.entryNumber,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
