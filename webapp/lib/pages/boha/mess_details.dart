import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:webapp/components/header_boha.dart';
import 'package:webapp/models/messOptions.dart';

class MessDetailsPageBoha extends StatefulWidget {
  const MessDetailsPageBoha({super.key});

  @override
  State<MessDetailsPageBoha> createState() => _MessDetailsPageBohaState();
}

class _MessDetailsPageBohaState extends State<MessDetailsPageBoha> {
  List<String> _messOptions = [];

  @override
  void initState() {
    super.initState();
    get_messOptions();
  }

  Future<void> get_messOptions() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('messOptions')
          .doc('messOptions')
          .get();

      if (doc.exists) {
        MessOptions options =
            MessOptions.fromJson(doc.data() as Map<String, dynamic>);
        setState(() {
          _messOptions = options.messNames;
        });
      }
    } catch (e) {
      print("Error getting mess options: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Header(currentPage: 'Mess Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded( 
              child: _buildViewMessDetailsCard(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewMessDetailsCard() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "View Mess Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (_messOptions.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 610,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 2.6, // Adjusted aspect ratio
                    ),
                    itemCount: _messOptions.length,
                    itemBuilder: (context, index) {
                      final messName = _messOptions[index];
                      return _buildMessCard(
                        context,
                        messName,
                        "Manager Name", // Replace with actual manager data
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessCard(
      BuildContext context, String messName, String managerName) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Row( // Removed fixed height SizedBox
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 6,
            decoration: BoxDecoration(
              color: const Color(0xFFFF7643),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    messName,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Manager: $managerName",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/mess_committee_boha',
                                  arguments: messName);
                            },
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all<Color>(
                                  const Color(0xFFF0753C)),
                              padding: WidgetStateProperty.all<EdgeInsets>(
                                const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                              ),
                              shape:
                                  WidgetStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0)),
                              ),
                            ),
                            child: const Text(
                              "View Details",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/feedback',
                                  arguments: messName);
                            },
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all<Color>(
                                  const Color(0xFFF0753C)),
                              padding: WidgetStateProperty.all<EdgeInsets>(
                                const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                              ),
                              shape:
                                  WidgetStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0)),
                              ),
                            ),
                            child: const Text(
                              "Feedback",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}