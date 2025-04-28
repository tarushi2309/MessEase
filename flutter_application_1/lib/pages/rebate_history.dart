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
  List<QueryDocumentSnapshot> rebateDocs = [];
  List<Rebate> rebateHistory = [];
  List<Rebate> approvedRebates = [];
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

      setState(() {
        rebateDocs = querySnapshot.docs;
        rebateHistory = rebateDocs.map((doc) {
          var rebate = Rebate.fromJson(doc);
          return rebate;
        }).toList();

        approvedRebates = rebateHistory
          .where((r) => r.status_.toString().split('.').last.toLowerCase() == 'approve')
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

  /// Deletes the rebate document both in Firestore and locally.
  Future<void> _deleteRebate(int index,String uid) async {
  final doc = rebateDocs[index];
  try {
    // Fetch the rebate document to get start and end dates
    final rebateDocSnapshot = await FirebaseFirestore.instance
      .collection('rebates')
      .doc(doc.id)
      .get();

    if (!rebateDocSnapshot.exists) {
      throw Exception('Rebate document does not exist');
    }

    final data = rebateDocSnapshot.data();
    if (data == null ) {
      throw Exception('Rebate document missing required fields');
    }

    final startDate = (data['start_date'] as Timestamp).toDate();
    final endDate = (data['end_date'] as Timestamp).toDate();

    // Calculate the number of days between start and end date (inclusive)
    final days = endDate.difference(startDate).inDays + 1;

    // Delete the rebate document
    await FirebaseFirestore.instance
      .collection('rebates')
      .doc(doc.id)
      .delete();

    // Update the state
    setState(() {
      rebateDocs.removeAt(index);
      rebateHistory.removeAt(index);
      approvedRebates = rebateHistory
        .where((r) => r.status_.toString().split('.').last.toLowerCase() == 'approve')
        .toList();
    });

    // Subtract the days from the student's pending rebates count
    final studentDocRef = FirebaseFirestore.instance.collection('students').doc(uid);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final studentSnapshot = await transaction.get(studentDocRef);
      if (!studentSnapshot.exists) {
        throw Exception('Student document does not exist');
      }
      final currentPendingCount = studentSnapshot.data()?['pending_rebate_days'] ?? 0;
      final newPendingCount = (currentPendingCount - days).clamp(0, double.infinity).toInt();
      transaction.update(studentDocRef, {'pending_rebate_days': newPendingCount});
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pending rebate deleted')),
    );
  } catch (e) {
    print("Error deleting rebate: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to delete rebate')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    String? uid = Provider.of<UserProvider>(context).uid;
    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: Text('User Page')),
        body: Center(child: Text("No user found. Please log in.")),
      );
    }
    if (isLoading) {
      _fetchRebateHistory(uid);
    }

    return Scaffold(
      key: widget.scaffoldKey,
      backgroundColor: Colors.white,
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
          
            const SizedBox(height: 10),
            RebateSummaryCard(
              rebateDays: approvedRebates.fold(
                0,
                (sum, r) => sum + ((r.end_date.seconds - r.start_date.seconds) ~/ 86400) + 1,
              ),
            ),
            const SizedBox(height: 20),
            Center(child: Text("Rebate History", style: TextStyle(fontSize: 30))),
            const SizedBox(height: 10),
            Expanded(
              child: isLoading
                ? Center(child: CircularProgressIndicator())
                : rebateHistory.isEmpty
                  ? Center(child: Text("No rebate history available."))
                  : ListView.builder(
                      itemCount: rebateHistory.length,
                      itemBuilder: (context, index) {
                        final rebate = rebateHistory[index];
                        String statusText = rebate.status_.toString().split('.').last;
                        statusText = statusText[0].toUpperCase() + statusText.substring(1);
                        final isPending = statusText.toLowerCase() == 'pending';

                        return Card(
                          color:Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            title: Text(
                              '${DateFormat('dd-MM-yyyy').format(rebate.start_date.toDate())} to ${DateFormat('dd-MM-yyyy').format(rebate.end_date.toDate())}',
                              
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(
                              'Number of Days: ${((rebate.end_date.seconds - rebate.start_date.seconds) ~/ 86400) + 1}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // status pill
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: (statusText == 'Approve' ? Colors.green : Colors.red)
                                      .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    statusText,
                                    style: TextStyle(
                                      color: statusText == 'Approve' ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                // delete button for pending
                                if (isPending)
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    tooltip: 'Delete pending request',
                                    onPressed: () => _deleteRebate(index,uid),
                                  ),
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
      bottomNavigationBar: CustomNavigationBar(),
    );
  }
}


class RebateSummaryCard extends StatelessWidget {
  final int rebateDays;
  const RebateSummaryCard({super.key, required this.rebateDays});

  @override
  Widget build(BuildContext context) {
    int rebateAmount = rebateDays * 130;
    double filledPercentage = rebateDays / 20;
    Color pieColor = Color(0xFFE06635);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      color: Colors.white,
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
                          value: (20 - rebateDays).toDouble(),
                          radius: 30,
                        ),
                      ],
                      sectionsSpace: 2,
                      centerSpaceRadius: 30,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text('$rebateDays / 20 Days',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}