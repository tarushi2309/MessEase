import 'package:flutter/material.dart';

import 'package:webapp/components/header_admin.dart';

class RefundPage extends StatelessWidget {
  const RefundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Header(currentPage: 'Refund'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Rebate Status',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Table(
              border: TableBorder.all(),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(2),
              },
              children: [
                _buildTableHeader(),
                _buildTableRow(context, 'Konark', 'John Doe', '120'),
                _buildTableRow(context, 'Anusha', 'Jane Smith', '95'),
                _buildTableRow(context, 'Ideal', 'Robert Brown', '80'),
              ],
            ),
            
          ],
        ),
      ),
    );
  }

  TableRow _buildTableHeader() {
    return const TableRow(
      children: [
        TableCell(child: Padding(padding: EdgeInsets.all(8), child: Text('Mess Name', style: TextStyle(fontWeight: FontWeight.bold)))),
        TableCell(child: Padding(padding: EdgeInsets.all(8), child: Text('Mess Manager', style: TextStyle(fontWeight: FontWeight.bold)))),
        TableCell(child: Padding(padding: EdgeInsets.all(8), child: Text('Number of Students', style: TextStyle(fontWeight: FontWeight.bold)))),
        TableCell(child: Padding(padding: EdgeInsets.all(8), child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold)))),
      ],
    );
  }

  TableRow _buildTableRow(BuildContext context, String messName, String manager, String studentCount) {
    return TableRow(
      children: [
        TableCell(child: Padding(padding: const EdgeInsets.all(8), child: Text(messName))),
        TableCell(child: Padding(padding: const EdgeInsets.all(8), child: Text(manager))),
        TableCell(child: Padding(padding: const EdgeInsets.all(8), child: Text(studentCount))),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/rebate_history',
                  arguments: messName,  
                );
              },
              child: const Text('Check Details'),
            ),
          ),
        ),
      ],
    );
  }
}
