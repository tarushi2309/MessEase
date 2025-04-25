import 'package:flutter/material.dart';
import 'package:webapp/components/header_manager.dart';
import '../../models/rebate.dart';
import '../../models/user.dart';
import '../../services/database.dart';
import '../../components/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class PendingRebate {
  final DateTime startDate;
  final DateTime endDate;
  final String hostel;
  final String studentId;
  final String entryNumber;
  final String studentName;
  final String req_id;

  PendingRebate({
    required this.startDate,
    required this.endDate,
    required this.hostel,
    required this.entryNumber,
    required this.studentName,
    required this.studentId,
    required this.req_id,
  });
}

class PendingRequestPage extends StatefulWidget {
  const PendingRequestPage({super.key});
  @override
  _PendingRequestsPageState createState() => _PendingRequestsPageState();
}

class _PendingRequestsPageState extends State<PendingRequestPage> {
  // backend logic to get the rebate requests
  //final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = true;
  late DatabaseModel db;
  String? uid;
  String messName = "";

  @override
  void initState() {
    super.initState();
    // Fetch UID in initState instead of the initializer
    uid = Provider.of<UserProvider>(context, listen: false).uid;
    print(uid);
    print("this is me debugging");
    fetchUserName();
  }

  // fetch mess name from uid
  @override
  void fetchUserName() async {
    print("I am entering here");
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('user').doc(uid).get();
      print(userDoc);
      print(userDoc['name']);
      if (userDoc.exists) {
        messName = userDoc['name']; // Return the name from the document
      } else {
        print("User not found");
      }
    } catch (e) {
      print("Error fetching user: $e");
    }
    print(messName);
  }

  List<PendingRebate> Rebates = [];
  String reqId = "";

  Future<List<PendingRebate>> getPendingRebates(String messName) async {
    List<PendingRebate> pendingRebates = [];

    // Fetch rebates where mess = messName and status = "pending"
    QuerySnapshot rebateSnapshot = await FirebaseFirestore.instance
        .collection('rebates')
        .where('mess', isEqualTo: messName)
        .where('status', isEqualTo: 'pending')
        .get();

    for (var doc in rebateSnapshot.docs) {
      Map<String, dynamic> rebate = doc.data() as Map<String, dynamic>;

      Timestamp startTimestamp = rebate['start_date'];
      Timestamp endTimestamp = rebate['end_date'];
      String studentId =
          rebate['student_id'].path.split('/').last; // Extract document ID
      reqId = rebate['req_id'];

      // Fetch student data using studentId
      DocumentSnapshot studentDoc = await FirebaseFirestore.instance
          .collection('students')
          .doc(studentId)
          .get();

      // Fetch user data using studentId
      

      if (studentDoc.exists) {
        String entryNumber = studentDoc['entryNumber']; // Get entry number
        String studentName = studentDoc['name']; // Get student name

        pendingRebates.add(
          PendingRebate(
            startDate: startTimestamp.toDate(),
            endDate: endTimestamp.toDate(),
            hostel: rebate['hostel'],
            entryNumber: entryNumber,
            studentName: studentName,
            studentId: studentId,
            req_id: reqId,
          ),
        );
      }
    }

    return pendingRebates;
  }

  List<PendingRebate> pendingRebates = [];

  Future<void> fetchPendingRebates() async {
    try {
      Rebates = await getPendingRebates(messName);
      /*for (var rebate in Rebates) {
        print("Start Date: ${rebate.startDate}");
        print("End Date: ${rebate.endDate}");
        print("Hostel: ${rebate.hostel}");
        print("Entry Number: ${rebate.entryNumber}");
        print("Student Name: ${rebate.studentName}");
        print("---------------------");
      }*/

      setState(() {
        pendingRebates = Rebates;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching the rebates $e");
      setState(() => isLoading = false);
    }
  }

  //function to change the status in the firebase of a rebate query

  Future<void> updateRebateStatus(
      String studentId, String newStatus, int numberofDaysAdded) async {
    try {
      DocumentReference studentRef =
          FirebaseFirestore.instance.collection("students").doc(studentId);
      // Query Firestore for rebate where student_id matches
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("rebates")
          .where("student_id", isEqualTo: studentRef)
          .where("mess", isEqualTo: messName)
          .where("status", isEqualTo: "pending")
          .get();

      print(studentRef);
      QuerySnapshot querySnapshotStudent = await FirebaseFirestore.instance
          .collection("students")
          .where("uid", isEqualTo: studentId)
          .get();

      //update status to approve/reject
      if (querySnapshot.docs.isNotEmpty) {
        // Get the first matching document (assuming only one rebate per student at a time)
        DocumentSnapshot doc = querySnapshot.docs.first;

        //debugging
        print("Updating document: ${doc.reference.path}");
        print("Document data: ${doc.data()}");

        await doc.reference.update({"status": newStatus}); // Update status
        await Future.delayed(
            Duration(seconds: 2)); // wait for this change to propogate

        print("Rebate status updated successfully!");
      } else {
        print("No rebate request found for this student.");
      }

      //update the num of days of rebate
      if (querySnapshotStudent.docs.isNotEmpty) {
        // Get the first matching document (assuming only one rebate per student at a time)
        print("Entering here");
        DocumentSnapshot doc = querySnapshotStudent.docs.first;

        //debugging
        print("Updating document: ${doc.reference.path}");
        print("Document data: ${doc.data()}");

        int currentNumberOfDays = doc["days_of_rebate"] ?? 0;
        int updatedDays = currentNumberOfDays + numberofDaysAdded;
        print(updatedDays);

        await doc.reference
            .update({"days_of_rebate": updatedDays}); // Update status
        await doc.reference
            .update({"refund": updatedDays * 130}); // Update status
        await Future.delayed(
            Duration(seconds: 2)); // wait for this change to propogate

        print("Rebate days added successfully!");
      } else {
        print("No rebate request found for this student.");
      }
    } catch (e) {
      print("Error updating rebate status: $e");
    }
  }

  String searchQuery = "";
  String selectedHostel = "";
  String selectedYear = "";

  @override
  Widget build(BuildContext context) {
    fetchPendingRebates();

    List<PendingRebate> filteredRequests = pendingRebates.where((rebate) {
      bool matchesSearch = rebate.studentName
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          rebate.entryNumber.toLowerCase().contains(searchQuery.toLowerCase());

      bool matchesHostel = selectedHostel.isEmpty ||
          rebate.hostel.toLowerCase() == selectedHostel.toLowerCase();

      bool matchesYear =
          selectedYear.isEmpty || rebate.entryNumber.contains(selectedYear);

      return matchesSearch && matchesHostel && matchesYear;
    }).toList();

    double maxWidth = MediaQuery.of(context).size.width * 0.95;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Header(currentPage: 'Pending Rebates'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  Center(
                    child: SizedBox(
                      width: maxWidth,
                      child: Row(
                        children: [
                          // Search bar
                          Expanded(
                            flex: 4,
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: "Search by Name or Entry No",
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
                          SizedBox(width: 12),

                          DropdownButtonHideUnderline(
                            child: ButtonTheme(
                              alignedDropdown: true,
                              child: SizedBox(
                                width:
                                    180, // controls dropdown popup + field width
                                child: DropdownButtonFormField<String>(
                                  value: selectedHostel.isEmpty
                                      ? null
                                      : selectedHostel,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    labelText: 'Hostel',
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 14),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    filled: true,
                                    fillColor: Colors.grey[100],
                                  ),
                                  icon: Icon(Icons.arrow_drop_down,
                                      color: Colors.grey[800]),
                                  dropdownColor: Colors.white,
                                  elevation: 6,
                                  borderRadius: BorderRadius.circular(10),
                                  items: [
                                    'CHENAB',
                                    'RAAVI',
                                    'SUTLEJ',
                                    'BRAMHAPUTRA',
                                    'BEAS',
                                    'T6',
                                  ]
                                      .map((hostel) => DropdownMenuItem(
                                            value: hostel.toLowerCase(),
                                            child: SizedBox(
                                              height:
                                                  20, // 👈 custom height here (default is ~48)
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  hostel,
                                                  style: TextStyle(
                                                      fontSize:
                                                          14), // you can reduce font too
                                                ),
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedHostel = value ?? '';
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          selectedHostel = '';
                          selectedYear = '';
                        });
                      },
                      icon: Icon(Icons.clear),
                      label: Text("Clear Filters"),
                    ),
                  ),

                  // 🧾 Data Table
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double maxWidth =
                            MediaQuery.of(context).size.width * 0.95;

                        return Center(
                          child: Container(
                            width: maxWidth,
                            margin: EdgeInsets.only(bottom: 24),
                            child: Card(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                              child: Column(
                                children: [
                                  // HEADER
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        topRight: Radius.circular(16),
                                      ),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        vertical: 14, horizontal: 8),
                                    child: Row(
                                      children: [
                                        _buildHeaderCell("Name"),
                                        _buildHeaderCell("Entry No"),
                                        _buildHeaderCell("Hostel"),
                                        _buildHeaderCell("Rebate From"),
                                        _buildHeaderCell("Rebate Till"),
                                        _buildHeaderCell("Actions"),
                                      ],
                                    ),
                                  ),

                                  // BODY
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(16),
                                        bottomRight: Radius.circular(16),
                                      ),
                                      child: isLoading
                                          ? Center(
                                              child: CircularProgressIndicator(
                                                color: Colors.grey[300],
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : filteredRequests.isEmpty
                                              ? Center(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            24),
                                                    child: Text(
                                                      "No pending rebates",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors
                                                            .grey[600],
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : ListView.builder(
                                                  padding: EdgeInsets.zero,
                                                  itemCount:
                                                      filteredRequests.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final rebate =
                                                        filteredRequests[index];
                                                    final numberOfDays = ((rebate
                                                                    .endDate
                                                                    .millisecondsSinceEpoch -
                                                                rebate.startDate
                                                                    .millisecondsSinceEpoch) ~/
                                                            86400000) +
                                                        1;

                                                    return Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 12,
                                                              horizontal: 8),
                                                      decoration:
                                                          BoxDecoration(
                                                        color: index % 2 == 0
                                                            ? Colors.grey[50]
                                                            : Colors.grey[
                                                                100], // alternating row color
                                                        border: Border(
                                                          bottom: BorderSide(
                                                              color: Colors
                                                                  .grey[300]!),
                                                        ),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          _buildBodyCell(rebate
                                                              .studentName),
                                                          _buildBodyCell(rebate
                                                              .entryNumber),
                                                          _buildBodyCell(
                                                              rebate.hostel),
                                                          _buildBodyCell(DateFormat(
                                                                  'yyyy-MM-dd')
                                                              .format(rebate
                                                                  .startDate)),
                                                          _buildBodyCell(DateFormat(
                                                                  'yyyy-MM-dd')
                                                              .format(rebate
                                                                  .endDate)),
                                                          _buildBodyCell(
                                                              buildActionsMenu(
                                                                  rebate,
                                                                  numberOfDays)),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderCell(String label) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildBodyCell(dynamic content) {
    return Expanded(
      child: Center(
        child: content is Widget
            ? content
            : Text(content.toString(), style: TextStyle(fontSize: 14)),
      ),
    );
  }

  Widget buildActionsMenu(PendingRebate rebate, int numberofDaysAdded) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: Colors.black),
      onSelected: (value) async {
        if (value == "approve" || value == "reject") {
          await updateRebateStatus(rebate.studentId, value, numberofDaysAdded);
          setState(() {
            pendingRebates.removeWhere((r) => r.req_id == rebate.req_id);
          });
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: "approve",
          child: Text("Approve", style: TextStyle(color: Colors.green)),
        ),
        PopupMenuItem(
          value: "reject",
          child: Text("Reject", style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
