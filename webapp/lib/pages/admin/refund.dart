import 'package:flutter/material.dart';
import 'package:webapp/components/header_admin.dart';

class RefundPage extends StatelessWidget {
  const RefundPage({super.key});

  @override
  Widget build(BuildContext context) {
    final messes = [
      {'name': 'Konark', 'manager': 'John Doe', 'rebates': '120'},
      {'name': 'Anusha', 'manager': 'Jane Smith', 'rebates': '95'},
      {'name': 'Ideal', 'manager': 'Robert Brown', 'rebates': '80'},
    ];

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

 Widget _buildMessCard(BuildContext context, Map<String, String> mess) {
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
                mess['name'] ?? '',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Manager Row
              _buildAlignedTextRow("Manager", mess['manager']),
              const SizedBox(height: 10),

              // Pending Rebates Row
              _buildAlignedTextRow("Pending Rebates", mess['rebates']),

              const SizedBox(height: 10),

              _buildAlignedTextRow("Total Amount", mess['rebates']),

              const SizedBox(height: 20),

              // View Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/rebate_history',
                    arguments: mess['name'],
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
