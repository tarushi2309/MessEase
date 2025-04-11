import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webapp/components/header_admin.dart';

class RebateData {
  final String docId;
  final String studentId;
  final String name;
  final String entryNumber;
  final String year;
  final String degree;
  final int numberOfDays;
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
    required this.numberOfDays,
    required this.bankAccountNumber,
    required this.ifscCode,
    required this.refund,
    required this.email,
    required this.status,
  });
}

class RebateHistoryPage extends StatefulWidget {
  const RebateHistoryPage({super.key});
  @override
  State<RebateHistoryPage> createState() => _RebateHistoryPageState();
}

class _RebateHistoryPageState extends State<RebateHistoryPage> {
  late String messName;
  List<RebateData> _rows = [];
  bool _loadingRows = true;

  // Filters & sorting
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    messName = args is String ? args.toLowerCase() : 'unknown';
    fetchRebateHistory(messName).then((list) {
      setState(() {
        _rows = list;
        _loadingRows = false;
      });
    });
  }

  Future<List<RebateData>> fetchRebateHistory(String messName) async {
    final rebateQuery = await FirebaseFirestore.instance
        .collection('rebates')
        .where('mess', isEqualTo: messName)
        .get();

    final List<RebateData> rebateList = [];
    for (final rebateDoc in rebateQuery.docs) {
      final data = rebateDoc.data();
      final docId = rebateDoc.id;
      final studentId = data['student_id'] is String
          ? data['student_id']
          : data['student_id'].path.split('/').last;

      final studentSnap = await FirebaseFirestore.instance
          .collection('students')
          .where('uid', isEqualTo: studentId)
          .get();
      final userSnap = await FirebaseFirestore.instance
          .collection('user')
          .where('uid', isEqualTo: studentId)
          .get();

      final studentData =
          studentSnap.docs.isNotEmpty ? studentSnap.docs.first.data() : {};
      final userData = userSnap.docs.isNotEmpty ? userSnap.docs.first.data() : {};

      rebateList.add(RebateData(
        docId: docId,
        studentId: studentId,
        name: userData['name']?.toString() ?? 'Unknown',
        entryNumber: studentData['entryNumber']?.toString() ?? 'Unknown',
        year: studentData['year']?.toString() ?? 'Unknown',
        degree: studentData['degree']?.toString() ?? 'Unknown',
        numberOfDays: studentData['days_of_rebate'] ?? 0,
        bankAccountNumber:
            studentData['bank_account_number']?.toString() ?? 'Unknown',
        ifscCode: studentData['ifsc_code']?.toString() ?? 'Unknown',
        refund: studentData['refund'] ?? 0,
        email: userData['email']?.toString() ?? 'Unknown',
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
      final okMin = minDays == null || r.numberOfDays >= minDays!;
      final okMax = maxDays == null || r.numberOfDays <= maxDays!;
      return okQ && okY && okMin && okMax;
    }).toList();

    rows.sort((a, b) => sortDir == 'Asc'
        ? a.numberOfDays.compareTo(b.numberOfDays)
        : b.numberOfDays.compareTo(a.numberOfDays));
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
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Text(
                      '${messName[0].toUpperCase()}${messName.substring(1)} Mess Refunds',
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
            // always-visible export button
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.download, color: Colors.white),
                  label: const Text('Export to Excel',
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(const Color(0xFFF0753C)),
                    padding: MaterialStateProperty.all<EdgeInsets>(
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 20)),
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Export to Excel clicked')),
                    );
                  },
                ),
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
                      _buildHeaderCell('Days'),
                      _buildHeaderCell('Amount'),
                      _buildHeaderCell('Account Number'),
                      _buildHeaderCell('IFSC Code'),
                      _buildHeaderCell('Actions'),
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
                                    _buildBodyCell(r.numberOfDays),
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
                                          onPressed: () {
                                            setState(() {
                                              _rows.removeWhere(
                                                  (e) => e.docId == r.docId);
                                            });
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
