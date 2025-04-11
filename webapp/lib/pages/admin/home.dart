import 'package:flutter/material.dart';
import 'package:webapp/components/header_admin.dart';
import 'package:webapp/models/mess.dart';
import 'package:webapp/services/database.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _messOptions = ["Anusha", "Konark", "Ideal"];

  // State variables for each batch's mess selection.
  String _selectedMessBtech_1 = "Anusha";
  String _selectedMessBtech_2 = "Anusha";
  String _selectedMessBtech_3 = "Anusha";
  String _selectedMessBtech_4 = "Anusha";
  String _selectedMessMtech_1 = "Anusha";
  String _selectedMessMtech_2 = "Anusha";
  String _selectedMessMsc_1 = "Anusha";
  String _selectedMessMsc_2 = "Anusha";
  String _selectedMessPhd = "Anusha";

  Future<void> allot_mess()
  async {
    Map<String,String> messAllot;
    messAllot = {
      "BTech1": _selectedMessBtech_1,
      "BTech2": _selectedMessBtech_2,
      "BTech3": _selectedMessBtech_3,
      "BTech4": _selectedMessBtech_4,
      "MTech1": _selectedMessMtech_1,
      "MTech2": _selectedMessMtech_2,
      "MSc1": _selectedMessMsc_1,
      "MSc2": _selectedMessMsc_2,
      "PhD": _selectedMessPhd
    };
    MessModel mess = MessModel(messAllot : messAllot);
    DatabaseModel dbservice = DatabaseModel();
    await dbservice.addMessDetails(mess);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Header(currentPage: 'Home'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // For screens less than 800 pixels wide, use a vertical layout.
          if (constraints.maxWidth < 800) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  // Wrap each card in a SizedBox to force a fixed height.
                  SizedBox(height: 600, child: _buildAllotMessesCard()),
                  const SizedBox(height: 16),
                  SizedBox(height: 400, child: _buildViewMessDetailsCard()),
                ],
              ),
            );
          } else {
            // For larger screens, display side-by-side.
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildAllotMessesCard()),
                  const SizedBox(width: 16),
                  Expanded(flex: 3, child: _buildViewMessDetailsCard()),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  // Builds the "Allot Messes" card.
  Widget _buildAllotMessesCard(){
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
              "Allot Messes",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Scrollable form fields.
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildFieldRow("BTech (1st Year)", _selectedMessBtech_1,
                        (val) => setState(() => _selectedMessBtech_1 = val ?? "")),
                    const SizedBox(height: 16),
                    _buildFieldRow("BTech (2nd Year)", _selectedMessBtech_2,
                        (val) => setState(() => _selectedMessBtech_2 = val ?? "")),
                    const SizedBox(height: 16),
                    _buildFieldRow("BTech (3rd Year)", _selectedMessBtech_3,
                        (val) => setState(() => _selectedMessBtech_3 = val ?? "")),
                    const SizedBox(height: 16),
                    _buildFieldRow("BTech (4th Year)", _selectedMessBtech_4,
                        (val) => setState(() => _selectedMessBtech_4 = val ?? "")),
                    const SizedBox(height: 16),
                    _buildFieldRow("MTech (1st Year)", _selectedMessMtech_1,
                        (val) => setState(() => _selectedMessMtech_1 = val ?? "")),
                    const SizedBox(height: 16),
                    _buildFieldRow("MTech (2nd Year)", _selectedMessMtech_2,
                        (val) => setState(() => _selectedMessMtech_2 = val ?? "")),
                    const SizedBox(height: 16),
                    _buildFieldRow("MSc (1st Year)", _selectedMessMsc_1,
                        (val) => setState(() => _selectedMessMsc_1 = val ?? "")),
                    const SizedBox(height: 16),
                    _buildFieldRow("MSc (2nd Year)", _selectedMessMsc_2,
                        (val) => setState(() => _selectedMessMsc_2 = val ?? "")),
                    const SizedBox(height: 16),
                    _buildFieldRow("PhD", _selectedMessPhd,
                        (val) => setState(() => _selectedMessPhd = val ?? "")),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            // The "Allot" button always remains visible.
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: (){
                  allot_mess();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Mess Allotted Successfully!")),
                  );
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFFF0753C)),
                  padding: MaterialStateProperty.all<EdgeInsets>(
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                ),
                child: const Text(
                  "Allot",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build a form field row.
  Widget _buildFieldRow(String label, String selectedValue, ValueChanged<String?> onChanged) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: selectedValue,
            decoration: const InputDecoration(
              labelText: "Select Mess",
              border: OutlineInputBorder(),
            ),
            items: _messOptions.map((String mess) {
              return DropdownMenuItem(value: mess, child: Text(mess));
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  // Builds the "View Mess Details" card.
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
            // Use a LayoutBuilder inside the card to get available width for the GridView.
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GridView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 600,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 2.5,
                    ),
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      final List<Map<String, String>> messData = [
                        {"name": "Anusha", "manager": "Alice"},
                        {"name": "Konark", "manager": "Bob"},
                        {"name": "Ideal", "manager": "Charlie"},
                      ];
                      final mess = messData[index];
                      return _buildMessCard(
                        context,
                        mess["name"] ?? "Unknown",
                        mess["manager"] ?? "Unknown",
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

  // Builds a single mess detail card.
  Widget _buildMessCard(BuildContext context, String messName, String managerName) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        height: 300,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left colored stripe.
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
            // Mess details and view button.
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      messName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Manager: $managerName",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/mess_details', arguments: messName);
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFFF0753C)),
                          padding: MaterialStateProperty.all<EdgeInsets>(
                            const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                          ),
                        ),
                        child: const Text(
                          "View Details",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
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
