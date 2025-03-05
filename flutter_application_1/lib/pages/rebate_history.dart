import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../components/footer.dart';
import '../components/header.dart';
import '../components/navbar.dart';
import '../services/database.dart'; // Import DatabaseService

class RebateHistoryScreen extends StatefulWidget {
  final String userId; // Pass user ID to fetch data

  RebateHistoryScreen({super.key, required this.userId});

  @override
  _RebateHistoryScreenState createState() => _RebateHistoryScreenState();
}

class _RebateHistoryScreenState extends State<RebateHistoryScreen> {
  late DatabaseModel dbService;
  List<Map<String, dynamic>> rebateHistory = []; 

  @override
  void initState() {
    super.initState();
    dbService = DatabaseModel(uid: widget.userId);
    fetchRebateHistory();
  }

  Future<void> fetchRebateHistory() async {
    List<Map<String, dynamic>> history = await dbService.getRebateHistory(widget.userId);
    setState(() {
      rebateHistory = history;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56),
        child: Header(scaffoldKey: GlobalKey<ScaffoldState>()),
      ),
      drawer: Navbar(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Rebate Tracker",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w400, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 10),
            
            // Rebate Summary Card (Placeholder)
            FutureBuilder<List<Map<String, dynamic>>>(
              future: dbService.getRebateHistory(widget.userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text("Error loading rebate data.");
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text("No rebate history found.");
                }

                int totalRebateDays = snapshot.data!.fold(0, (sum, item) => sum + (item['days'] as int));
                return RebateSummaryCard(rebateDays: totalRebateDays);
              },
            ),

            const SizedBox(height: 20),

            Center(
              child: Text(
                "Rebate History",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w400, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 10),

            // Display Rebate History
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: dbService.getRebateHistory(widget.userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error loading rebate history."));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("No rebate history found."));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final rebate = snapshot.data![index];
                      return _buildRebateCard(rebate['from'], rebate['to'], rebate['days'], rebate['status']);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(),
    );
  }

  Widget _buildRebateCard(String from, String to, int days, String status) {
    Color statusColor = status == 'Approved' ? Colors.green : Colors.orange;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          title: Text(
            'From: $from \nTo: $to',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          subtitle: Text('Number of days: $days'),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

class RebateSummaryCard extends StatelessWidget {
  final int rebateDays;

  const RebateSummaryCard({super.key, required this.rebateDays});

  @override
  Widget build(BuildContext context) {
    int rebateAmount = rebateDays * 130;
    double filledPercentage = rebateDays / 21;
    Color pieColor = Color(0xFFE06635);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Rebate Amount',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '₹$rebateAmount',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFF0753C)),
                  ),
                ],
              ),
            ),

            Column(
              children: [
                SizedBox(
                  height: 100,
                  width: 100,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(color: pieColor, value: rebateDays.toDouble(), radius: 30),
                        PieChartSectionData(color: Colors.grey[300]!, value: (21 - rebateDays).toDouble(), radius: 30),
                      ],
                      sectionsSpace: 2,
                      centerSpaceRadius: 30,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text('$rebateDays / 21 Days', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
