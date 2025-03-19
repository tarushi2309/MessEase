import 'package:flutter/material.dart';
import '../../components/header_admin.dart'; // Import header

class RefundPage extends StatefulWidget {
  @override
  _RefundPageState createState() => _RefundPageState();
}

class _RefundPageState extends State<RefundPage> {
  List<Map<String, dynamic>> rebateRequests = [
    {"name": "John Doe", "rebateFrom": "01-Mar-2024", "rebateTo": "10-Mar-2024", "days": "10", "status": "Pending"},
    {"name": "Alice Smith", "rebateFrom": "05-Mar-2024", "rebateTo": "15-Mar-2024", "days": "11", "status": "Pending"},
    {"name": "Bob Johnson", "rebateFrom": "12-Mar-2024", "rebateTo": "20-Mar-2024", "days": "9", "status": "Approved"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Header(currentPage: "refund"), // Top Header
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Card(
                //color: Color(0xFFEEEEEE), // Light grey for a subtle look
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 10,
                shadowColor: Colors.black54,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Title inside a full-width container matching the table width
                      Container(
                        width: double.infinity, // Full width of the table
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade400,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            "REBATE REQUESTS",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Table structure
                      Table(
                        border: TableBorder.all(
                          color: Colors.grey.shade500,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(2),
                          2: FlexColumnWidth(2),
                          3: FlexColumnWidth(2),
                          4: FlexColumnWidth(2),
                        },
                        children: [
                          TableRow(
                            decoration: BoxDecoration(
                              //color: const Color(0xFFF0753C),
                              //color: Color(0xFF444444),
                              color: Colors.blueGrey.shade400,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            children: [
                              tableHeaderCell("NAME"),
                              tableHeaderCell("REBATE FROM"),
                              tableHeaderCell("REBATE TO"),
                              tableHeaderCell("NO. OF DAYS"),
                              tableHeaderCell("REBATE STATUS"),
                            ],
                          ),
                          ...rebateRequests.map((request) {
                            return TableRow(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                              ),
                              children: [
                                tableCell(request["name"]),
                                tableCell(request["rebateFrom"]),
                                tableCell(request["rebateTo"]),
                                tableCell(request["days"]),
                                statusCell(request["status"]),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget tableHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget tableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  Widget statusCell(String status) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: status == "Approved" ? Colors.green.shade400 : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: status == "Approved" ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
