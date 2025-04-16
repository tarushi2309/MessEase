import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webapp/models/mess_committee.dart';
import 'package:webapp/components/header_boha.dart';

class MessCommittePageBoha extends StatefulWidget {
  const MessCommittePageBoha({super.key});

  @override
  _MessCommittePageBohaState createState() => _MessCommittePageBohaState();
}

class _MessCommittePageBohaState extends State<MessCommittePageBoha> {
  late String messName;
  late Future<List<MessCommitteeModel>> _committeeMembers;
  String? uid;
  String mess = "";
  int totalStudents = 0;
  List<String> batches = [];
  final ScrollController _scrollController = ScrollController();

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
    _committeeMembers = fetchCommitteeMembers(messName);
  }

  Future<List<MessCommitteeModel>> fetchCommitteeMembers(
      String messName) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("mess_committee")
        .where('messName', isEqualTo: messName)
        .get();

    return querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return MessCommitteeModel.fromJson(data);
    }).toList();
  }

  void removeMember(String entryNumber) {
    setState(() {
      _committeeMembers = _committeeMembers.then((list) =>
          list.where((member) => member.entryNumber != entryNumber).toList());
    });

    FirebaseFirestore.instance
        .collection("mess_committee")
        .where("entryNumber", isEqualTo: entryNumber)
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        doc.reference.delete();
      }
    });
  }

  void _showAddMemberDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController entryNumberController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Text("Add Committee Member"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: "Name")),
                TextField(
                    controller: entryNumberController,
                    decoration: InputDecoration(labelText: "Entry Number")),
                TextField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: "Email")),
                TextField(
                    controller: phoneController,
                    decoration: InputDecoration(labelText: "Phone Number"),
                    keyboardType: TextInputType.phone),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text("Submit"),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection("mess_committee")
                    .add({
                  'name': nameController.text,
                  'entryNumber': entryNumberController.text,
                  'email': emailController.text,
                  'phoneNumber': phoneController.text,
                  'messName': messName,
                });
                setState(() {
                  _committeeMembers = fetchCommitteeMembers(messName);
                });
                Navigator.pop(context);
              },
            ),
          ],
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
          // Header remains unchanged
          const Header(currentPage: 'Mess Committee'),

          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  controller: _scrollController, // Attach controller here
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(
                            "$messName Mess Committee",
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
                              _buildInfoRow(
                                  "Total Number of Students", "$totalStudents"),
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

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Column(
                                  children: [
                                    const Text(
                                        "Error loading committee members"),
                                    Text(snapshot.error.toString(),
                                        style:
                                            const TextStyle(color: Colors.red)),
                                  ],
                                );
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return const Center(
                                    child: Text("No committee members found"));
                              }

                              List<MessCommitteeModel> members = snapshot.data!;
                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(16),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 24,
                                  mainAxisSpacing: 24,
                                  childAspectRatio: 2,
                                ),
                                itemCount: members.length,
                                itemBuilder: (context, index) {
                                  return _buildCommitteeCard(
                                      context, members[index]);
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
            ),
          ),
        ],
      ),

      // Floating Button Replacing Top-right "+"
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMemberDialog,
        label: const Text("Add Committee Member",
            style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Color(0xFFFF7643),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 4, // Matches your desired UI
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.person,
                          size: 40, color: Colors.grey),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            member.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text("Entry Number: ${member.entryNumber}",
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text("Email: ${member.email}",
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text("Phone: ${member.phoneNumber}",
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 14)),
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
