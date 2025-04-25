import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webapp/models/announcement.dart';
import 'package:webapp/components/header_boha.dart';
import 'package:webapp/services/database.dart';
import 'package:intl/intl.dart';

class AnnouncementPage extends StatefulWidget {
  const AnnouncementPage({super.key});

  @override
  _AnnouncementPageState createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends State<AnnouncementPage> {
  late List<AnnouncementModel> _allAnnouncements = [];
  late List<AnnouncementModel> _filteredAnnouncements = [];

  DatabaseModel db = DatabaseModel();

  String searchQuery = '';
  DateTimeRange? dateRange;
  bool allTime = false;

  @override
  void initState() {
    super.initState();
    _fetchRecentAnnouncements();
  }

  Future<void> _fetchRecentAnnouncements() async {
    _allAnnouncements = await db.fetchAnnouncementsRecent();
    setState(() {
      _filteredAnnouncements = _allAnnouncements;
      _filteredAnnouncements.sort(
          (a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));
    });
  }

  Future<void> _fetchAllAnnouncements() async {
    if (_allAnnouncements.length == _filteredAnnouncements.length) {
      _allAnnouncements = await db.fetchAnnouncements();
    }
    setState(() {
      _filteredAnnouncements = _allAnnouncements;
      _filteredAnnouncements.sort(
          (a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));
    });
  }

  // Add announcements
  void _showAddAnnouncementDialog() {
    TextEditingController announcementController = TextEditingController();
    List<String> messes = ['Konark', 'Anusha', 'Ideal'];

    List<String> selectedMesses = [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              title: const Text("Add Announcement"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: announcementController,
                      decoration:
                          const InputDecoration(labelText: "Announcement"),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Select Mess:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Column(
                      children: messes.map((messName) {
                        return CheckboxListTile(
                          title: Text(messName),
                          value: selectedMesses.contains(messName),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                selectedMesses.add(messName);
                              } else {
                                selectedMesses.remove(messName);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  child: const Text("Submit"),
                  onPressed: () async {
                    if (announcementController.text.isEmpty ||
                        selectedMesses.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              "Please fill all fields and select at least one mess"),
                        ),
                      );
                      return;
                    }

                    String currentDateTime = DateTime.now().toString();

                    // Save one document with all selected messes as an array
                    await FirebaseFirestore.instance
                        .collection("announcements")
                        .add({
                      'announcement': announcementController.text,
                      'date': currentDateTime,
                      'mess': selectedMesses, // Store as array
                    });

                    await _fetchRecentAnnouncements();

                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Header(currentPage: 'Announcements'),
          _buildFilterRow(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _allAnnouncements.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _buildTable(_filteredAnnouncements),
            ),
          ),
        ],
      ),
      floatingActionButton: _allAnnouncements.isEmpty
          ? null
          : Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
              child: FloatingActionButton.extended(
                onPressed: _showAddAnnouncementDialog,
                label: const Text(
                  "Add Announcement",
                  style: TextStyle(color: Colors.white),
                ),
                icon: const Icon(Icons.add, color: Colors.white),
                backgroundColor: Color(0xFFF0753C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 10,
              ),
            ),
    );
  }

  Widget _buildFilterRow() => LayoutBuilder(builder: (context, constraints) {
        const gap = SizedBox(width: 12);
        if (constraints.maxWidth >= 1200) {
          return Padding(
              padding: const EdgeInsets.all(15),
              child: Row(children: [
                const Expanded(
                    flex: 3,
                    child: Text('Announcements',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold))),
                gap,
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        labelText: 'Search Mess Name',
                        border: OutlineInputBorder()),
                    onChanged: (v) {
                      setState(() => searchQuery = v);
                      _applyFilters();
                    },
                  ),
                ),
                gap,
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
                          onChanged: (v) async {
                            setState(() => allTime = v!);
                            if (allTime) {
                              await _fetchAllAnnouncements();
                            } else {
                              await _fetchRecentAnnouncements();
                            }
                            _applyFilters();
                          }),
                      const Text('All time'),
                    ])),
                Expanded(
                  flex: 1,
                  child: TextButton(
                      onPressed: () {
                        setState(() {
                          searchQuery = '';
                          dateRange = null;
                          allTime = false;
                        });
                        _fetchRecentAnnouncements();
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
                const Text('Announcements',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(
                  width: 220,
                  child: TextField(
                    decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        labelText: 'Search Mess Name',
                        border: OutlineInputBorder()),
                    onChanged: (v) {
                      setState(() => searchQuery = v);
                      _applyFilters();
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
                      onChanged: (v) async {
                        setState(() => allTime = v!);
                        if (allTime) {
                          await _fetchAllAnnouncements();
                        } else {
                          await _fetchRecentAnnouncements();
                        }
                        _applyFilters();
                      }),
                  const Text('All time'),
                ]),
                TextButton(
                    onPressed: () {
                      setState(() {
                        searchQuery = '';
                        dateRange = null;
                        allTime = false;
                      });
                      _fetchRecentAnnouncements();
                    },
                    child: const Text('Clear')),
              ],
            ),
          );
        }
      });

  void _applyFilters() {
    setState(() {
      _filteredAnnouncements = _allAnnouncements.where((announcement) {
        final matchesQuery = searchQuery.isEmpty ||
            announcement.mess.any((messName) =>
                messName.toLowerCase().contains(searchQuery.toLowerCase()));

        final matchesDateRange = dateRange == null ||
            (DateTime.parse(announcement.date).isAfter(
                    dateRange!.start.subtract(const Duration(days: 1))) &&
                DateTime.parse(announcement.date)
                    .isBefore(dateRange!.end.add(const Duration(days: 1))));

        return matchesQuery && matchesDateRange;
      }).toList();
      _filteredAnnouncements.sort(
          (a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));
    });
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
              if (tempEnd.isBefore(tempStart)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('End date cannot be before start date.'),
                    backgroundColor: Color(0xFFF0753C),
                  ),
                );
                return;
              }
              setState(() {
                dateRange = DateTimeRange(start: tempStart, end: tempEnd);
              });
              _applyFilters();
              Navigator.of(ctx).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(List<AnnouncementModel> rows) => Padding(
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
                    Flexible(
                      flex: 3,
                      child: _buildHeaderCell('Announcement'),
                    ),
                    Flexible(
                      flex: 1,
                      child: _buildHeaderCell('Mess'),
                    ),
                    Flexible(
                      flex: 1,
                      child: _buildHeaderCell('Date'),
                    )
                  ])),

              Expanded(
                  child: ClipRRect(
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12)),
                child: rows.isEmpty
                    ? Container(
                        color: Colors.grey[50],
                        child:
                            const Center(child: Text('No announcements found')))
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: rows.length,
                        itemBuilder: (c, i) {
                          final announcement = rows[i];
                          final bg =
                              i.isEven ? Colors.grey[50] : Colors.grey[100];
                          return Container(
                            color: bg,
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 8),
                            child: Row(children: [
                              Flexible(
                                flex: 3,
                                child: _buildBodyCell(SizedBox(
                                  child: Text(announcement.announcement,
                                      softWrap: true),
                                )),
                              ),
                              Flexible(
                                  flex: 1,
                                  child: _buildBodyCell(
                                      announcement.mess.join(', '),
                                      alignment: Alignment.centerLeft)),
                              Flexible(
                                  flex: 1,
                                  child: _buildBodyCell(DateFormat('dd-MM-yyyy')
                                      .format(
                                          DateTime.parse(announcement.date))))
                            ]),
                          );
                        }),
              )),
            ]),
          );
          return card;
        }),
      );

  Widget _buildHeaderCell(String label) => Align(
      alignment: Alignment.centerLeft,
      child: Text(label,
          style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black87)));

  Widget _buildBodyCell(dynamic content,
          {Alignment alignment = Alignment.centerLeft}) =>
      Align(
          alignment: alignment,
          child: content is Widget
              ? content
              : Text(content.toString(), style: const TextStyle(fontSize: 13)));
}
