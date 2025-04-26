import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webapp/models/mess_committee.dart';
import 'package:webapp/components/header_admin.dart';
import '../../components/user_provider.dart';
import 'package:provider/provider.dart';
import 'dart:html' as html;
import 'package:shared_preferences/shared_preferences.dart';

class MessDetailsPage extends StatefulWidget {
  const MessDetailsPage({super.key});

  @override
  _MessDetailsPageState createState() => _MessDetailsPageState();
}

class _MessDetailsPageState extends State<MessDetailsPage> {
  String? uid;
  late String messName = "";
  int totalStudents = 0;
  List<String> batches = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadMessName();
  }

  void _loadMessName() {
    // Try to get from route arguments first
    final args = ModalRoute.of(context)?.settings.arguments as String?;
    if (args != null && args.isNotEmpty) {
      _setMessName(args);
    } else {
      // Fallback to localStorage for refresh persistence
      final storedName = html.window.localStorage['messName'];
      if (storedName != null && storedName.isNotEmpty) {
        _setMessName(storedName);
      }
    }
  }

  void _setMessName(String name) {
    if (mounted) {
      setState(() {
        messName = name;
        html.window.localStorage['messName'] = name; // Persist
      });
      fetchData();
    }
  }

  void fetchData() {
    fetchTotalStudents();
    fetchBatches();
  }

  String _formatMessName(String name) {
    return name.isNotEmpty
        ? name[0].toUpperCase() + name.substring(1).toLowerCase()
        : '';
  }

  @override
  void initState() {
    super.initState();
    uid = Provider.of<UserProvider>(context, listen: false).uid;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void fetchTotalStudents() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("students")
          .where('mess', isEqualTo: messName.toLowerCase())
          .get();

      if (mounted) {
        setState(() => totalStudents = querySnapshot.docs.length);
      }
    } catch (e) {
      print("Error fetching students: $e");
    }
  }

  Future<void> fetchBatches() async {
    try {
      DocumentSnapshot messAllotDoc = await FirebaseFirestore.instance
          .collection("mess")
          .doc("messAllotment")
          .get();

      if (messAllotDoc.exists) {
        final data = messAllotDoc.data() as Map<String, dynamic>?;
        final messAllot = data?['messAllot'] as Map<String, dynamic>? ?? {};

        final matches = messAllot.entries
            .where((entry) => 
                entry.value.toString().toLowerCase() == messName.toLowerCase())
            .map((entry) => entry.key)
            .toList();

        if (mounted) {
          setState(() => batches = matches);
        }
      }
    } catch (e) {
      print("Batch fetch error: $e");
      if (mounted) {
        setState(() => batches = []);
      }
    }
  }

  Future<List<MessCommitteeModel>> fetchCommitteeMembers() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("mess_committee")
          .where('messName', isEqualTo: messName.toLowerCase())
          .get();

      return querySnapshot.docs.map((doc) {
        return MessCommitteeModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print("Committee error: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const Header(currentPage: 'Mess Details'),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  controller: _scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(
                            "${_formatMessName(messName)} Mess Details",
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow("Total Students", "$totalStudents"),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                "Batches",
                                batches.isNotEmpty 
                                    ? batches.join(", ")
                                    : "No batches allocated",
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildCommitteeSection(constraints),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommitteeSection(BoxConstraints constraints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Text(
            "Mess Committee",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          constraints: const BoxConstraints(minHeight: 200),
          child: FutureBuilder<List<MessCommitteeModel>>(
            future: fetchCommitteeMembers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasError) {
                return _buildErrorWidget(snapshot.error.toString());
              }

              final members = snapshot.data ?? [];
              if (members.isEmpty) {
                return const Center(child: Text("No committee members found"));
              }

              return _buildCommitteeGrid(constraints, members);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCommitteeGrid(BoxConstraints constraints, List<MessCommitteeModel> members) {
    final crossAxisCount = _calculateGridColumns(constraints.maxWidth);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: 2,
      ),
      itemCount: members.length,
      itemBuilder: (context, index) => _buildCommitteeCard(members[index]),
    );
  }

  int _calculateGridColumns(double width) {
    if (width > 1000) return 3;
    if (width > 600) return 2;
    return 1;
  }

  Widget _buildErrorWidget(String error) {
    return Column(
      children: [
        const Text("Error loading committee"),
        Text(error, style: const TextStyle(color: Colors.red)),
      ],
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 200,
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.blueGrey,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
          ],
        ),
        const Divider(thickness: 1),
      ],
    );
  }

  Widget _buildCommitteeCard(MessCommitteeModel member) {
    return Card(
      color: Colors.white,
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 6,
              decoration: const BoxDecoration(
                color: Color(0xFFFF7643),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildMemberDetail(member.name),
                    const SizedBox(height: 6),
                    _buildMemberDetail("Entry: ${member.entryNumber}"),
                    const SizedBox(height: 4),
                    _buildMemberDetail("Email: ${member.email}"),
                    const SizedBox(height: 4),
                    _buildMemberDetail("Phone: ${member.phoneNumber}"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberDetail(String text) {
    return Flexible(
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
