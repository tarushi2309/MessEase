import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webapp/components/header_admin.dart';
import 'package:webapp/services/notification.dart';
import 'package:webapp/models/processed_rebate.dart';
import 'package:webapp/models/rebate_days.dart';
import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:typed_data';

class HostelLeavingData {
  final String docId;
  final String studentId;
  final String name;
  final String entryNumber;
  final String mess;
  final int numberOfDays;
  final Timestamp selectedDate;

  HostelLeavingData({
    required this.docId,
    required this.studentId,
    required this.name,
    required this.entryNumber,
    required this.mess,
    required this.numberOfDays,
    required this.selectedDate,
  });
}

Future<void> _exportToExcel(List<HostelLeavingData> hostelLeavingList) async {
  final excel = Excel.createExcel();
  final sheet = excel['HostelLeavingData'];

  // Add header row
  sheet.appendRow([
    'Name',
    'Entry Number',
    'Mess',
    'Number of Days',
    'Date of Leaving'
  ]);

  // Add data rows
  for (final r in hostelLeavingList) {
    sheet.appendRow([
      r.name,
      r.entryNumber,
      r.mess,
      r.numberOfDays,
      r.selectedDate,
    ]);
  }

  // Convert to bytes
  final fileBytes = excel.encode();

  // For web, trigger download
  final blob = html.Blob([fileBytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', 'hostel_leaving_data.xlsx')
    ..click();
  html.Url.revokeObjectUrl(url);
}

class HostelLeavingPage extends StatefulWidget {
  const HostelLeavingPage({super.key});
  @override
  State<HostelLeavingPage> createState() => _HostelLeavingPageState();
}

class _HostelLeavingPageState extends State<HostelLeavingPage> {
  List<HostelLeavingData> _rows = [];
  bool _loadingRows = true;

  // Filters & sorting
  String searchQuery = '';
  String selectedMess = 'All';
  String sortDir = 'Asc';

  late final List<String> messOptions = (() {
    return <String>['All', 'Konark', 'Anusha', 'Ideal'];
  })();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchHostelLeaving().then((list) {
      setState(() {
        _rows = list;
        _loadingRows = false;
      });
    });
  }

Future<List<HostelLeavingData>> fetchHostelLeaving() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('hostel_leaving_data')
        .get();

    final List<HostelLeavingData> hostelLeavingList = [];

    for (final doc in querySnapshot.docs) {
        final data = doc.data();

        hostelLeavingList.add(
            HostelLeavingData(
                docId: doc.id,
                studentId: data['studentId'] ?? '',
                name: data['name'] ?? '',
                entryNumber: data['entryNumber'] ?? '',
                mess: data['mess'] ?? '',
                numberOfDays: 0,
                selectedDate: data['selectedDate'] ?? Timestamp.now(),
            ),
        );
    }

    return hostelLeavingList;
}


  List<HostelLeavingData> _applyFilters(List<HostelLeavingData> list) {
    final q = searchQuery.toLowerCase();
    final rows = list.where((r) {
      final okQ = r.name.toLowerCase().contains(q) ||
          r.entryNumber.toLowerCase().contains(q);
      final okY = selectedMess == 'All' || r.mess == selectedMess;
      return okQ && okY;
    }).toList();

    rows.sort((a, b) => sortDir == 'Asc'
        ? a.numberOfDays.compareTo(b.numberOfDays)
        : b.numberOfDays.compareTo(a.numberOfDays));
    return rows;
  }

  void _clearFilters() => setState(() {
        searchQuery = '';
        selectedMess = 'All';
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: Header(currentPage: 'Hostel Leaving'),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // filter row
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Text(
                      'Hostel Leaving Data',
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: TextField(
                    decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        labelText: 'Search by Name or Entry Number',
                        border: OutlineInputBorder()),
                    onChanged: (v) => setState(() => searchQuery = v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    value: selectedMess,
                    items: messOptions
                        .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                        .toList(),
                    decoration: const InputDecoration(
                        labelText: 'Mess', border: OutlineInputBorder()),
                    onChanged: (v) => setState(() => selectedMess = v ?? 'All'),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(onPressed: _clearFilters, child: const Text('Clear')),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _loadingRows
                  ? const Center(child: CircularProgressIndicator())
                  : _buildTable(),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.download, color: Colors.white),
                    label: const Text(
                      'Export to Excel',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Color(0xFFF0753C)),
                      padding: MaterialStateProperty.all<EdgeInsets>(
                          const EdgeInsets.symmetric(vertical: 12, horizontal: 20)),
                      shape: MaterialStateProperty.all<OutlinedBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    onPressed: () async {
                      final filteredList = _applyFilters(_rows);
                      if (filteredList.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No data to export')),
                        );
                        return;
                      }

                      await _exportToExcel(filteredList);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Export successful')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTable() {
    final rows = _applyFilters(_rows);

    return LayoutBuilder(builder: (context, constraints) {
      final tableWidth = MediaQuery.of(context).size.width * 0.95;
      return Center(
        child: SizedBox(
          width: tableWidth,
          child: Card(
            color: Colors.white,
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                // header strip (always shown)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                  child: Row(
                    children: [
                      _buildHeaderCell('Name'),
                      _buildHeaderCell('Entry Number'),
                      _buildHeaderCell('Mess'),
                      _buildHeaderCell('Date of Leaving'),
                      _buildHeaderCell('Number of Refund Days Added'),
                    ],
                  ),
                ),
                // body (empty state or rows)
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    child: rows.isEmpty
                        ? Container(
                            color: Colors.grey[50],
                            child: const Center(
                              child: Text('No records.'),
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: rows.length,
                            itemBuilder: (context, index) {
                              final r = rows[index];
                              final rowColor = index.isEven
                                  ? Colors.grey[50]
                                  : Colors.grey[100];
                              return Container(
                                color: rowColor,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 8),
                                child: Row(
                                  children: [
                                    _buildBodyCell(r.name),
                                    _buildBodyCell(r.entryNumber),
                                    _buildBodyCell(r.mess),
                                    _buildBodyCell(r.selectedDate),
                                    _buildBodyCell(r.numberOfDays),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildHeaderCell(String label) => Expanded(
        child: Center(
          child: Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.black87)),
        ),
      );

  Widget _buildBodyCell(dynamic content) => Expanded(
        child: Center(
          child: content is Widget
              ? content
              : Text(content.toString(),
                  style: const TextStyle(fontSize: 14)),
        ),
      );
}
