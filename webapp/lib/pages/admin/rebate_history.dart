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
  final int bank_account_number;
  final String ifsc_code;
  final int refund;

  RebateData({
    required this.studentId,
    required this.name,
    required this.entryNumber,
    required this.year,
    required this.degree,
    required this.hostel,
    required this.numberOfDays,
    required this.bank_account_number,
    required this.ifsc_code,
    required this.refund,
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is String) {
      messName = args.toLowerCase();
    } else {
      messName = "Unknown";
    }
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
        
        if(uniqueStudentIds.contains(studentId)){
            continue;
        }

        uniqueStudentIds.add(studentId);
        
        final studentDoc = await FirebaseFirestore.instance
            .collection('students')
            .where('uid', isEqualTo: studentId)
            .get();

        final studentNameDoc = await FirebaseFirestore.instance
            .collection('user')
            .where('uid', isEqualTo: studentId)
            .get();

        final studentData =
            studentDoc.docs.isNotEmpty ? studentDoc.docs.first.data() : {};
        final studentNameData =
            studentNameDoc.docs.isNotEmpty ? studentNameDoc.docs.first.data() : {};

        rebateList.add(RebateData(
            studentId: studentId,
            name: studentNameData['name']?.toString() ?? 'Unknown',
            entryNumber: studentData['entryNumber']?.toString() ?? 'Unknown',
            year: studentData['year']?.toString() ?? 'Unknown',
            degree: studentData['degree']?.toString() ?? 'Unknown',
            hostel: rebateData['hostel']?.toString() ?? 'Unknown',
            numberOfDays: studentData['days_of_rebate'] ?? 0,
            bank_account_number: studentData['bank_account_number'] ?? 0,
            ifsc_code: studentData['ifsc_code']?.toString() ?? 'Unknown',
            refund: studentData['refund'] ?? 0,
        ));
    }
    return rebateList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rebate History - $messName')),
      body: FutureBuilder<List<RebateData>>(
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

          final rebates = snapshot.data!;
          return ListView.builder(
            itemCount: rebates.length,
            itemBuilder: (context, index) {
              final rebate = rebates[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name: ${rebate.name}',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Entry No: ${rebate.entryNumber}'),
                      Text('Year: ${rebate.year.toString()}'),
                      Text('Degree: ${rebate.degree}'),
                      Text('Hostel: ${rebate.hostel}'),
                      Text('Num of Days: ${rebate.numberOfDays.toString()}'),
                      Text('Refund: ${rebate.refund.toString()}'),
                      const SizedBox(height: 8),
                      const Text('Bank Details:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Account No: ${rebate.bank_account_number.toString()}'),
                      Text('IFSC: ${rebate.ifsc_code}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
