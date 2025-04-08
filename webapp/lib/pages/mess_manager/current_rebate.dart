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

  CurrentRebate({
    required this.startDate,
    required this.endDate,
    required this.hostel,
    required this.entryNumber,
    required this.studentName,
    required this.studentId,
    required this.req_id,
  });
}

class CurrentRequestPage extends StatefulWidget {
  CurrentRequestPage({super.key});
  @override
  _CurrentRequestsPageState createState() => _CurrentRequestsPageState();
}

class _CurrentRequestsPageState extends State<CurrentRequestPage> {
  // backend logic to get the rebate requests
  //final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = true;
  late DatabaseModel db;
  String? uid;
  String messName = "";

  List<CurrentRebate> Rebates = [];

  List<CurrentRebate> CurrentRebates = [];
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

  String reqId = "";

  Future<List<CurrentRebate>> getCurrentRebates(String messName) async {
    List<CurrentRebate> CurrentRebates = [];
    // Fetch rebates where mess = messName and status = "Approved"
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
        String studentId =
            rebate['student_id'].path.split('/').last; // Extract document ID
        reqId = rebate['req_id'];
        // Fetch student data using studentId
        DocumentSnapshot studentDoc = await FirebaseFirestore.instance
            .collection('students')
            .doc(studentId)
            .get();

        // Fetch user data using studentId
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('user')
            .doc(studentId)
            .get();

        if (studentDoc.exists && userDoc.exists) {
          String entryNumber = studentDoc['entryNumber']; // Get entry number
          String studentName = userDoc['name']; // Get student name

          CurrentRebates.add(
            CurrentRebate(
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
    }

    return CurrentRebates;
  }

  Future<void> fetchCurrentRebates() async {
    try {
      Rebates = await getCurrentRebates(messName);
      /*for (var rebate in Rebates) {
        print("Start Date: ${rebate.startDate}");
        print("End Date: ${rebate.endDate}");
        print("Hostel: ${rebate.hostel}");
        print("Entry Number: ${rebate.entryNumber}");
        print("Student Name: ${rebate.studentName}");
        print("---------------------");
      }*/

      setState(() {
        CurrentRebates = Rebates;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching the rebates $e");
      setState(() => isLoading = false);
    }
  }

  //function to change the status in the firebase of a rebate query

  String searchQuery = "";
  String selectedHostel = "";
  String selectedYear = "";

  @override
  Widget build(BuildContext context) {
    fetchCurrentRebates();
    List<CurrentRebate> filteredRequests = CurrentRebates.where((rebate) {
      return rebate.studentName
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          rebate.entryNumber.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    // return Scaffold(
    //   backgroundColor: Colors.white,
    //   appBar: PreferredSize(
    //     preferredSize: const Size.fromHeight(60),
    //     child: Header(currentPage: 'Current Rebates'),
    //   ),
    //   body: isLoading
    //       ? Center(child: CircularProgressIndicator())
    //       : CurrentRebates.isEmpty
    //           ? Center(child: Text("No Current requests"))
    //           : Padding(
    //               padding: const EdgeInsets.all(16.0),
    //               child: Column(
    //                 children: [
    //                   // Search Bar
    //                   TextField(
    //                     decoration: InputDecoration(
    //                       hintText: "Search by Name or Entry No",
    //                       prefixIcon: Icon(Icons.search),
    //                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    //                     ),
    //                     onChanged: (value) {
    //                       setState(() {
    //                         searchQuery = value;
    //                       });
    //                     },
    //                   ),
    //                   SizedBox(height: 10),

    //                   // Column Headers
    //                   Container(
    //                     padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
    //                     decoration: BoxDecoration(
    //                       color: Colors.grey[300],
    //                       borderRadius: BorderRadius.circular(8),
    //                     ),
    //                     child: Row(
    //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                       children: [
    //                         SizedBox(width: 120, child: Text("Name", style: TextStyle(fontWeight: FontWeight.bold))),
    //                         SizedBox(width: 120, child: Text("Entry No", style: TextStyle(fontWeight: FontWeight.bold))),
    //                         SizedBox(width: 120, child: Text("Hostel", style: TextStyle(fontWeight: FontWeight.bold))),
    //                         SizedBox(width: 120, child: Text("Rebate From", style: TextStyle(fontWeight: FontWeight.bold))),
    //                         SizedBox(width: 120, child: Text("Rebate Till", style: TextStyle(fontWeight: FontWeight.bold))),
    //                         Icon(Icons.more_vert, color: Colors.transparent), // Placeholder for alignment
    //                       ],
    //                     ),
    //                   ),
    //                   SizedBox(height: 10),

    //                   // List of Requests
    //                   Expanded(
    //                     child: ListView.builder(
    //                       itemCount: filteredRequests.length,
    //                       itemBuilder: (context, index) {
    //                         var request = filteredRequests[index];
    //                         return Card(
    //                           elevation: 3,
    //                           margin: EdgeInsets.symmetric(vertical: 10),
    //                           child: Padding(
    //                             padding: const EdgeInsets.all(16.0),
    //                             child: Row(
    //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                               children: [
    //                                 SizedBox(width: 120, child: Text(request.studentName)),
    //                                 SizedBox(width: 120, child: Text(request.entryNumber)),
    //                                 SizedBox(width: 120, child: Text(request.hostel)),
    //                                 SizedBox(width: 120, child: Text(DateFormat('yyyy-MM-dd').format(request.startDate))),
    //                                 SizedBox(width: 120, child: Text(DateFormat('yyyy-MM-dd').format(request.endDate))),
    //                               ],
    //                             ),
    //                           ),
    //                         );
    //                       },
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //             ),

    // );
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
                children: [
                  Center(
                    child: Container(
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
                                    labelText: 'Degree Type',
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
                                    'BTech.',
                                    'Mtech.',
                                    'Phd.',
                                    'MSc.',
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
                                        _buildHeaderCell("Student Image"),
                                        _buildHeaderCell("Name"),
                                        _buildHeaderCell("Entry No"),
                                        _buildHeaderCell("Hostel"),
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
                                      child: CurrentRebates.isEmpty
                                          ? Center(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(24),
                                                child: Text(
                                                  "No Current Rebates.",
                                                  style: TextStyle(
                                                      color: Colors.grey[600]),
                                                ),
                                              ),
                                            )
                                          : ListView.builder(
                                              padding: EdgeInsets.zero,
                                              itemCount:
                                                  filteredRequests.length,
                                              itemBuilder: (context, index) {
                                                final rebate =
                                                    filteredRequests[index];

                                                return Container(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 12,
                                                      horizontal: 8),
                                                  decoration: BoxDecoration(
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
                                                      _buildBodyCell(
                                                          rebate.studentName),
                                                      _buildBodyCell(
                                                          rebate.entryNumber),
                                                      _buildBodyCell(
                                                          rebate.hostel),
                                    
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
}
