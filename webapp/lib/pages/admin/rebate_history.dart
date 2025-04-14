import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webapp/components/header_admin.dart';
import 'package:webapp/models/processed_rebate.dart';
import 'package:webapp/services/notification.dart';
import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:typed_data';

Future<void> _exportToExcel(List<ProcessedRebate> rebateList) async {
  final excel = Excel.createExcel();
  final sheet = excel['ProcessedRebate'];

  // Add header row
  sheet.appendRow([
    'Name',
    'Entry Number',
    'Year',
    'Mess',
    'Degree',
    'Days',
    'Refund (₹)',
    'Bank Account Number',
    'IFSC Code',
    'Email',
    'Status'
  ]);

  // Add data rows
  for (final r in rebateList) {
    sheet.appendRow([
      r.name,
      r.entryNumber,
      r.year,
      r.mess,
      r.degree,
      r.numberOfDays,
      r.refund,
      r.bankAccountNumber,
      r.ifscCode,
      r.email,
      r.status
    ]);
  }

  // Convert to bytes
  final fileBytes = excel.encode();

  // For web, trigger download
  final blob = html.Blob([fileBytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', 'rebate_data.xlsx')
    ..click();
  html.Url.revokeObjectUrl(url);
}

class RebateHistoryProcessedPage extends StatefulWidget {
  const RebateHistoryProcessedPage({super.key});
  @override
  State<RebateHistoryProcessedPage> createState() => _RebateHistoryProcessedPageState();
}

class _RebateHistoryProcessedPageState extends State<RebateHistoryProcessedPage> {
  List<ProcessedRebate> _rows = [];
  bool _loadingRows = true;

  // Filters & sorting
  String searchQuery = '';
  String selectedYear = 'All';
  String selectedMess = 'All';
  int? minDays;
  int? maxDays;
  String sortDir = 'Asc';

  late final List<String> yearOptions = (() {
    final now = DateTime.now().year;
    return <String>['All', ...List.generate(10, (i) => (now - i).toString())];
  })();

  late final List<String> messOptions = (() {
    return <String>['All', 'konark', 'anusha', 'ideal'];
  })();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    fetchProcessedRebateHistory().then((list) {
      setState(() {
        _rows = list;
        _loadingRows = false;
      });
    });
  }

  Future<List<ProcessedRebate>> fetchProcessedRebateHistory() async {
    //print("fetching rebate history");
    final rebateQuery = await FirebaseFirestore.instance
        .collection('processed_rebates')
        .get();

    final List<ProcessedRebate> rebateList = [];
    for (final rebateDoc in rebateQuery.docs) {
      final data = rebateDoc.data();
      final docId = rebateDoc.id;
      rebateList.add(ProcessedRebate(
        docId: docId,
        studentId: data['uid']?.toString() ?? 'Unknown',
        name: data['name']?.toString() ?? 'Unknown',
        entryNumber: data['entryNumber']?.toString() ?? 'Unknown',
        year: data['year']?.toString() ?? 'Unknown',
        mess: data['mess']?.toString() ?? 'Unknown',
        degree: data['degree']?.toString() ?? 'Unknown',
        numberOfDays: data['numberOfDays'] ?? 0,
        bankAccountNumber:
            data['bankAccountNumber']?.toString() ?? 'Unknown',
        ifscCode: data['ifscCode']?.toString() ?? 'Unknown',
        refund: data['refund'] ?? 0,
        email: data['email']?.toString() ?? 'Unknown',
        status: data['status']?.toString() ?? 'Pending',
      ));
    }
    return rebateList;
  }

  List<ProcessedRebate> _applyFilters(List<ProcessedRebate> list) {
    final q = searchQuery.toLowerCase();
    final rows = list.where((r) {
      final okQ = r.name.toLowerCase().contains(q) ||
          r.entryNumber.toLowerCase().contains(q);
      final okY = selectedYear == 'All' || r.year == selectedYear;
      final okM = selectedMess == 'All' || r.mess == selectedMess;
      final okMin = minDays == null || r.numberOfDays >= minDays!;
      final okMax = maxDays == null || r.numberOfDays <= maxDays!;
      return okQ && okY && okM && okMin && okMax;
    }).toList();

    rows.sort((a, b) => sortDir == 'Asc'
        ? a.numberOfDays.compareTo(b.numberOfDays)
        : b.numberOfDays.compareTo(a.numberOfDays));
    return rows;
  }

  void _clearFilters() => setState(() {
        searchQuery = '';
        selectedYear = 'All';
        selectedMess = 'All';
        minDays = null;
        maxDays = null;
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: Header(currentPage: 'Processed Refund'),
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
                      'Processed Mess Refunds',
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
                    value: sortDir,
                    items: const [
                      DropdownMenuItem(value: 'Asc', child: Text('Days ↑')),
                      DropdownMenuItem(value: 'Desc', child: Text('Days ↓')),
                    ],
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 14)),
                    onChanged: (v) => setState(() => sortDir = v ?? 'Asc'),
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
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    value: selectedYear,
                    items: yearOptions
                        .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                        .toList(),
                    decoration: const InputDecoration(
                        labelText: 'Year', border: OutlineInputBorder()),
                    onChanged: (v) => setState(() => selectedYear = v ?? 'All'),
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
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.notifications, color: Colors.white),
                    label: const Text(
                      'Send notification to Process payment',
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
                        //selecting date till when complain can be made
                        final DateTime? selectedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days:30)),
                        );

                        if (selectedDate == null) return;

                        final String formattedDate =
                            "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";

                        final String message =
                            "The rebate for this semester has been processed. Please check you bank accounts and report any discrepancy to admin by $formattedDate";

                        // await NotificationService.sendNotificationToApp(message);

                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Notification sent to app')),
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
        child: Container(
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
                      _buildHeaderCell('Year'),
                      _buildHeaderCell('Mess'),
                      _buildHeaderCell('Degree'),
                      _buildHeaderCell('Days'),
                      _buildHeaderCell('Amount'),
                      _buildHeaderCell('Account Number'),
                      _buildHeaderCell('IFSC Code'),
                      _buildHeaderCell('Status'),
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
                              child: Text('No rebate records.'),
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
                                    _buildBodyCell(r.year),
                                    _buildBodyCell(r.mess),
                                    _buildBodyCell(r.degree),
                                    _buildBodyCell(r.numberOfDays),
                                    _buildBodyCell('₹${r.refund}'),
                                    _buildBodyCell(r.bankAccountNumber),
                                    _buildBodyCell(r.ifscCode),
                                     _buildBodyCell(r.status),
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
