import 'package:flutter/material.dart';

import '../components/footer.dart';
import '../components/header.dart';
import '../components/navbar.dart';
import '../pages/RebateForm.dart';

class RebateHistoryScreen extends StatefulWidget {
  @override
  _RebateHistoryScreenState createState() => _RebateHistoryScreenState();
}

class _RebateHistoryScreenState extends State<RebateHistoryScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  // Hardcoded data
  List<Map<String, String>> rebateHistory = [
    {
      'from': '13/02/2025',
      'to': '20/02/2025',
      'days': '7',
      'status': 'Approved'
    },
    {
      'from': '05/01/2025',
      'to': '12/01/2025',
      'days': '7',
      'status': 'Approved'
    },
  ];

  // Simulated database fetch function
  Future<List<Map<String, String>>> fetchRebateHistory() async {
    await Future.delayed(Duration(seconds: 2)); // Simulating network delay
    return [
      {
        'from': '01/12/2024',
        'to': '08/12/2024',
        'days': '7',
        'status': 'Pending'
      },
      {
        'from': '20/11/2024',
        'to': '27/11/2024',
        'days': '7',
        'status': 'Approved'
      }
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56),
        child: Header(scaffoldKey: scaffoldKey),
      ),
      drawer: Navbar(),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Rebate History", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            
            // Hardcoded Entries
            ...rebateHistory.map((rebate) => buildRebateCard(rebate)).toList(),
            
            // Fetched Entries from Database
            FutureBuilder(
              future: fetchRebateHistory(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error fetching data"));
                } else {
                  List<Map<String, String>> fetchedData = snapshot.data as List<Map<String, String>>;
                  return Column(
                    children: fetchedData.map((rebate) => buildRebateCard(rebate)).toList(),
                  );
                }
              },
            ),
            
            Spacer(),
            
            // Apply Rebate Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF0753C),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RebateFormPage()),
                  );
                },
                child: Text("Apply Rebate", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(selectedIndex: 1),
    );
  }

  // Widget for building a rebate history card
  Widget buildRebateCard(Map<String, String> rebate) {
    return Card(
      color: Color(0xFFF0753C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("From -", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(rebate['from']!, style: TextStyle(color: Colors.white)),
                Text(rebate['status']!, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
              ],
            ),
            SizedBox(height: 5),
            Text("To - ${rebate['to']!}", style: TextStyle(color: Colors.white)),
            SizedBox(height: 5),
            Text("Days - ${rebate['days']!}", style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
