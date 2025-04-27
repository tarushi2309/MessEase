import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:webapp/components/header_student.dart';
import 'package:webapp/components/user_provider.dart';
import 'package:webapp/models/mess_menu.dart';
import 'package:webapp/models/rebate.dart';
import 'package:webapp/services/database.dart';

class RebateHistoryStudentPage extends StatefulWidget {
  const RebateHistoryStudentPage({super.key});

  @override
  State<RebateHistoryStudentPage> createState() =>
      _RebateHistoryStudentPageState();
}

class _RebateHistoryStudentPageState extends State<RebateHistoryStudentPage> {
  DatabaseModel db = DatabaseModel();
  late DatabaseModel dbService;
  List<Rebate> rebateHistory = [];
  List<Rebate> approvedRebates = [];
  List<QueryDocumentSnapshot> rebateDocs = [];
  String? uid;
  bool isLoading = true;

  Future<void> _deleteRebate(int index, String uid) async {
    final doc = rebateDocs[index];
    try {
      final rebateDocSnapshot = await FirebaseFirestore.instance
          .collection('rebates')
          .doc(doc.id)
          .get();

      if (!rebateDocSnapshot.exists) throw Exception('Rebate document does not exist');
      final data = rebateDocSnapshot.data();
      if (data == null) throw Exception('Rebate document missing required fields');

      final startDate = (data['start_date'] as Timestamp).toDate();
      final endDate = (data['end_date'] as Timestamp).toDate();
      final days = endDate.difference(startDate).inDays + 1;

      await FirebaseFirestore.instance.collection('rebates').doc(doc.id).delete();

      setState(() {
        rebateDocs.removeAt(index);
        rebateHistory.removeAt(index);
        approvedRebates = rebateHistory
            .where((r) => r.status_.toString().split('.').last.toLowerCase() == 'approve')
            .toList();
      });

      final studentDocRef = FirebaseFirestore.instance.collection('students').doc(uid);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final studentSnapshot = await transaction.get(studentDocRef);
        if (!studentSnapshot.exists) throw Exception('Student document does not exist');
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

  Future<void> _fetchRebateHistory(String uid) async {
    dbService = DatabaseModel();
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('rebates')
          .where('student_id',
              isEqualTo:
                  FirebaseFirestore.instance.collection('students').doc(uid))
          .orderBy('start_date', descending: true)
          .get();
      setState(() {
        rebateDocs = querySnapshot.docs;
        rebateHistory = querySnapshot.docs.map((doc) {
          var rebate = Rebate.fromJson(doc);
          return rebate;
        }).toList();
        approvedRebates = rebateHistory
            .where((rebate) =>
                rebate.status_.toString().toLowerCase() == "status.approve")
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
    uid = Provider.of<UserProvider>(context).uid;

    if (uid == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (isLoading) {
      _fetchRebateHistory(uid!);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Header(currentPage: 'Rebate History'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // For screens less than 800 pixels wide, use a vertical layout with full vertical scroll
          if (constraints.maxWidth < 800) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildRebateChart(),
                    const SizedBox(height: 16),
                    _buildAllRebates(),
                  ],
                ),
              ),
            );
          } else {
            // For larger screens, display side-by-side, but allow vertical scroll if needed
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildRebateChart()),
                    const SizedBox(width: 16),
                    Expanded(flex: 3, child: _buildAllRebates()),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildAllRebates() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : rebateHistory.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: Text("No rebate history available.")),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          Flexible(flex: 2, child: _buildHeaderCell('From')),
                          Flexible(flex: 2, child: _buildHeaderCell('To')),
                          Flexible(flex: 2, child: _buildHeaderCell('Number of Days')),
                          Flexible(flex: 2, child: _buildHeaderCell('Status')),
                          Flexible(flex: 1, child: _buildHeaderCell('')),
                        ],
                      ),
                    ),
                    const Divider(height: 0),
                    // Scrollable Table Body
                    SizedBox(
                      height: 300, // Set a reasonable height for the table's scroll area
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: rebateHistory.length,
                        itemBuilder: (context, index) {
                          final rebate = rebateHistory[index];
                          final fromDate = DateTime.fromMillisecondsSinceEpoch(
                              rebate.start_date.seconds * 1000);
                          final toDate = DateTime.fromMillisecondsSinceEpoch(
                              rebate.end_date.seconds * 1000);
                          final days = toDate.difference(fromDate).inDays + 1;
                          final bgColor = index % 2 == 0
                              ? Colors.white
                              : Colors.grey.shade100;

                          return Container(
                            color: bgColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              children: [
                                Flexible(
                                  flex: 2,
                                  child: _buildBodyCell(
                                      "${fromDate.day}/${fromDate.month}/${fromDate.year}"),
                                ),
                                Flexible(
                                  flex: 2,
                                  child: _buildBodyCell(
                                      "${toDate.day}/${toDate.month}/${toDate.year}"),
                                ),
                                Flexible(
                                  flex: 2,
                                  child: _buildBodyCell(days.toString()),
                                ),
                                Flexible(
                                  flex: 2,
                                  child: _buildBodyCell(
                                    TextButton(
                                      onPressed: () {},
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all(
                                          rebate.status_
                                                      .toString()
                                                      .split('.')
                                                      .last
                                                      .toLowerCase() ==
                                                  "approve"
                                              ? Colors.green.withOpacity(0.2)
                                              : Colors.red.withOpacity(0.2),
                                        ),
                                        shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        padding: MaterialStateProperty.all(
                                          const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                        ),
                                      ),
                                      child: Text(
                                        rebate.status_
                                            .toString()
                                            .split('.')
                                            .last
                                            .toUpperCase(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: rebate.status_
                                                      .toString()
                                                      .split('.')
                                                      .last
                                                      .toLowerCase() ==
                                                  "approve"
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  flex: 1,
                                  child: _buildBodyCell(
                                    rebate.status_
                                                .toString()
                                                .split('.')
                                                .last
                                                .toLowerCase() !=
                                            "approve"
                                        ? IconButton(
                                            icon: Icon(Icons.delete, color: Color(0xFFF0753C)),
                                            tooltip: 'Delete pending request',
                                            onPressed: () => _deleteRebate(index, uid!),
                                          )
                                        : SizedBox.shrink(),
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildRebateChart() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            const Text(
              "YOUR REBATE SUMMARY",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            RebateSummaryCard(
              rebateDays: approvedRebates.fold(
                0,
                (sum, rebate) =>
                    sum +
                    ((rebate.end_date.seconds - rebate.start_date.seconds) ~/
                        86400) +
                    1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String label) {
    return Center(
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildBodyCell(dynamic content) {
    return Center(
      child: content is Widget
          ? content
          : Text(content.toString(), style: TextStyle(fontSize: 14)),
    );
  }
}

class RebateSummaryCard extends StatelessWidget {
  final int rebateDays;
  const RebateSummaryCard({super.key, required this.rebateDays});

  @override
  Widget build(BuildContext context) {
    int rebateAmount = rebateDays * 130;
    Color pieColor = const Color(0xFFE06635);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 150,
          width: 150,
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
        const SizedBox(height: 30),
        Text(
          '$rebateDays / 20 Days',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),
        const Text(
          'Your Rebate Amount',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        Text(
          '₹$rebateAmount',
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFFF0753C),
          ),
        ),
      ],
    );
  }
}
