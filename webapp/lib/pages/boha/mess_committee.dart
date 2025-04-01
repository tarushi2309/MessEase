import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webapp/models/mess_committee.dart';
import 'package:webapp/components/header_boha.dart';

class MessCommitteeScreenBoha extends StatefulWidget {
  const MessCommitteeScreenBoha({super.key});

  @override
  _MessCommitteeScreenBohaState createState() => _MessCommitteeScreenBohaState();
}

class _MessCommitteeScreenBohaState extends State<MessCommitteeScreenBoha> {
  late String messName;
  late Future<List<MessCommitteeModel>> _committeeMembers;

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

  void removeMember(String entryNumber) {
    setState(() {
      _committeeMembers = _committeeMembers.then((list) => list.where((member) => member.entryNumber != entryNumber).toList());
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
                TextField(controller: nameController, decoration: InputDecoration(labelText: "Name")),
                TextField(controller: entryNumberController, decoration: InputDecoration(labelText: "Entry Number")),
                TextField(controller: emailController, decoration: InputDecoration(labelText: "Email")),
                TextField(controller: phoneController, decoration: InputDecoration(labelText: "Phone Number"), keyboardType: TextInputType.phone),
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
                await FirebaseFirestore.instance.collection("mess_committee").add({
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

        // Body containing the committee members list
        Expanded( 
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder<List<MessCommitteeModel>>(
              future: _committeeMembers,
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
                    crossAxisCount: 3, // Max 3 per row
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2, // Adjusted to fix right overflow
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
                                    "${member.name}",
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
                            const Spacer(), // Prevents bottom overflow
                            Align(
                              alignment: Alignment.bottomRight,
                              child: ElevatedButton(
                                onPressed: () => removeMember(member.entryNumber),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                ),
                                child: const Text("Remove"),
                              ),
                            ),
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

    // Floating Button Replacing Top-right "+"
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _showAddMemberDialog,
      label: const Text("Add Committee Member", style: TextStyle(color: Colors.white)),
      icon: const Icon(Icons.add, color: Colors.white),
      backgroundColor: Colors.blue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      elevation: 10, // Matches your desired UI
    ),
  );
}
}