// import 'package:flutter/material.dart';
// import '../../models/rebate.dart';
// import '../../models/user.dart';
// import '../../services/database.dart';
// import '../../components/user_provider.dart';

// class PendingRequestPage extends StatefulWidget {
//   @override
//   _PendingRequestsPageState createState() => _PendingRequestsPageState();
// }

// class _PendingRequestsPageState extends State<PendingRequestPage> {

//   // backend logic to get the rebate requests
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   List<Rebate> pendingRequests = [];
//   bool isLoading = true;

//   @override
//   void initState(){
//     super.initState();
//     fetchPendingRebates();
//   }

//   Future<void> fetchPendingRebates() async {
//     try{
//       String uid = Provider.of<UserProvider>(context, listen: false).uid;
//       DatabaseModel db = DatabaseModel(uid : uid);

//       List<Rebate> rebates = await db.getPendingRebates();

//       setStates(() {
//         pendingRebates = rebates;
//         isLoading = false;
//       });
//     } catch(e){
//       print("Error fetching the rebates $e");
//       setState(() => isLoading = false);
//     }

//   }

//   String searchQuery = "";

//   @override
//   Widget build(BuildContext context) {
//     /*List<Map<String, String>> filteredRequests = requests
//         .where((request) =>
//             request["name"]!.toLowerCase().contains(searchQuery.toLowerCase()) ||
//             request["entryNo"]!.toLowerCase().contains(searchQuery.toLowerCase()))
//         .toList(); */

//     List<Rebate> filteredRebates = pendingRebates.where((rebate) {
//       return rebate.student_id.id.toLowerCase().contains(searchQuery.toLowerCase());
//     }).toList();

//     return Scaffold(
//       appBar: AppBar(title: Text('Pending Requests')),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : pending_request.isEmpty
//             ? Center(child : Text("No pending requests"))
//             : Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   children: [
//                     // Search Bar
//                     TextField(
//                       decoration: InputDecoration(
//                         hintText: "Search by Name or Entry No",
//                         prefixIcon: Icon(Icons.search),
//                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                       ),
//                       onChanged: (value) {
//                         setState(() {
//                           searchQuery = value;
//                         });
//                       },
//                     ),
//                     SizedBox(height: 10),

//                 // Column Headers
//                 Container(
//                   padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
//                   decoration: BoxDecoration(
//                     color: Colors.grey[300],
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       SizedBox(width: 120, child: Text("Name", style: TextStyle(fontWeight: FontWeight.bold))),
//                       SizedBox(width: 120, child: Text("Entry No", style: TextStyle(fontWeight: FontWeight.bold))),
//                       SizedBox(width: 120, child: Text("Hostel", style: TextStyle(fontWeight: FontWeight.bold))),
//                       SizedBox(width: 120, child: Text("Rebate From", style: TextStyle(fontWeight: FontWeight.bold))),
//                       SizedBox(width: 120, child: Text("Rebate Till", style: TextStyle(fontWeight: FontWeight.bold))),
//                       SizedBox(width: 120, child: Text("Action", style: TextStyle(fontWeight: FontWeight.bold))),
//                       Icon(Icons.more_vert, color: Colors.transparent), // Placeholder for alignment
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 10),

//             // List of Requests
//             Expanded(
//               child: ListView.builder(
//                 itemCount: filteredRequests.length,
//                 itemBuilder: (context, index) {
//                   var request = filteredRequests[index];
//                   return Card(
//                     elevation: 3,
//                     margin: EdgeInsets.symmetric(vertical: 10),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           SizedBox(width: 120, child: Text(request['name']!)),
//                           SizedBox(width: 120, child: Text(request['entryNo']!)),
//                           SizedBox(width: 120, child: Text(request['hostel']!)),
//                           SizedBox(width: 120, child: Text(request['from']!)),
//                           SizedBox(width: 120, child: Text(request['to']!)),
//                           SizedBox(
//                             width: 50,
//                             child: Align(
//                               alignment: Alignment.centerRight,
//                               child: PopupMenuButton<String>(
//                                 icon: Icon(Icons.more_vert, color: Colors.black),
//                                 onSelected: (value) {
//                                   if (value == "approve" || value == "reject") {
//                                     setState(() {
//                                       requests.removeWhere(
//                                           (element) => element["sno"] == request["sno"]);
//                                     });
//                                   }
//                                 },
//                                 itemBuilder: (context) => [
//                                   PopupMenuItem(
//                                     value: "approve",
//                                     child: Text("Approve", style: TextStyle(color: Colors.green)),
//                                   ),
//                                   PopupMenuItem(
//                                     value: "reject",
//                                     child: Text("Reject", style: TextStyle(color: Colors.red)),
//                                   ),
//                                 ],
//                               ),
//                             )
//                           )
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
