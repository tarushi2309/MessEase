import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Example values retrieved from backend
  final String year = "3";
  final String degree = "B.Tech CSE";
  final String bankAccount = "1234567890";
  final String ifscCode = "SBIN0001234";
  final String entryNumber = "ABC123456"; // Add your entry number here
  final String mess = "Anusha"; // Example of Mess

  final String? downloadUrl = null; // Replace with backend URL when available

  void _uploadProfilePicture() {
    // Implement your image upload logic
  }

  void _submitDetails() {
    // Submit logic (probably disabled since read-only)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Matching card background
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.history), label: "Rebate History"),
          BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu), label: "Mess Menu"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
        ],
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFF0753C),
                ),
                child: const Align(
                  alignment: Alignment.topLeft,
                  child: Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),

              // Profile and Form Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // LEFT COLUMN - PROFILE PHOTO
                      Expanded(
                        flex: 1,
                        child: Card(
                          color: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                const Text("PROFILE",
                                    style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 16),
                                const CircleAvatar(
                                  radius: 150,
                                  backgroundColor: Colors.grey,
                                  child: Icon(Icons.person, size: 100,color: Colors.white),
                                ),
                                const SizedBox(height: 12),
                                const Text("STUDENT NAME"),
                                const SizedBox(height: 32),
                                ElevatedButton.icon(
                                  onPressed: _uploadProfilePicture,
                                  icon: const Icon(Icons.upload),
                                  label: const Text("Upload"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFF0753C),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 50),

                      // RIGHT COLUMN - FORM
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            // USER DETAILS CARD
                            SizedBox(
                              width: double.infinity,
                              child: _buildCardSection(
                                title: "USER DETAILS",
                                children: [
                                  _buildReadOnlyField("Year", year),
                                  _buildReadOnlyField("Degree", degree),
                                  _buildReadOnlyField("Entry Number", entryNumber),
                                  _buildReadOnlyField("Mess ", mess),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // BANK DETAILS CARD
                            SizedBox(
                              width: double.infinity,
                              child: _buildCardSection(
                                title: "BANK DETAILS",
                                children: [
                                  _buildReadOnlyField("Bank Account Number", bankAccount),
                                  _buildReadOnlyField("IFSC Code", ifscCode),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // MESS ID CARD SECTION
                            SizedBox(
                              width: double.infinity,
                              child: _buildCardSection(
                                title: "ISSUE NEW MESS ID CARD",
                                children: [
                                  if (downloadUrl != null)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(downloadUrl!,
                                            height: 150),
                                      ),
                                    ),
                                  const Text(
                                    "Ensure size of image is less than 32MB",
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton.icon(
                                    onPressed: _uploadProfilePicture,
                                    icon: const Icon(Icons.upload,
                                        color: Colors.white),
                                    label: const Text("Upload Photo"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFFF0753C),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: _submitDetails,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFF0753C),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 50, vertical: 15),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: const Text("Submit",
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ],
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
        ),
      ),
    );
  }

  Widget _buildCardSection(
      {required String title, required List<Widget> children}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "$label: $value",
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
*/