import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webapp/components/header_admin.dart';
import 'package:webapp/services/notification.dart';
import 'package:webapp/models/processed_rebate.dart';
import 'package:excel/excel.dart';
import 'package:universal_html/html.dart' as html;
import 'package:shared_preferences/shared_preferences.dart';

class RebateData {
  final String docId;
  final String studentId;
  final String name;
  final String entryNumber;
  final String year;
  final String degree;
  final int totalNumberOfDays;
  final int rebateDays;
  final int hostelLeavingDays;
  String bankAccountNumber;
  final String ifscCode;
  final int refund;
  final String email;
  final String status;

  RebateData({
    required this.docId,
    required this.studentId,
    required this.name,
    required this.entryNumber,
    required this.year,
    required this.degree,
    required this.totalNumberOfDays,
    required this.rebateDays,
    required this.hostelLeavingDays,
    required this.bankAccountNumber,
    required this.ifscCode,
    required this.refund,
    required this.email,
    required this.status,
  });
}

Future<void> _exportToExcel(List<RebateData> rebateList) async {
  final excel = Excel.createExcel();
  final sheet = excel['RebateData'];
  sheet.appendRow([
    'Name',
    'Entry Number',
    'Year',
    'Degree',
    'Rebate Days',
    'Hostel Leaving Days',
    'Total Days',
    'Refund (₹)',
    'Bank Account Number',
    'IFSC Code',
    'Email',
    'Status'
  ]);
  for (final r in rebateList) {
    sheet.appendRow([
      r.name,
      r.entryNumber,
      r.year,
      r.degree,
      r.rebateDays,
      r.hostelLeavingDays,
      r.totalNumberOfDays,
      r.refund,
      r.bankAccountNumber,
      r.ifscCode,
      r.email,
      r.status
    ]);
  }
  final fileBytes = excel.encode();
  final blob = html.Blob([fileBytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', 'rebate_data.xlsx')
    ..click();
  html.Url.revokeObjectUrl(url);
}

class RebateHistoryPage extends StatefulWidget {
  const RebateHistoryPage({super.key});
  @override
  State<RebateHistoryPage> createState() => _RebateHistoryPageState();
}

class _RebateHistoryPageState extends State<RebateHistoryPage> {
  String? messName;
  List<RebateData> _rows = [];
  bool _loadingRows = true;

  String searchQuery = '';
  String selectedYear = 'All';
  int? minDays;
  int? maxDays;
  String sortDir = 'Asc';

  late final List<String> yearOptions = (() {
    final now = DateTime.now().year;
    return <String>['All', ...List.generate(10, (i) => (now - i).toString())];
  })();

  @override
  void initState() {
    super.initState();
    _initMessNameAndFetch();
  }

  Future<void> _initMessNameAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    // Try to get messName from route arguments (if any)
    final ModalRoute? route = ModalRoute.of(context);
    String? argMessName;
    if (route != null && route.settings.arguments != null) {
      final args = route.settings.arguments;
      argMessName = args is String ? args.toLowerCase() : null;
    }
    // If not in arguments, get from SharedPreferences
    String? savedMessName = prefs.getString('messName');
    messName = argMessName ?? savedMessName;
    if (messName == null) {
      messName = 'unknown';
    }
    // Save messName for persistence
    await prefs.setString('messName', messName!);
    await _fetchRows();
  }

  Future<void> _fetchRows() async {
    setState(() {
      _loadingRows = true;
    });
    final list = await fetchRebateHistory(messName!);
    setState(() {
      _rows = list;
      _loadingRows = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // If the widget is rebuilt (e.g. after browser refresh), re-init messName and fetch
    _initMessNameAndFetch();
  }

  Future<List<RebateData>> fetchRebateHistory(String messName) async {
    final rebateQuery = await FirebaseFirestore.instance
        .collection('students')
        .where('mess', isEqualTo: messName)
        .where('refund', isGreaterThan: 0)
        .get();

    final List<RebateData> rebateList = [];
    for (final rebateDoc in rebateQuery.docs) {
      final data = rebateDoc.data();
      final docId = rebateDoc.id;
      final studentId = data['uid'] is String
          ? data['uid']
          : data['uid'].path.split('/').last;

      final studentSnap = await FirebaseFirestore.instance
          .collection('students')
          .where('uid', isEqualTo: studentId)
          .get();

      final studentData =
          studentSnap.docs.isNotEmpty ? studentSnap.docs.first.data() : {};

      int rebateDays = studentData['days_of_rebate'] ?? 0;
      int hostelLeavingDays = studentData['hostel_leaving_days'] ?? 0;
      int totalNumberOfDays = rebateDays + hostelLeavingDays;

      rebateList.add(RebateData(
        docId: docId,
        studentId: studentId,
        name: studentData['name']?.toString() ?? 'Unknown',
        entryNumber: studentData['entryNumber']?.toString() ?? 'Unknown',
        year: studentData['year']?.toString() ?? 'Unknown',
        degree: studentData['degree']?.toString() ?? 'Unknown',
        rebateDays: rebateDays,
        hostelLeavingDays: hostelLeavingDays,
        totalNumberOfDays: totalNumberOfDays,
        bankAccountNumber: studentData['bank_account_number']?.toString() ?? 'Unknown',
        ifscCode: studentData['ifsc_code']?.toString() ?? 'Unknown',
        refund: studentData['refund'] ?? 0,
        email: studentData['email']?.toString() ?? 'Unknown',
        status: data['status']?.toString() ?? 'Pending',
      ));
    }
    return rebateList;
  }

  List<RebateData> _applyFilters(List<RebateData> list) {
    final q = searchQuery.toLowerCase();
    final rows = list.where((r) {
      final okQ = r.name.toLowerCase().contains(q) ||
          r.entryNumber.toLowerCase().contains(q);
      final okY = selectedYear == 'All' || r.year == selectedYear;
      final okMin = minDays == null || r.totalNumberOfDays >= minDays!;
      final okMax = maxDays == null || r.totalNumberOfDays <= maxDays!;
      return okQ && okY && okMin && okMax;
    }).toList();

    rows.sort((a, b) => sortDir == 'Asc'
        ? a.totalNumberOfDays.compareTo(b.totalNumberOfDays)
        : b.totalNumberOfDays.compareTo(a.totalNumberOfDays));
    return rows;
  }

  void _clearFilters() => setState(() {
        searchQuery = '';
        selectedYear = 'All';
        minDays = null;
        maxDays = null;
      });

  @override
  Widget build(BuildContext context) {
    final displayMessName = messName == null || messName == 'unknown'
        ? 'Mess'
        : '${messName![0].toUpperCase()}${messName!.substring(1)} Mess';
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: Header(currentPage: 'Refund'),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // filter row
            LayoutBuilder(
              builder: (context, constraints) {
                final isSmallScreen = constraints.maxWidth < 800;
                return isSmallScreen
                    ? Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          SizedBox(
                            width: constraints.maxWidth * 0.9,
                            child: Text(
                              displayMessName + ' Refunds',
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87),
                            ),
                          ),
                          SizedBox(
                            width: constraints.maxWidth * 0.9,
                            child: TextField(
                              decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.search),
                                  labelText: 'Search by Name or Entry Number',
                                  border: OutlineInputBorder()),
                              onChanged: (v) => setState(() => searchQuery = v),
                            ),
                          ),
                          SizedBox(
                            width: constraints.maxWidth * 0.45,
                            child: DropdownButtonFormField<String>(
                              value: sortDir,
                              items: const [
                                DropdownMenuItem(
                                    value: 'Asc', child: Text('Days ↑')),
                                DropdownMenuItem(
                                    value: 'Desc', child: Text('Days ↓')),
                              ],
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 14)),
                              onChanged: (v) => setState(() => sortDir = v ?? 'Asc'),
                            ),
                          ),
                          SizedBox(
                            width: constraints.maxWidth * 0.45,
                            child: DropdownButtonFormField<String>(
                              value: selectedYear,
                              items: yearOptions
                                  .map((y) => DropdownMenuItem(
                                      value: y, child: Text(y)))
                                  .toList(),
                              decoration: const InputDecoration(
                                  labelText: 'Year',
                                  border: OutlineInputBorder()),
                              onChanged: (v) =>
                                  setState(() => selectedYear = v ?? 'All'),
                            ),
                          ),
                          TextButton(
                              onPressed: _clearFilters,
                              child: const Text('Clear')),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                              child: Text(
                                displayMessName + ' Refunds',
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
                                DropdownMenuItem(
                                    value: 'Asc', child: Text('Days ↑')),
                                DropdownMenuItem(
                                    value: 'Desc', child: Text('Days ↓')),
                              ],
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 14)),
                              onChanged: (v) => setState(() => sortDir = v ?? 'Asc'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 1,
                            child: DropdownButtonFormField<String>(
                              value: selectedYear,
                              items: yearOptions
                                  .map((y) => DropdownMenuItem(
                                      value: y, child: Text(y)))
                                  .toList(),
                              decoration: const InputDecoration(
                                  labelText: 'Year',
                                  border: OutlineInputBorder()),
                              onChanged: (v) =>
                                  setState(() => selectedYear = v ?? 'All'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          TextButton(
                              onPressed: _clearFilters,
                              child: const Text('Clear')),
                        ],
                      );
              },
            ),
            const SizedBox(height: 16),
            // The table
            Expanded(
              child: _loadingRows
                  ? const Center(child: CircularProgressIndicator())
                  : _buildTable(),
            ),
            const SizedBox(height: 12),
            // Responsive button row
            LayoutBuilder(
              builder: (context, constraints) {
                final isSmall = constraints.maxWidth < 600;
                final children = [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.download, color: Colors.white),
                    label: const Text(
                      'Export to Excel',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all<Color>(Color(0xFFF0753C)),
                      padding: WidgetStateProperty.all<EdgeInsets>(
                          const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20)),
                      shape: WidgetStateProperty.all<OutlinedBorder>(
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
                  isSmall ? const SizedBox(height: 8) : const SizedBox(width: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.notifications, color: Colors.white),
                    label: const Text(
                      'Send notification to Process payment',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all<Color>(Color(0xFFF0753C)),
                      padding: WidgetStateProperty.all<EdgeInsets>(
                          const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20)),
                      shape: WidgetStateProperty.all<OutlinedBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    onPressed: () async {
                      final DateTime? selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 60)),
                      );
                      if (selectedDate == null) return;
                      final String formattedDate =
                          "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
                      if (_rows.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('No students to notify')));
                        return;
                      }
                      final emails = _rows.map((r) => r.email).toList();
                      final subject =
                          'MessEase: Reminder to update your payment details';
                      final body = '''
Dear Student,

"We are processing the rebates for this semester, check your bank details and change them before this $formattedDate. No requests will be entertained later.";

Thanks,
MessEase Admin
                  ''';
                      try {
                        await sendMailViaGAS(
                            to: emails, subject: subject, body: body);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Notification sent to ${emails.length} students')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Failed to send notifications')),
                        );
                      }
                    },
                  ),
                ];
                return isSmall
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: children,
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: children,
                      );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTable() {
    final rows = _applyFilters(_rows);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 1200,
        child: Card(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              // Header
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
                    _buildHeaderCell('Rebate Days'),
                    _buildHeaderCell('Hostel Leaving Days'),
                    _buildHeaderCell('Total Days'),
                    _buildHeaderCell('Amount'),
                    _buildHeaderCell('Account Number'),
                    _buildHeaderCell('IFSC Code'),
                    _buildHeaderCell('Actions'),
                  ],
                ),
              ),
              // Body
              rows.isEmpty
                  ? Expanded(
                      child: Container(
                        color: Colors.grey[50],
                        child: const Center(
                          child: Text('No rebate records.'),
                        ),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
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
                                _buildBodyCell(r.rebateDays),
                                _buildBodyCell(r.hostelLeavingDays),
                                _buildBodyCell(r.totalNumberOfDays),
                                _buildBodyCell('₹${r.refund}'),
                                _buildBodyCell(r.bankAccountNumber),
                                _buildBodyCell(r.ifscCode),
                                Expanded(
                                  child: Center(
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor:
                                            const Color(0xFFF0753C),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                      ),
                                      onPressed: () async {
                                        try {
                                          final processedRebate =
                                              ProcessedRebate(
                                            docId: r.docId,
                                            studentId: r.studentId,
                                            name: r.name,
                                            entryNumber: r.entryNumber,
                                            year: r.year,
                                            mess: messName!,
                                            degree: r.degree,
                                            numberOfDays: r.totalNumberOfDays,
                                            bankAccountNumber:
                                                r.bankAccountNumber,
                                            ifscCode: r.ifscCode,
                                            refund: r.refund,
                                            email: r.email,
                                            status: 'processed',
                                          );
                                          await FirebaseFirestore.instance
                                              .collection('processed_rebates')
                                              .doc(r.docId)
                                              .set(processedRebate.toJson());
                                          setState(() {
                                            _rows.removeWhere(
                                                (e) => e.docId == r.docId);
                                          });
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content: Text(
                                                      'Rebate marked as processed')));
                                        } catch (e) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content: Text(
                                                      'Failed to process rebate')));
                                        }
                                      },
                                      child: const Text('Process'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
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
