import 'package:flutter/material.dart';
import 'package:webapp/components/header_boha.dart';

class MessCommitteePage extends StatelessWidget {
  const MessCommitteePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Header(currentPage: 'Mess Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Mess Committee',
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
                _buildTableRow(context, 'Konark', 'John Doe', '5'),
                _buildTableRow(context, 'Anusha', 'Jane Smith', '5'),
                _buildTableRow(context, 'Ideal', 'Robert Brown', '5'),
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
        TableCell(child: Padding(padding: EdgeInsets.all(8), child: Text('Mess Committee', style: TextStyle(fontWeight: FontWeight.bold)))),
        TableCell(child: Padding(padding: EdgeInsets.all(8), child: Text('Feedbacks', style: TextStyle(fontWeight: FontWeight.bold)))),
      ],
    );
  }

  TableRow _buildTableRow(BuildContext context, String messName, String manager, String studentCount) {
    return TableRow(
      children: [
        TableCell(child: Padding(padding: const EdgeInsets.all(8), child: Text(messName))),
        TableCell(child: Padding(padding: const EdgeInsets.all(8), child: Text(manager))),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/mess_committee_boha',
                  arguments: messName,  
                );
              },
              child: const Text('Check Details'),
            ),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/feedback',
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
