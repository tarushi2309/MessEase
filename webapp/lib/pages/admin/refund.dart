import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:webapp/components/header_admin.dart';

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

// class RefundPage extends StatelessWidget {
//   const RefundPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(60),
//         child: Header(currentPage: 'Refund'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             const Text(
//               'Rebate Status',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 20),
//             Table(
//               border: TableBorder.all(),
//               columnWidths: const {
//                 0: FlexColumnWidth(2),
//                 1: FlexColumnWidth(2),
//                 2: FlexColumnWidth(2),
//                 3: FlexColumnWidth(2),
//               },
//               children: [
//                 _buildTableHeader(),
//                 _buildTableRow(context, 'Konark', 'John Doe', '120'),
//                 _buildTableRow(context, 'Anusha', 'Jane Smith', '95'),
//                 _buildTableRow(context, 'Ideal', 'Robert Brown', '80'),
//               ],
//             ),

//           ],
//         ),
//       ),
//     );
//   }

//   TableRow _buildTableHeader() {
//     return const TableRow(
//       children: [
//         TableCell(child: Padding(padding: EdgeInsets.all(8), child: Text('Mess Name', style: TextStyle(fontWeight: FontWeight.bold)))),
//         TableCell(child: Padding(padding: EdgeInsets.all(8), child: Text('Mess Manager', style: TextStyle(fontWeight: FontWeight.bold)))),
//         TableCell(child: Padding(padding: EdgeInsets.all(8), child: Text('Number of Students', style: TextStyle(fontWeight: FontWeight.bold)))),
//         TableCell(child: Padding(padding: EdgeInsets.all(8), child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold)))),
//       ],
//     );
//   }

//   TableRow _buildTableRow(BuildContext context, String messName, String manager, String studentCount) {
//     return TableRow(
//       children: [
//         TableCell(child: Padding(padding: const EdgeInsets.all(8), child: Text(messName))),
//         TableCell(child: Padding(padding: const EdgeInsets.all(8), child: Text(manager))),
//         TableCell(child: Padding(padding: const EdgeInsets.all(8), child: Text(studentCount))),
//         TableCell(
//           child: Padding(
//             padding: const EdgeInsets.all(8),
//             child: ElevatedButton(
//               onPressed: () {
//                 Navigator.pushNamed(
//                   context,
//                   '/rebate_history',
//                   arguments: messName,
//                 );
//               },
//               child: const Text('Check Details'),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

class RefundPage extends StatefulWidget {
  const RefundPage({super.key});

  @override
  State<RefundPage> createState() => _RefundPageState();
}

class _RefundPageState extends State<RefundPage> {

  late Future<List<RebateData>> _rebateHistory;
  String searchQuery = "";
  Map<String, bool> expandedRows = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _rebateHistory = fetchRebateHistory();
  }

  Future<List<RebateData>> fetchRebateHistory() async {
    final rebateQuery = await FirebaseFirestore.instance
        .collection('rebates')
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Header(currentPage: 'Refund'),
      ),
      body:
    );
  }
}
