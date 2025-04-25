import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webapp/components/header_boha.dart';
import '../../components/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class FeedbackModelUI {
  final String text;
  final String? imageUrl;
  final DateTime timestamp;
  final String uid;
  final String studentName;
  final String studentEntryNum;
  final String studentEmail;
  final String meal; // always lowercase

  FeedbackModelUI({
    required this.text,
    required this.timestamp,
    required this.uid,
    required this.studentName,
    required this.studentEntryNum,
    required this.studentEmail,
    this.imageUrl,
    required this.meal,
  });
}
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});
  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  Future<List<FeedbackModelUI>>? _feedbacksFuture;
  bool _loadingRows = true;

  String? uid;
  late String messName;

  String searchQuery = '';
  String selectedDay = 'All';
  String selectedMeal = 'all';
  DateTimeRange? dateRange;
  bool allTime = false;

  final days = [
    'All',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  final mealDisplay = ['All', 'Breakfast', 'Lunch', 'Dinner'];

  @override
    void didChangeDependencies() {
        super.didChangeDependencies();
        final args = ModalRoute.of(context)!.settings.arguments;
        if (args is String) {
            messName = args.toLowerCase();
            print(messName);
        } else {
            messName = "Unknown";
        }
        _feedbacksFuture = fetchFeedbacks();
    }

  @override
  void initState() {
    super.initState();
    uid = Provider.of<UserProvider>(context, listen: false).uid;
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    
  }

  Future<void> _load() async {
    final userDoc =
        await FirebaseFirestore.instance.collection('user').doc(uid).get();
    messName = userDoc['name'];
    await _refresh();
  }

  Future<void> _refresh() async {
    setState(() {
      _loadingRows = true;
      _feedbacksFuture = fetchFeedbacks();
    });
    try {
      await _feedbacksFuture;
    } finally {
      if (mounted) setState(() => _loadingRows = false);
    }
  }

  Future<List<FeedbackModelUI>> fetchFeedbacks() async {
    final now = DateTime.now();
    final cutoff = now.subtract(const Duration(days: 7));

    final snap = await FirebaseFirestore.instance
        .collection('feedback')
        .where('mess', isEqualTo: messName)
        .orderBy('timestamp', descending: true)
        .get();

    final tasks = snap.docs.map((doc) async {
      final feedback = doc.data();
      final rawTs = feedback['timestamp'];
      DateTime ts;

      if (rawTs is Timestamp) {
        ts = rawTs.toDate();
      } else if (rawTs is String) {
        ts = DateTime.tryParse(rawTs) ?? DateTime.fromMillisecondsSinceEpoch(0);
      } else {
        return null;
      }

      if (!allTime && ts.isBefore(cutoff)) return null;
      if (dateRange != null &&
          (ts.isBefore(dateRange!.start) || ts.isAfter(dateRange!.end))) {
        return null;
      }

      final stuUid = feedback['uid'] as String;
      final stuDoc = await FirebaseFirestore.instance
          .collection('students')
          .doc(stuUid)
          .get();
      final student = stuDoc.data();
      if (student == null) return null;

      return FeedbackModelUI(
        text: feedback['text'] ?? '',
        imageUrl: feedback['imageUrl'],
        timestamp: ts,
        uid: stuUid,
        studentName: student['name'] ?? 'Unknown',
        studentEntryNum: student['entryNumber'] ?? 'Unknown',
        studentEmail: student['email'] ?? 'Unknown',
        meal: (feedback['meal'] ?? 'unknown').toString().trim().toLowerCase(),
      );
    }).toList();

    final list = await Future.wait(tasks);
    return list.whereType<FeedbackModelUI>().toList();
  }

  List<FeedbackModelUI> _applyClientFilters(List<FeedbackModelUI> list) {
    final q = searchQuery.trim().toLowerCase();
    return list.where((f) {
      if (q.isNotEmpty &&
          !(f.studentName.toLowerCase().contains(q) ||
              f.studentEntryNum.toLowerCase().contains(q))) {
        return false;
      }
      if (selectedDay != 'All' &&
          DateFormat.EEEE().format(f.timestamp) != selectedDay) {
        return false;
      }
      if (selectedMeal != 'all' && f.meal != selectedMeal) return false;
      return true;
    }).toList();
  }

  Future<void> _pickDateRangeDialog() async {
    final now = DateTime.now();
    DateTime tempStart = dateRange?.start ?? now;
    DateTime tempEnd = dateRange?.end ?? now;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Date Range'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Start Date'),
                SizedBox(
                  height: 200,
                  child: CalendarDatePicker(
                    initialDate: tempStart,
                    firstDate: DateTime(now.year - 1),
                    lastDate: now,
                    onDateChanged: (d) => tempStart = d,
                  ),
                ),
                const SizedBox(height: 12),
                const Text('End Date'),
                SizedBox(
                  height: 200,
                  child: CalendarDatePicker(
                    initialDate: tempEnd,
                    firstDate: DateTime(now.year - 1),
                    lastDate: now,
                    onDateChanged: (d) => tempEnd = d,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() =>
                  dateRange = DateTimeRange(start: tempStart, end: tempEnd));
              Navigator.of(ctx).pop();
              _refresh();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const Header(currentPage: 'Mess Details'),
          _buildFilterRow(),
          Expanded(
            child: (_feedbacksFuture == null || _loadingRows)
                ? const Center(child: CircularProgressIndicator())
                : FutureBuilder<List<FeedbackModelUI>>(
                    future: _feedbacksFuture,
                    builder: (ctx, snap) {
                      if (snap.hasError) {
                        return Center(child: Text('Error: ${snap.error}'));
                      }
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final rows = _applyClientFilters(snap.data ?? []);
                      return _buildTable(rows);
                    }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() => LayoutBuilder(builder: (context, constraints) {
        const gap = SizedBox(width: 12);
        if (constraints.maxWidth >= 1200) {
          return Padding(
              padding: const EdgeInsets.all(15),
              child: Row(children: [
                const SizedBox(width: 12),
                const Expanded(
                    flex: 3,
                    child: Text('Feedback',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold))),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        labelText: 'Search Name/Entry',
                        border: OutlineInputBorder()),
                    onChanged: (v) {
                      setState(() => searchQuery = v);
                      _refresh();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: selectedDay,
                    items: days
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    decoration: const InputDecoration(
                        labelText: 'Day', border: OutlineInputBorder()),
                    onChanged: (v) {
                      setState(() => selectedDay = v!);
                      _refresh();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: selectedMeal,
                    items: mealDisplay.map((m) {
                      final val = m.toLowerCase();
                      return DropdownMenuItem(value: val, child: Text(m));
                    }).toList(),
                    decoration: const InputDecoration(
                        labelText: 'Meal', border: OutlineInputBorder()),
                    onChanged: (v) {
                      setState(() => selectedMeal = v!);
                      _refresh();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextButton.icon(
                      icon: const Icon(Icons.date_range),
                      label: Text(dateRange == null
                          ? 'Pick Range'
                          : '${DateFormat.yMd().format(dateRange!.start)} – ${DateFormat.yMd().format(dateRange!.end)}'),
                      onPressed: _pickDateRangeDialog),
                ),
                Expanded(
                    flex: 1,
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Checkbox(
                          value: allTime,
                          onChanged: (v) {
                            setState(() => allTime = v!);
                            _refresh();
                          }),
                      const Text('All time'),
                    ])),
                Expanded(
                  flex: 1,
                  child: TextButton(
                      onPressed: () {
                        setState(() {
                          searchQuery = '';
                          selectedDay = 'All';
                          selectedMeal = 'all';
                          dateRange = null;
                          allTime = false;
                        });
                        _refresh();
                      },
                      child: const Text('Clear')),
                ),
              ]));
        } else {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text('Feedback',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(
                  width: 220,
                  child: TextField(
                    decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        labelText: 'Search Name/Entry',
                        border: OutlineInputBorder()),
                    onChanged: (v) {
                      setState(() => searchQuery = v);
                      _refresh();
                    },
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: DropdownButtonFormField<String>(
                    value: selectedDay,
                    items: days
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    decoration: const InputDecoration(
                        labelText: 'Day', border: OutlineInputBorder()),
                    onChanged: (v) {
                      setState(() => selectedDay = v!);
                      _refresh();
                    },
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: DropdownButtonFormField<String>(
                    value: selectedMeal,
                    items: mealDisplay.map((m) {
                      final val = m.toLowerCase();
                      return DropdownMenuItem(value: val, child: Text(m));
                    }).toList(),
                    decoration: const InputDecoration(
                        labelText: 'Meal', border: OutlineInputBorder()),
                    onChanged: (v) {
                      setState(() => selectedMeal = v!);
                      _refresh();
                    },
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.date_range),
                  label: Text(dateRange == null
                      ? 'Pick Range'
                      : '${DateFormat.yMd().format(dateRange!.start)} – '
                          '${DateFormat.yMd().format(dateRange!.end)}'),
                  onPressed: _pickDateRangeDialog,
                ),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Checkbox(
                      value: allTime,
                      onChanged: (v) {
                        setState(() => allTime = v!);
                        _refresh();
                      }),
                  const Text('All time'),
                ]),
                TextButton(
                    onPressed: () {
                      setState(() {
                        searchQuery = '';
                        selectedDay = 'All';
                        selectedMeal = 'all';
                        dateRange = null;
                        allTime = false;
                      });
                      _refresh();
                    },
                    child: const Text('Clear')),
              ],
            ),
          );
        }
      });

  Widget _buildTable(List<FeedbackModelUI> rows) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: LayoutBuilder(builder: (context, constraints) {
          final card = Card(
            color: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: Column(children: [
              // header row
              Container(
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12))),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Row(children: [
                    _buildHeaderCell('Name'),
                    _buildHeaderCell('Entry No.'),
                    _buildHeaderCell('Feedback'),
                    _buildHeaderCell('Image'),
                    _buildHeaderCell('Timestamp'),
                  ])),

              Expanded(
                  child: ClipRRect(
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12)),
                child: rows.isEmpty
                    ? Container(
                        color: Colors.grey[50],
                        child: const Center(child: Text('No feedback found')))
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: rows.length,
                        itemBuilder: (c, i) {
                          final f = rows[i];
                          final bg =
                              i.isEven ? Colors.grey[50] : Colors.grey[100];
                          return Container(
                            color: bg,
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 8),
                            child: Row(children: [
                              _buildBodyCell(f.studentName),
                              _buildBodyCell(f.studentEntryNum),
                              _buildBodyCell(SizedBox(
                                  width: 300,
                                  child: Text(f.text, softWrap: true))),
                              Expanded(
                                  child: Center(
                                child: f.imageUrl != null
                                    ? TextButton(
                                        child: const Text("View Image"),
                                        onPressed: () => showDialog(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                                    content: Image.network(
                                                  f.imageUrl!,
                                                  loadingBuilder:
                                                      (ctx, child, progress) {
                                                    if (progress == null) {
                                                      return child;
                                                    }
                                                    final v = progress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? progress
                                                                .cumulativeBytesLoaded /
                                                            progress
                                                                .expectedTotalBytes!
                                                        : null;
                                                    return SizedBox(
                                                        width: 120,
                                                        height: 120,
                                                        child: Center(
                                                            child:
                                                                CircularProgressIndicator(
                                                                    value: v)));
                                                  },
                                                ))))
                                    : const Text('No image'),
                              )),
                              _buildBodyCell(DateFormat('dd‑MM‑yyyy HH:mm')
                                  .format(f.timestamp)),
                            ]),
                          );
                        }),
              )),
            ]),
          );
          return card;
        }),
      );

  Widget _buildHeaderCell(String label) => Expanded(
      child: Center(
          child: Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black87))));

  Widget _buildBodyCell(dynamic content) => Expanded(
      child: Center(
          child: content is Widget
              ? content
              : Text(content.toString(),
                  style: const TextStyle(fontSize: 13))));
}
