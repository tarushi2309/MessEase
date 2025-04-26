import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webapp/models/mess_committee.dart';
import 'package:webapp/components/header_manager.dart';
import '../../components/user_provider.dart';
import 'package:provider/provider.dart';

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
  final ScrollController _scrollController = ScrollController(); // Added scroll controller

  late Future<void> _initialLoad;

  @override
  void initState() {
    super.initState();
    uid = Provider.of<UserProvider>(context, listen: false).uid;
    _initialLoad = _initPageData();
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose the controller
    super.dispose();
  }

  Future<void> _initPageData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('user').doc(uid).get();

      if (userDoc.exists) {
        messName = userDoc['name'];
        mess = messName[0].toUpperCase() + messName.substring(1).toLowerCase();
        //print("Mess name: $messName");
        //print("Mess: $mess");

        await fetchTotalStudents();
        await fetchBatches();
      } else {
        print("User not found");
      }
    } catch (e) {
      print("Error during page data init: $e");
      rethrow;
    }
  }

  Future<void> fetchTotalStudents() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("students")
          .where('mess', isEqualTo: messName)
          .get();

      setState(() {
        totalStudents = querySnapshot.docs.length;
        //print("Total students in $messName: $totalStudents");
      });
    } catch (e) {
      print("Error fetching total students: $e");
    }
  }

  Future<void> fetchBatches() async {
    try {
      DocumentSnapshot messAllotDoc = await FirebaseFirestore.instance
          .collection("mess")
          .doc("messAllotment") 
          .get();
      //print("Mess allotment document: ${messAllotDoc.data()}");
      if (messAllotDoc.exists) {
        Map<String, dynamic>? messAllotData = messAllotDoc.data() as Map<String, dynamic>?;
        List<String> matchingBatches = [];
        
        if (messAllotData != null && messAllotData.containsKey('messAllot')) {
          Map<String, dynamic> messAllotMap = messAllotData['messAllot'] as Map<String, dynamic>;
          messAllotMap.forEach((batch, assignedMess) {
            if (assignedMess == mess) {
              matchingBatches.add(batch);
            }
          });
        }

        setState(() {
          batches = matchingBatches;
        });
      } else {
        print("messAllot document not found");
      }
    } catch (e) {
      print("Error fetching batches: $e");
    }
  }

  Future<List<MessCommitteeModel>> fetchCommitteeMembers(String messName) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("mess_committee")
        .where('messName', isEqualTo: messName)
        .get();

    return querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return MessCommitteeModel.fromJson(data);
    }).toList();
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
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error: ${snapshot.error}",
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                } else {
                  return LayoutBuilder(
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
                                  "$mess Mess Details",
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
                                    _buildInfoRow("Total Number of Students", "$totalStudents"),
                                    const SizedBox(height: 12),
                                    _buildInfoRow("Batches", batches.join(", ")),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),
                              Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: const Text(
                                  "Mess Committee",
                                  style: TextStyle(
                                      fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                constraints: BoxConstraints(
                                  minHeight: 200,
                                ),
                                child: FutureBuilder<List<MessCommitteeModel>>(
                                  future: fetchCommitteeMembers(messName),
                                  builder: (context, snapshot) {
                                    int crossAxisCount;
                                    double screenWidth = constraints.maxWidth;

                                    if (screenWidth > 1000) {
                                      crossAxisCount = 3;
                                    } else if (screenWidth > 600) {
                                      crossAxisCount = 2;
                                    } else {
                                      crossAxisCount = 1;
                                    }

                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      //print("in waiting state");
                                      return const Center(child: CircularProgressIndicator());
                                    } else if (snapshot.hasError) {
                                      return Column(
                                        children: [
                                          const Text("Error loading committee members"),
                                          Text(snapshot.error.toString(),
                                              style: const TextStyle(color: Colors.red)),
                                        ],
                                      );
                                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                      return const Center(child: Text("No committee members found"));
                                    }

                                    List<MessCommitteeModel> members = snapshot.data!;
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
                                      itemBuilder: (context, index) {
                                        return _buildCommitteeCard(context, members[index]);
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
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
              child: Text(
                title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blueGrey),
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

  Widget _buildCommitteeCard(BuildContext context, MessCommitteeModel member) {
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.person, size: 40, color: Colors.grey),
                    ),
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
}