import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webapp/components/header_manager.dart';
import '../../models/rebate.dart';
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
  late SharedPreferences prefs;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  String selectedHostel = "";
  String selectedYear = "";

  @override
  void initState() {
    super.initState();
    _initializePersistedData();
  }

  Future<void> _initializePersistedData() async {
    prefs = await _prefs;
    // Load uid from SharedPreferences or Provider
    uid = Provider.of<UserProvider>(context, listen: false).uid ?? 
          prefs.getString('uid');
    
    if (uid != null) {
      await _persistUid();
      await fetchUserName();
      await fetchCurrentRebates();
    }
    
    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _persistUid() async {
    if (uid != null && uid!.isNotEmpty) {
      await prefs.setString('uid', uid!);
    }
  }

  Future<void> _persistMessName() async {
    if (messName.isNotEmpty) {
      await prefs.setString('mess', messName);
    }
  }

  Future<void> fetchUserName() async {
    try {
      // Try to load from SharedPreferences first
      messName = prefs.getString('mess') ?? '';
      
      // Fallback to Firestore if not found
      if (messName.isEmpty && uid != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('user')
            .doc(uid)
            .get();

        if (userDoc.exists) {
          messName = userDoc['name'];
          await _persistMessName();
        }
      }
    } catch (e) {
      print("Error fetching user: $e");
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<List<CurrentRebate>> getCurrentRebates(String messName) async {
    List<CurrentRebate> currentRebates = [];
    try {
      QuerySnapshot rebateSnapshot = await FirebaseFirestore.instance
          .collection('rebates')
          .where('mess', isEqualTo: messName)
          .where('status', isEqualTo: 'approve')
          .get();

      for (var doc in rebateSnapshot.docs) {
        Map<String, dynamic> rebate = doc.data() as Map<String, dynamic>;
        Timestamp startTimestamp = rebate['start_date'] as Timestamp;
        Timestamp endTimestamp = rebate['end_date'] as Timestamp;

        if (startTimestamp.compareTo(Timestamp.now()) <= 0 &&
            endTimestamp.compareTo(Timestamp.now()) >= 0) {
          DocumentReference studentRef = rebate['student_id'] as DocumentReference;
          String studentId = studentRef.id;
          String reqId = rebate['req_id'];

          DocumentSnapshot studentDoc = await FirebaseFirestore.instance
              .collection('students')
              .doc(studentId)
              .get();

          if (studentDoc.exists) {
            currentRebates.add(
              CurrentRebate(
                startDate: startTimestamp.toDate(),
                endDate: endTimestamp.toDate(),
                hostel: rebate['hostel'],
                entryNumber: studentDoc['entryNumber'],
                studentName: studentDoc['name'],
                studentId: studentId,
                req_id: reqId,
                url: studentDoc['url'],
              ),
            );
          }
        }
      }
    } catch (e) {
      print("Error fetching current rebates: $e");
      throw Exception("Failed to load current rebates");
    }
    return currentRebates;
  }

  Future<void> fetchCurrentRebates() async {
    try {
      Rebates = await getCurrentRebates(messName);
      if (mounted) {
        setState(() {
          CurrentRebates = Rebates;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching rebates: $e");
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<CurrentRebate> filteredRequests = CurrentRebates.where((rebate) {
      return rebate.studentName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          rebate.entryNumber.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    double maxWidth = MediaQuery.of(context).size.width * 0.95;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Header(currentPage: 'Current Rebates'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
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
                            borderRadius: BorderRadius.circular(8),
                          ),
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
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : CurrentRebates.isEmpty
                      ? Center(
                          child: Text(
                            "No Current Rebates",
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              int crossAxisCount = constraints.maxWidth > 1000
                                  ? 3
                                  : constraints.maxWidth > 600
                                      ? 2
                                      : 1;

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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
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
                        const SizedBox(height: 8),
                        Text(
                          '${DateFormat('MMM dd').format(rebate.startDate)} - ${DateFormat('MMM dd').format(rebate.endDate)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blueGrey[700],
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

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
