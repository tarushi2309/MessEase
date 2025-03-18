import 'package:flutter/material.dart';
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

  PendingRebate({
    required this.startDate,
    required this.endDate,
    required this.hostel,
    required this.entryNumber,
    required this.studentName,
    required this.studentId,
  });
}

class PendingRequestPage extends StatefulWidget {
  PendingRequestPage({super.key});
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
  
  void fetchUserName() async{
    print("I am entering here");
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('user').doc(uid).get();
      print(userDoc);
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
    String studentId = rebate['student_id'].path.split('/').last; // Extract document ID

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

      pendingRebates.add(
        PendingRebate(
          startDate: startTimestamp.toDate(),
          endDate: endTimestamp.toDate(),
          hostel: rebate['hostel'],
          entryNumber: entryNumber,
          studentName: studentName,
          studentId: studentId,
        ),
      );
    }
  }

  return pendingRebates;
}

  List<PendingRebate> pendingRebates = [];

  Future<void> fetchPendingRebates() async {
    try{

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
    } catch(e){
      print("Error fetching the rebates $e");
      setState(() => isLoading = false);
    }

  }

  //function to change the status in the firebase of a rebate query

  Future<void> updateRebateStatus(String studentId, String newStatus) async {
    try {
      DocumentReference studentRef = FirebaseFirestore.instance.collection("students").doc(studentId);
      // Query Firestore for rebate where student_id matches
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("rebates")
          .where("student_id", isEqualTo: studentRef)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Get the first matching document (assuming only one rebate per student at a time)
        DocumentSnapshot doc = querySnapshot.docs.first;
        await doc.reference.update({"status": newStatus}); // Update status

        print("Rebate status updated successfully!");
      } else {
        print("No rebate request found for this student.");
      }
    } catch (e) {
      print("Error updating rebate status: $e");
    }
  }

  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    fetchPendingRebates();
    List<PendingRebate> filteredRequests = pendingRebates.where((rebate) {
      return rebate.studentName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          rebate.entryNumber.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text('Pending Requests')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : pendingRebates.isEmpty
              ? Center(child: Text("No pending requests"))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Search Bar
                      TextField(
                        decoration: InputDecoration(
                          hintText: "Search by Name or Entry No",
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                      ),
                      SizedBox(height: 10),

                      // Column Headers
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(width: 120, child: Text("Name", style: TextStyle(fontWeight: FontWeight.bold))),
                            SizedBox(width: 120, child: Text("Entry No", style: TextStyle(fontWeight: FontWeight.bold))),
                            SizedBox(width: 120, child: Text("Hostel", style: TextStyle(fontWeight: FontWeight.bold))),
                            SizedBox(width: 120, child: Text("Rebate From", style: TextStyle(fontWeight: FontWeight.bold))),
                            SizedBox(width: 120, child: Text("Rebate Till", style: TextStyle(fontWeight: FontWeight.bold))),
                            SizedBox(width: 120, child: Text("Action", style: TextStyle(fontWeight: FontWeight.bold))),
                            Icon(Icons.more_vert, color: Colors.transparent), // Placeholder for alignment
                          ],
                        ),
                      ),
                      SizedBox(height: 10),

                      // List of Requests
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredRequests.length,
                          itemBuilder: (context, index) {
                            var request = filteredRequests[index];
                            return Card(
                              elevation: 3,
                              margin: EdgeInsets.symmetric(vertical: 10),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(width: 120, child: Text(request.studentName)),
                                    SizedBox(width: 120, child: Text(request.entryNumber)),
                                    SizedBox(width: 120, child: Text(request.hostel)),
                                    SizedBox(width: 120, child: Text(DateFormat('yyyy-MM-dd').format(request.startDate))),
                                    SizedBox(width: 120, child: Text(DateFormat('yyyy-MM-dd').format(request.endDate))),
                                    SizedBox(
                                      width: 50,
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: PopupMenuButton<String>(
                                          icon: Icon(Icons.more_vert, color: Colors.black),
                                          onSelected: (value) async {
                                            if (value == "approve" || value == "reject") {
                                              setState(() {
                                                // updating the status in the backend
                                                String newStatus = value; 
                                                String studentId = filteredRequests[index].studentId;
                                                print(newStatus);
                                                print(studentId);
                                                print("I am here to update status");
                                                updateRebateStatus(studentId, newStatus);

                                                // deleting the row once approved / rejected
                                                print("I am here to delete the row");
                                                filteredRequests.removeAt(index);
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
                                        ),
                                      ),
                                    )
                                  ],
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
} 
