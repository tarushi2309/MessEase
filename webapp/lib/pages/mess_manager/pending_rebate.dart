import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool isLoading = true;
  late DatabaseModel db;
  String? uid;
  String messName = "";
  late SharedPreferences prefs;

  List<PendingRebate> Rebates = [];
  List<PendingRebate> pendingRebates = [];
  String reqId = "";

  String searchQuery = "";
  String selectedHostel = "";
  String selectedYear = "";

  @override
  void initState() {
    super.initState();
    _initPrefsAndLoad();
  }

  Future<void> _initPrefsAndLoad() async {
    prefs = await SharedPreferences.getInstance();
    // Try to get uid from Provider, else from SharedPreferences
    uid = Provider.of<UserProvider>(context, listen: false).uid ?? prefs.getString('uid');
    if (uid != null) {
      await prefs.setString('uid', uid!);
      await fetchUserName();
      await fetchPendingRebates();
    }
    if (mounted) setState(() => isLoading = false);
  }

  Future<void> fetchUserName() async {
    // Try to load from SharedPreferences first
    messName = prefs.getString('mess') ?? '';
    if (messName.isEmpty && uid != null) {
      try {
        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance.collection('user').doc(uid).get();
        if (userDoc.exists) {
          messName = userDoc['name'];
          await prefs.setString('mess', messName);
        }
      } catch (e) {
        print("Error fetching user: $e");
      }
    }
  }

  Future<List<PendingRebate>> getPendingRebates(String messName) async {
    List<PendingRebate> pendingRebates = [];
    QuerySnapshot rebateSnapshot = await FirebaseFirestore.instance
        .collection('rebates')
        .where('mess', isEqualTo: messName)
        .where('status', isEqualTo: 'pending')
        .get();

    for (var doc in rebateSnapshot.docs) {
      Map<String, dynamic> rebate = doc.data() as Map<String, dynamic>;
      Timestamp startTimestamp = rebate['start_date'];
      Timestamp endTimestamp = rebate['end_date'];
      // Use robust document reference extraction
      DocumentReference studentRef = rebate['student_id'] as DocumentReference;
      String studentId = studentRef.id;
      reqId = rebate['req_id'];

      DocumentSnapshot studentDoc = await FirebaseFirestore.instance
          .collection('students')
          .doc(studentId)
          .get();

      if (studentDoc.exists) {
        String entryNumber = studentDoc['entryNumber'];
        String studentName = studentDoc['name'];
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

  Future<void> fetchPendingRebates() async {
    try {
      Rebates = await getPendingRebates(messName);
      if (mounted) {
        setState(() {
          pendingRebates = Rebates;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching the rebates $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> updateRebateStatus(
      String studentId, String newStatus, int numberofDaysAdded) async {
    try {
      DocumentReference studentRef =
          FirebaseFirestore.instance.collection("students").doc(studentId);
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("rebates")
          .where("student_id", isEqualTo: studentRef)
          .where("mess", isEqualTo: messName)
          .where("status", isEqualTo: "pending")
          .get();

      QuerySnapshot querySnapshotStudent = await FirebaseFirestore.instance
          .collection("students")
          .where("uid", isEqualTo: studentId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = querySnapshot.docs.first;
        await doc.reference.update({"status": newStatus});
        await Future.delayed(Duration(seconds: 2));
      } else {
        print("No rebate request found for this student.");
      }

      if (querySnapshotStudent.docs.isNotEmpty) {
        DocumentSnapshot doc = querySnapshotStudent.docs.first;
        int currentNumberOfDays = doc["days_of_rebate"] ?? 0;
        int updatedDays = currentNumberOfDays + numberofDaysAdded;
        int updatedPendingDays = doc["pending_rebate_days"]-numberofDaysAdded;
        await doc.reference.update({"days_of_rebate": updatedDays});
        await doc.reference.update({"pending_rebate_days":updatedPendingDays });
        await doc.reference.update({"refund": updatedDays * 130});
        await Future.delayed(Duration(seconds: 2));
      } else {
        print("No rebate request found for this student.");
      }
    } catch (e) {
      print("Error updating rebate status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
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
                                width: 180,
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
                                              height: 20,
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  hostel,
                                                  style: TextStyle(fontSize: 14),
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
                                                    final rebate = filteredRequests[index];
                                                    final numberOfDays = rebate.endDate.difference(rebate.startDate).inDays + 1;
                                                    return Container(
                                                      padding: EdgeInsets.symmetric(
                                                          vertical: 12,
                                                          horizontal: 8),
                                                      decoration: BoxDecoration(
                                                        color: index % 2 == 0
                                                            ? Colors.grey[50]
                                                            : Colors.grey[100],
                                                        border: Border(
                                                          bottom: BorderSide(
                                                              color: Colors
                                                                  .grey[300]!),
                                                        ),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          _buildBodyCell(rebate.studentName),
                                                          _buildBodyCell(rebate.entryNumber),
                                                          _buildBodyCell(rebate.hostel),
                                                          _buildBodyCell(DateFormat('yyyy-MM-dd').format(rebate.startDate)),
                                                          _buildBodyCell(DateFormat('yyyy-MM-dd').format(rebate.endDate)),
                                                          _buildBodyCell(
                                                            buildActionsMenu(rebate, numberOfDays),
                                                          ),
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

  Widget buildActionsMenu(PendingRebate rebate, int numberOfDaysAdded) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: Colors.black),
      onSelected: (value) async {
        if (value == "approve" || value == "reject") {
          await updateRebateStatus(rebate.studentId, value, numberOfDaysAdded);
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
