import 'package:flutter/material.dart';
import 'package:webapp/components/header_admin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webapp/models/messOptions.dart';

class RefundPage extends StatefulWidget {
  RefundPage({super.key});

  @override
  _RefundPageState createState() => _RefundPageState();
}

class _RefundPageState extends State<RefundPage> {
  List<String> messes = [];

  @override
  void initState() {
    super.initState();
    get_messOptions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Header(currentPage: 'Refund'),
      ),
      body: Builder(
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              color: Colors.white,
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    (Scaffold.maybeOf(context)?.appBarMaxHeight ?? 60),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'REBATE REQUESTS',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 32),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = constraints.maxWidth > 1000
                            ? 3
                            : constraints.maxWidth > 600
                                ? 2
                                : 1;
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.5,
                          ),
                          itemCount: messes.length,
                          itemBuilder: (context, index) {
                            return _buildMessCard(context, messes[index]);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
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
          messes = options.messNames;
        });
      }
    } catch (e) {
      print("Error getting mess options: $e");
    }
  }

  Widget _buildMessCard(BuildContext context, String mess) {
    return FutureBuilder(
      future: _fetchRebateStats(mess ?? ''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Text("Error loading data");
        }

        final data = snapshot.data as Map<String, dynamic>;
        final pendingRebates = data['pending'].toString();
        final totalAmount = data['amount'].toString();

        return Card(
          color: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          margin: const EdgeInsets.all(12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                height: 250,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          mess ?? '',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),

                        _buildAlignedTextRow("Pending Processing Rebates", pendingRebates),
                        const SizedBox(height: 10),

                        _buildAlignedTextRow("Total Amount", "₹$totalAmount"),
                        const SizedBox(height: 20),

                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/rebate_history',
                              arguments: mess,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF0753C),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            "View",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _fetchRebateStats(String messName) async {
    messName = messName.toLowerCase();
    final query = await FirebaseFirestore.instance
        .collection('students')
        .where('mess', isEqualTo: messName)
        .where('refund', isGreaterThan: 0)
        .get();

    final docs = query.docs;

    int totalPending = docs.length;
    double totalAmount = docs.fold(0.0, (sum, doc) {
      return sum + (doc['refund'] as num).toDouble();
    });
    return {
      'pending': totalPending,
      'amount': totalAmount.toStringAsFixed(2),
    };
  }

  Widget _buildAlignedTextRow(String label, String? value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "$label:",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 12),
        Text(
          value ?? '',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  
}
