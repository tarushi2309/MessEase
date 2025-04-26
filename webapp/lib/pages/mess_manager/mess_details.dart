import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webapp/models/mess_committee.dart';
import 'package:webapp/components/header_manager.dart';
import '../../components/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessCommitteeMessManagerPage extends StatefulWidget {
  const MessCommitteeMessManagerPage({super.key});

  @override
  _MessCommitteeMessManagerPageState createState() =>
      _MessCommitteeMessManagerPageState();
}

class _MessCommitteeMessManagerPageState extends State<MessCommitteeMessManagerPage> {
  String? uid;
  String messName = "";
  String mess = "";
  int totalStudents = 0;
  List<String> batches = [];
  final ScrollController _scrollController = ScrollController();
  late Future<void> _initialLoad;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    _loadPersistedData();
  }

  Future<void> _loadPersistedData() async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      uid = Provider.of<UserProvider>(context, listen: false).uid ?? 
           prefs.getString('uid');
      messName = prefs.getString('mess') ?? '';
    });
    
    if (uid != null && uid!.isNotEmpty) {
      _initialLoad = _initPageData();
      await _initialLoad;
      _persistData();
    }
  }

  Future<void> _persistData() async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setString('uid', uid ?? '');
    await prefs.setString('mess', messName);
  }

  Future<void> _initPageData() async {
    try {
      if (uid == null || uid!.isEmpty) {
        throw Exception("User ID is missing");
      }

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('user')
          .doc(uid!)
          .get();

      if (userDoc.exists) {
        setState(() {
          messName = userDoc['name'];
          mess = _formatMessName(messName);
        });
        
        await Future.wait([fetchTotalStudents(), fetchBatches()]);
      }
    } catch (e) {
      print("Error initializing page data: $e");
      rethrow;
    }
  }

  String _formatMessName(String name) {
    return name.isNotEmpty 
        ? name[0].toUpperCase() + name.substring(1).toLowerCase()
        : '';
  }

  Future<void> fetchTotalStudents() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("students")
          .where('mess', isEqualTo: messName)
          .get();

      setState(() {
        totalStudents = querySnapshot.docs.length;
      });
    } catch (e) {
      print("Error fetching students: $e");
      throw Exception("Failed to load student data");
    }
  }

  Future<void> fetchBatches() async {
    try {
      DocumentSnapshot messAllotDoc = await FirebaseFirestore.instance
          .collection("mess")
          .doc("messAllotment")
          .get();

      if (messAllotDoc.exists) {
        Map<String, dynamic>? data = messAllotDoc.data() as Map<String, dynamic>?;
        List<String> matches = [];

        data?['messAllot']?.forEach((batch, mess) {
          if (mess == mess) matches.add(batch);
        });

        setState(() => batches = matches);
      }
    } catch (e) {
      print("Error fetching batches: $e");
      throw Exception("Failed to load batch data");
    }
  }

  Future<List<MessCommitteeModel>> fetchCommitteeMembers() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("mess_committee")
          .where('messName', isEqualTo: messName)
          .get();

      return querySnapshot.docs.map((doc) {
        return MessCommitteeModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print("Error fetching committee: $e");
      throw Exception("Failed to load committee members");
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const Header(currentPage: 'Mess Details'),
          Expanded(
            child: FutureBuilder(
              future: _initialLoad,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoading();
                } else if (snapshot.hasError) {
                  return _buildError(snapshot.error.toString());
                }
                return _buildMainContent();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      interactive: true,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildInfoCard(),
              const SizedBox(height: 32),
              _buildCommitteeSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Text(
        "$mess Mess Details",
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
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
          _buildInfoRow("Batches", batches.join(", ")),
        ],
      ),
    );
  }

  Widget _buildCommitteeSection() {
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
        FutureBuilder<List<MessCommitteeModel>>(
          future: fetchCommitteeMembers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _buildError(snapshot.error.toString());
            }
            return _buildCommitteeGrid(snapshot.data ?? []);
          },
        ),
      ],
    );
  }

  Widget _buildCommitteeGrid(List<MessCommitteeModel> members) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 1000 ? 3 : 
                           constraints.maxWidth > 600 ? 2 : 1;
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            childAspectRatio: 2,
          ),
          itemCount: members.length,
          itemBuilder: (context, index) => _buildCommitteeCard(members[index]),
        );
      },
    );
  }

  Widget _buildCommitteeCard(MessCommitteeModel member) {
    return Card(
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
                child: Row(
                  children: [
                    _buildMemberIcon(),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              member.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Flexible(
                            child: Text(
                              "Entry Number: ${member.entryNumber}",
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Flexible(
                            child: Text(
                              "Email: ${member.email}",
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Flexible(
                            child: Text(
                              "Phone: ${member.phoneNumber}",
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.person, size: 40, color: Colors.grey),
    );
  }

  Widget _buildMemberInfo(MessCommitteeModel member) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(member.name, style: _boldStyle),
          const SizedBox(height: 6),
          Text("Entry: ${member.entryNumber}", style: _greyStyle),
          Text("Email: ${member.email}", style: _greyStyle),
          Text("Phone: ${member.phoneNumber}", style: _greyStyle),
        ],
      ),
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
              child: Text(title, style: _boldGreyStyle),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(value, style: _blackStyle)),
          ],
        ),
        const Divider(thickness: 1),
      ],
    );
  }

  Widget _buildLoading() => const Center(child: CircularProgressIndicator());
  
  Widget _buildError(String error) => Center(
    child: Text("Error: $error", style: const TextStyle(color: Colors.red)),
  );

  final TextStyle _boldStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );

  final TextStyle _greyStyle = const TextStyle(
    color: Colors.grey,
    fontSize: 14,
  );

  final TextStyle _boldGreyStyle = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
    color: Colors.blueGrey,
  );

  final TextStyle _blackStyle = const TextStyle(
    fontSize: 16,
    color: Colors.black,
  );
}
