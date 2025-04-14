import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webapp/models/mess_committee.dart';
import 'package:webapp/components/header_manager.dart';
import '../../components/user_provider.dart';
import 'package:provider/provider.dart';

class MessCommitteeMessManagerPage extends StatefulWidget {
  const MessCommitteeMessManagerPage({super.key});

  @override
  _MessCommitteeMessManagerPageState createState() => _MessCommitteeMessManagerPageState();
}

class _MessCommitteeMessManagerPageState extends State<MessCommitteeMessManagerPage> {
  String? uid;
  String messName = "";

  @override
  void initState() {
    super.initState();
    uid = Provider.of<UserProvider>(context, listen: false).uid;
    fetchUserName();
  }

  Future<void> fetchUserName() async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('user').doc(uid).get();

      if (userDoc.exists) {
        setState(() {
          messName = userDoc['name'];
        });
      } else {
        print("User not found");
      }
    } catch (e) {
      print("Error fetching user: $e");
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FutureBuilder<List<MessCommitteeModel>>(
                future: fetchCommitteeMembers(messName),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Error loading committee members"),
                          Text(snapshot.error.toString(), style: const TextStyle(color: Colors.red)),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No committee members found"));
                  }

                  List<MessCommitteeModel> members = snapshot.data!;

                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 2,
                    ),
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      MessCommitteeModel member = members[index];
                      return Card(
                        color: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.person, color: Colors.tealAccent),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      member.name,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text("Entry Number: ${member.entryNumber}", style: const TextStyle(color: Colors.white70)),
                              Text("Email: ${member.email}", style: const TextStyle(color: Colors.white70)),
                              Text("Phone: ${member.phoneNumber}", style: const TextStyle(color: Colors.white70)),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
