import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../components/footer.dart';
import '../components/header.dart';
import '../components/navbar.dart';

class RebateHistoryScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  RebateHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56),
        child: Header(scaffoldKey: scaffoldKey),
      ),
      drawer: Navbar(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              Text(
                "REBATE TRACKER",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            const SizedBox(height: 10),
            // Rebate Amount and Pie Chart
            RebateSummaryCard(rebateDays: 15),

            const SizedBox(height: 20),

            // Rebate History Title
            Center(
              child: Text(
                "Rebate History",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Rebate History Cards
            Expanded(
              child: ListView(
                children: [
                  _buildRebateCard('2024-01-01', '2024-01-10', 10, 'Approved'),
                  _buildRebateCard('2024-02-05', '2024-02-15', 11, 'Pending'),
                  _buildRebateCard('2024-03-01', '2024-03-07', 7, 'Approved'),
                ],
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
            // Rebate Amount
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
                    '₹$rebateAmount', // Dynamic amount
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF0753C),
                    ),
                  ),
                ],
              ),
            ),

            // Pie Chart
            Column(
              children: [
                SizedBox(
                  height: 100,
                  width: 100,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          color: pieColor,
                          value: rebateDays.toDouble(),
                          radius: 30,
                        ),
                        PieChartSectionData(
                          color: Colors.grey[300]!,
                          value: (21 - rebateDays).toDouble(),
                          radius: 30,
                        ),
                      ],
                      sectionsSpace: 2,
                      centerSpaceRadius: 30,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  '$rebateDays / 21 Days',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
