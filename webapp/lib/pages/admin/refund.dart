import 'package:flutter/material.dart';

class RefundPage extends StatefulWidget {
  @override
  _RefundPageState createState() => _RefundPageState();
}

class _RefundPageState extends State<RefundPage> {
  // Sample data: List of students and their rebate details
  List<Map<String, dynamic>> rebateRequests = [
    {
      "name": "John Doe",
      "rebateFrom": "01-Mar-2024",
      "rebateTo": "10-Mar-2024",
      "days": "10",
      "status": "Pending"
    },
    {
      "name": "Alice Smith",
      "rebateFrom": "05-Mar-2024",
      "rebateTo": "15-Mar-2024",
      "days": "11",
      "status": "Pending"
    },
    {
      "name": "Bob Johnson",
      "rebateFrom": "12-Mar-2024",
      "rebateTo": "20-Mar-2024",
      "days": "9",
      "status": "Approved"
    },
  ];

  void updateStatus(int index, String newStatus) {
    setState(() {
      rebateRequests[index]["status"] = newStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Rebate Requests",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Table structure
            Table(
              border: TableBorder.all(color: Colors.black),
              columnWidths: const {
                0: FlexColumnWidth(2), // Name column
                1: FlexColumnWidth(2), // Rebate From
                2: FlexColumnWidth(2), // Rebate To
                3: FlexColumnWidth(2), // Number of Days
                4: FlexColumnWidth(2), // Status column
              },
              children: [
                // Table header
                TableRow(
                  decoration: BoxDecoration(color: Colors.orange.shade300),
                  children: [
                    tableHeaderCell("NAME"),
                    tableHeaderCell("REBATE FROM"),
                    tableHeaderCell("REBATE TO"),
                    tableHeaderCell("NO. OF DAYS"),
                    tableHeaderCell("REBATE STATUS"),
                  ],
                ),
                // Table rows with data
                ...rebateRequests.asMap().entries.map((entry) {
                  int index = entry.key;
                  var request = entry.value;
                  return TableRow(
                    decoration: BoxDecoration(color: Colors.grey.shade100),
                    children: [
                      tableCell(request["name"]),
                      tableCell(request["rebateFrom"]),
                      tableCell(request["rebateTo"]),
                      tableCell(request["days"]),
                      statusDropdown(index, request["status"]),
                    ],
                  );
                }).toList(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget for table header cell
  Widget tableHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  // Widget for table data cell
  Widget tableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
      ),
    );
  }

  // Dropdown for status selection with background color change
  Widget statusDropdown(int index, String currentStatus) {
    return Container(
      color: currentStatus == "Approved" ? Colors.green.shade300 : Colors.transparent, // Turns green when Approved
      padding: const EdgeInsets.all(8.0),
      child: DropdownButton<String>(
        value: currentStatus,
        onChanged: (String? newValue) {
          if (newValue != null) {
            updateStatus(index, newValue);
          }
        },
        items: ["Pending", "Approved"].map<DropdownMenuItem<String>>((String status) {
          return DropdownMenuItem<String>(
            value: status,
            child: Text(status),
          );
        }).toList(),
      ),
    );
  }
}
