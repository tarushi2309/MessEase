import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RebateData {
  final String studentId;
  final String name;
  final String entryNumber;
  final String year;
  final String degree;
  final String hostel;
  final int numberOfDays;
  final int bankAccountNumber;
  final String ifscCode;
  final int refund;
  bool showBankDetails;

  RebateData({
    required this.studentId,
    required this.name,
    required this.entryNumber,
    required this.year,
    required this.degree,
    required this.hostel,
    required this.numberOfDays,
    required this.bankAccountNumber,
    required this.ifscCode,
    required this.refund,
    this.showBankDetails = false,
  });
}

class RebateHistoryPage extends StatefulWidget {
  const RebateHistoryPage({super.key});

  @override
  _RebateHistoryPageState createState() => _RebateHistoryPageState();
}

class _RebateHistoryPageState extends State<RebateHistoryPage> {
  late String messName;
  late Future<List<RebateData>> _rebateHistory;
  String searchQuery = "";
  Map<String, bool> expandedRows = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    messName = args is String ? args.toLowerCase() : "Unknown";
    _rebateHistory = fetchRebateHistory(messName);
  }

  Future<List<RebateData>> fetchRebateHistory(String messName) async {
    final rebateQuery = await FirebaseFirestore.instance
        .collection('rebates')
        .where('mess', isEqualTo: messName)
        .where('status', isEqualTo: 'approve')
        .get();

    final List<RebateData> rebateList = [];
    Set<String> uniqueStudentIds = {};

    for (final rebateDoc in rebateQuery.docs) {
      final rebateData = rebateDoc.data();
      final studentId = rebateData['student_id'] is String
          ? rebateData['student_id']
          : rebateData['student_id'].path.split('/').last;

      if (uniqueStudentIds.contains(studentId)) continue;
      uniqueStudentIds.add(studentId);

      final studentDoc = await FirebaseFirestore.instance
          .collection('students')
          .where('uid', isEqualTo: studentId)
          .get();
      final studentNameDoc = await FirebaseFirestore.instance
          .collection('user')
          .where('uid', isEqualTo: studentId)
          .get();

      final studentData = studentDoc.docs.isNotEmpty ? studentDoc.docs.first.data() : {};
      final studentNameData = studentNameDoc.docs.isNotEmpty ? studentNameDoc.docs.first.data() : {};

      rebateList.add(RebateData(
        studentId: studentId,
        name: studentNameData['name']?.toString() ?? 'Unknown',
        entryNumber: studentData['entryNumber']?.toString() ?? 'Unknown',
        year: studentData['year']?.toString() ?? 'Unknown',
        degree: studentData['degree']?.toString() ?? 'Unknown',
        hostel: rebateData['hostel']?.toString() ?? 'Unknown',
        numberOfDays: studentData['days_of_rebate'] ?? 0,
        bankAccountNumber: studentData['bank_account_number'] ?? 0,
        ifscCode: studentData['ifsc_code']?.toString() ?? 'Unknown',
        refund: studentData['refund'] ?? 0,
      ));
    }
    return rebateList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rebate History - $messName')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search by Name or Entry Number',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() => searchQuery = value.toLowerCase());
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<RebateData>>(
              future: _rebateHistory,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No rebate records found.'));
                }

                final rebates = snapshot.data!.where((rebate) {
                  return rebate.name.toLowerCase().contains(searchQuery) ||
                      rebate.entryNumber.toLowerCase().contains(searchQuery);
                }).toList();

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Entry No')),
                      DataColumn(label: Text('Year')),
                      DataColumn(label: Text('Degree')),
                      DataColumn(label: Text('Hostel')),
                      DataColumn(label: Text('Num of Days')),
                      DataColumn(label: Text('Refund')),
                      DataColumn(label: Text('Bank Details')),
                    ],
                    rows: rebates.map((rebate) {
                      return DataRow(
                        cells: [
                          DataCell(Text(rebate.name)),
                          DataCell(Text(rebate.entryNumber)),
                          DataCell(Text(rebate.year.toString())),
                          DataCell(Text(rebate.degree)),
                          DataCell(Text(rebate.hostel)),
                          DataCell(Text(rebate.numberOfDays.toString())),
                          DataCell(Text(rebate.refund.toString())),
                          DataCell(
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  rebate.showBankDetails = !rebate.showBankDetails;
                                });
                              },
                              child: Text(rebate.showBankDetails ? "Hide" : "Show"),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
