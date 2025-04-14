import 'package:flutter/material.dart';
import 'package:webapp/components/header_admin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RefundPage extends StatelessWidget {
  const RefundPage({super.key});

  @override
  Widget build(BuildContext context) {
    final messes = ['Konark', 'Anusha', 'Ideal'];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Header(currentPage: 'Refund'),
      ),
      body: Container(
        color: Colors.white,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: messes.map((mess) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: _buildMessCard(context, mess),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

    Widget _buildMessCard(BuildContext context, String mess) {
        //print(mess);
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
            //print(pendingRebates);
            final totalAmount = data['amount'].toString();
            //print(totalAmount);

            return Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                margin: const EdgeInsets.all(12),
                child: SizedBox(
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
                                    mess?? '',
                                    style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    ),
                                ),
                                const SizedBox(height: 20),

                                _buildAlignedTextRow("Manager", 'abc'),
                                const SizedBox(height: 10),

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
                ),
            );
            },
        );
    }

    Future<Map<String, dynamic>> _fetchRebateStats(String messName) async {
        messName = messName.toLowerCase();
        //print("Fetching data for the mess $messName");
        final query = await FirebaseFirestore.instance
                .collection('students')
                .where('mess', isEqualTo: messName)
                .where('refund', isGreaterThan: 0)
                .get();

        final docs = query.docs;
        //print("Query length: ${query.docs.length}");  // See if any documents are returned

        /*if (query.docs.isEmpty) {
            print("No matching students found.");
            } else {
            query.docs.forEach((doc) {
                print(doc.data()); 
            });
        }*/

        int totalPending = docs.length;
        //print(totalPending);
        double totalAmount = docs.fold(0.0, (sum, doc) {
            return sum + (doc['refund'] as num).toDouble();
        });
        //print(totalAmount);
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
