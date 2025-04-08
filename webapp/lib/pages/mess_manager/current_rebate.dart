import 'package:flutter/material.dart';
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

  // backend logic to get the rebate requests
  //final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool isLoading = true;
  late DatabaseModel db;
  String? uid;
  String messName = "";

  List<CurrentRebate> Rebates = [];

  List<CurrentRebate> CurrentRebates = [];
  @override
  void initState(){
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
      .where('mess', isEqualTo: messName).where('status', isEqualTo: 'approve').get();
  for (var doc in rebateSnapshot.docs) {
    Map<String, dynamic> rebate = doc.data() as Map<String, dynamic>;

    Timestamp startTimestamp = rebate['start_date'] as Timestamp;
    Timestamp endTimestamp = rebate['end_date'] as Timestamp;
    if(startTimestamp.compareTo(Timestamp.now())<=0 && endTimestamp.compareTo(Timestamp.now())>=0){
      
    
    String studentId = rebate['student_id'].path.split('/').last;// Extract document ID
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

      CurrentRebates.add(
        CurrentRebate(
          startDate: startTimestamp.toDate(),
          endDate: endTimestamp.toDate(),
          hostel: rebate['hostel'],
          entryNumber: entryNumber,
          studentName: studentName,
          studentId: studentId,
          req_id: reqId,
          url:studentDoc['url'],
        ),
      );
      
    }
    }
  }
  
  return CurrentRebates;
}

  

  Future<void> fetchCurrentRebates() async {
    try{
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
    } catch(e){
      print("Error fetching the rebates $e");
      setState(() => isLoading = false);
    }

  }

  //function to change the status in the firebase of a rebate query

  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    fetchCurrentRebates();
    List<CurrentRebate> filteredRequests = CurrentRebates.where((rebate) {
      return rebate.studentName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          rebate.entryNumber.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text('Current Requests')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : CurrentRebates.isEmpty
              ? Center(child: Text("No Current requests"))
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
