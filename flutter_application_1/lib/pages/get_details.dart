import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/components/user_provider.dart';
import 'package:flutter_application_1/pages/image.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GetStudentDetails extends StatefulWidget {
  const GetStudentDetails({super.key});

  @override
  State<GetStudentDetails> createState() => _GetStudentDetailsState();
}

const authOutlineInputBorder = OutlineInputBorder(
  borderSide: BorderSide(color: Color(0xFF757575)),
  borderRadius: BorderRadius.all(Radius.circular(100)),
);

class _GetStudentDetailsState extends State<GetStudentDetails> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _formCompleted = false;
  late User _currentUser;

  final TextEditingController yearController = TextEditingController();
  final TextEditingController degreeController = TextEditingController();
  final TextEditingController bankaccountController = TextEditingController();
  final TextEditingController ifscController = TextEditingController();
  final TextEditingController entryNoController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<String> degreeOptions = ['BTech', 'MTech', 'PhD', 'MSc'];
  String? downloadUrl;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser!;
    degreeController.addListener(_updateDegreeValue);
  }

  void _updateDegreeValue() {
    setState(() {}); // Refresh UI when degree changes
  }

  Future<void> _uploadProfilePicture() async {
    try {
      final imageUrl = await showDialog<String>(
        context: context,
        builder: (BuildContext context) => const ImageUploadDialog(),
      );
      if (imageUrl != null) {
        setState(() => downloadUrl = imageUrl);
      }
    } catch (e) {
      _showErrorSnackbar("Error saving profile picture: ${e.toString()}");
    }
  }

  Future<void> _submitDetails() async {
    if (_formKey.currentState!.validate() && downloadUrl != null) {
      try {
        final batch = '${degreeController.text}${yearController.text}';
        final messSnapshot = await _firestore.collection('mess').doc('messAllotment').get();

        setState(() => _formCompleted = true);

        Navigator.pop(context, {
          'year': yearController.text.trim(),
          'degree': degreeController.text.trim(),
          'bankAccount': bankaccountController.text.trim(),
          'ifsc': ifscController.text.trim(),
          'downloadUrl': downloadUrl,
          'entryNo': entryNoController.text.trim(),
          'mess': messSnapshot['messAllot'][batch] as String,
        });
      } catch (e) {
        _showErrorSnackbar("Submission failed: ${e.toString()}");
      }
    } else if (downloadUrl == null) {
      _showErrorSnackbar("Please upload a profile picture");
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // User pressed back, abandon registration
        Navigator.pop(context, null);
        return false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        body: Container(
          color: Colors.white,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = constraints.maxWidth < 650 
                  ? constraints.maxWidth * 0.9 
                  : 600;

              return Center(
                child: SingleChildScrollView(
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 2,
                    child: Container(
                      width: cardWidth.toDouble(),
                      padding: const EdgeInsets.all(24),
                      child: _buildFormContent(),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "FILL DETAILS",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        const Text(
          "Enter the details below to sign up",
          style: TextStyle(color: Color(0xFF757575)),
        ),
        const SizedBox(height: 20),
        Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField("Year", yearController, 
                  keyboardType: TextInputType.number),
              _buildTextField("Entry Number", entryNoController),
              _buildDegreeDropdown(),
              _buildTextField("Bank Account Number", bankaccountController,
                  validator: _validateBankAccount),
              _buildTextField("IFSC Code", ifscController,
                  validator: _validateIfscCode),
              _buildImageUploadSection(),
              _buildSubmitButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDegreeDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
                             child: FractionallySizedBox(
                                widthFactor: 0.95,
                                child: DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  isDense: false, // Ensures the dropdown is not overly compact
                                  alignment: Alignment.centerLeft, // Aligns the text properly
                                  itemHeight: 48, // Adjusted item height to ensure text is not cut off
                                  style: const TextStyle(fontSize: 16, height: 1.5), // Adjusted line height for better visibility
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please Select Degree Type';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Degree Type',
                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                    hintText: 'Select Degree Type',
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8), // Increased vertical padding
                                    border: authOutlineInputBorder,
                                    enabledBorder: authOutlineInputBorder,
                                    focusedBorder: authOutlineInputBorder.copyWith(
                                      borderSide: const BorderSide(color: Color(0xFFFF7643)),
                                    ),
                                  ),
                                  items: degreeOptions.map((degree) {
                                    return DropdownMenuItem(
                                      value: degree,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0), // Padding inside the dropdown menu
                                        child: Text(
                                          degree,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      degreeController.text = value!;
                                    });
                                  },
                                  value: degreeController.text.isNotEmpty
                                      ? degreeController.text
                                      : null,
                                  dropdownColor: Colors.white, // Background color for dropdown menu
                                  menuMaxHeight: 300, // Ensures dropdown menu does not stretch too much
                                ),
                              ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType? keyboardType, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: FractionallySizedBox(
        widthFactor: 0.95,
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: validator ?? (value) => 
              value?.isEmpty ?? true ? 'Please enter $label' : null,
        ),
      ),
    );
  }

  String? _validateBankAccount(String? value) {
    if (value == null || !RegExp(r'^\d{12}$').hasMatch(value)) {
      return "Must be 12-digit account number";
    }
    return null;
  }

  String? _validateIfscCode(String? value) {
    if (value == null || !RegExp(r'^[A-Za-z]{4}0\d{6}$').hasMatch(value)) {
      return "Invalid IFSC format (e.g., ABCD0123456)";
    }
    return null;
  }

  Widget _buildImageUploadSection() {
    return Column(
      children: [
        if (downloadUrl != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(downloadUrl!, height: 150),
            ),
          ),
          const Text("Image preview", style: TextStyle(color: Colors.grey)),
        ],
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: _uploadProfilePicture,
          icon: const Icon(Icons.upload, color: Colors.white),
          label: const Text("Upload Profile Picture",
              style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF0753C),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: ElevatedButton(
        onPressed: _submitDetails,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF0753C),
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text(
          "Submit Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
