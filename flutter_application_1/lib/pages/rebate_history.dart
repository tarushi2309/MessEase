import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/rebate.dart';
import 'package:flutter_application_1/services/database.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../components/footer.dart';
import '../components/header.dart';
import '../components/navbar.dart';
import '../components/user_provider.dart';

class RebateHistoryScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  RebateHistoryScreen({super.key});

  @override
  _RebateHistoryScreenState createState() => _RebateHistoryScreenState();
}

class _RebateHistoryScreenState extends State<RebateHistoryScreen> {
  late DatabaseModel dbService;
  List<Rebate> rebateHistory = [];
  bool isLoading = true;

  @override
  
  Future<void> _fetchRebateHistory(String uid) async {
   

    dbService = DatabaseModel(uid: uid);
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('rebates')
          .where('student_id', isEqualTo: FirebaseFirestore.instance.collection('students').doc(uid))
          .orderBy('start_date', descending: true)
          .get();
      print("StudentID : $uid");
      print("QuerySnapshot: $querySnapshot");
      if (querySnapshot.docs.isEmpty) {
        print("No rebate history found for the user.");
      } else {
        print("First rebate record: ${querySnapshot.docs[0].data()}");
      }
      setState(() {
        rebateHistory = querySnapshot.docs
            .map((doc) => Rebate.fromJson(querySnapshot.docs[0]))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching rebate history: $e");
      setState(() {
        isLoading = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
     String? uid = Provider.of<UserProvider>(context).uid;

    // If the UID is null, show an error message or loading indicator
    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: Text('User Page')),
        body: Center(
          child: Text("No user found. Please log in."),
        ),
      );
    }

    // Fetch data if UID is available and not already loaded
    if (isLoading) {
      _fetchRebateHistory(uid);
    }
    return Scaffold(
      key: widget.scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56),
        child: Header(scaffoldKey: widget.scaffoldKey),
      ),
      drawer: Navbar(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              Text(
                "REBATE TRACKER",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            const SizedBox(height: 10),
            
            RebateSummaryCard(rebateDays: rebateHistory.fold(0, (sum, rebate) => sum + ((rebate.end_date.seconds - rebate.start_date.seconds) ~/ 86400))),
            
            const SizedBox(height: 20),
            Center(
              child: Text(
                "Rebate History",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : rebateHistory.isEmpty
                      ? Center(child: Text("No rebate history available."))
                      : ListView.builder(
                          itemCount: rebateHistory.length,
                          itemBuilder: (context, index) {
                            return _buildRebateCard(
                              DateFormat('dd-MM-yyyy').format(rebateHistory[index].start_date.toDate()),
                              DateFormat('dd-MM-yyyy').format(rebateHistory[index].end_date.toDate()), 
                              ((rebateHistory[index].end_date.seconds - rebateHistory[index].start_date.seconds) ~/ 86400) + 1,
                              "Approved", // Modify based on actual status
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(),
    );
  }

  Widget _buildRebateCard(String from, String to, int days, String status) {
    Color statusColor = status == 'Approved' ? Colors.green : Colors.red;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          title: Text(
            'From: ${from} \nTo: ${to}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          subtitle: Text('Number of days: $days'),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

class RebateSummaryCard extends StatelessWidget {
  final int rebateDays;
  const RebateSummaryCard({super.key, required this.rebateDays});

  @override
  Widget build(BuildContext context) {
    int rebateAmount = rebateDays * 130;
    double filledPercentage = rebateDays / 21;
    Color pieColor = Color(0xFFE06635);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Rebate Amount',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '₹$rebateAmount',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF0753C),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                SizedBox(
                  height: 100,
                  width: 100,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          color: pieColor,
                          value: rebateDays.toDouble(),
                          radius: 30,
                        ),
                        PieChartSectionData(
                          color: Colors.grey[300]!,
                          value: (21 - rebateDays).toDouble(),
                          radius: 30,
                        ),
                      ],
                      sectionsSpace: 2,
                      centerSpaceRadius: 30,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text('$rebateDays / 21 Days',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
