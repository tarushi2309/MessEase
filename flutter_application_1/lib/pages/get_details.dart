import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/user_provider.dart';
import 'package:flutter_application_1/pages/image.dart';
import 'package:flutter_application_1/pages/signin.dart';
import 'package:provider/provider.dart';

class GetStudentDetails extends StatefulWidget {
  const GetStudentDetails({super.key});

  @override
  State<GetStudentDetails> createState() => _GetStudentDetailsState();
}

class _GetStudentDetailsState extends State<GetStudentDetails> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String? uid;
  String? downloadUrl;

  // Controllers
  final TextEditingController yearController = TextEditingController();
  final TextEditingController degreeController = TextEditingController();
  final TextEditingController bankaccountController = TextEditingController();
  final TextEditingController ifscController = TextEditingController();
  final TextEditingController entryNoController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<String> degreeOptions = ['BTech', 'MTech', 'PhD', 'MTech', 'MSc'];

  @override
  void initState() {
    super.initState();
    uid = Provider.of<UserProvider>(context, listen: false).uid;
  }

  Future<void> _uploadProfilePicture() async {
    try {
      String? imageUrl = await showDialog<String>(
        context: context,
        builder: (BuildContext context) => const ImageUploadDialog(),
      );
      if (imageUrl != null) {
        setState(() {
          downloadUrl = imageUrl;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error saving profile picture to Firestore:\n$e"),
      ));
    }
  }

  Future<void> _submitDetails() async {
    if (_formKey.currentState!.validate()) {
      if (downloadUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please upload a profile picture."),
        ));
        return;
      }

      try {
        String batch =
            degreeController.text.trim() + yearController.text.trim();
        DocumentSnapshot messes = await FirebaseFirestore.instance
            .collection('mess')
            .doc('messAllotment')
            .get();

        Navigator.pop(context, {
          'year': yearController.text.trim(),
          'degree': degreeController.text.trim(),
          'bankAccount': bankaccountController.text.trim(),
          'ifsc': ifscController.text.trim(),
          'downloadUrl': downloadUrl, // Add your URL handling logic here,
          'entryNo': entryNoController.text.trim(),
          'mess': messes['messAllot'][batch] as String,
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to submit details: $e"),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        color: Colors.white,
        child: LayoutBuilder(
          builder: (context, constraints) {
            double cardWidth =
                constraints.maxWidth < 650 ? constraints.maxWidth * 0.9 : 600;

            return Center(
              child: SingleChildScrollView(
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 2,
                  child: Container(
                    width: cardWidth,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Text(
                            "FILL DETAILS",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          child: Text(
                            "Enter the details below to sign up",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Color(0xFF757575)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              buildResponsiveTextField(
                                "Year",
                                yearController,
                                keyboardType: TextInputType.number,
                              ),
                              buildResponsiveTextField(
                                "Entry Number",
                                entryNoController,
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 10),
                              FractionallySizedBox(
                                widthFactor: 0.95,
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButtonFormField<String>(
                                    isExpanded: true, // Ensures the dropdown expands properly
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
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
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
                                    value: degreeController.text.isNotEmpty ? degreeController.text : null,
                                    dropdownColor: Colors.white,
                                    menuMaxHeight: 300,
                                  ),
                                ),
                              ),
                              buildResponsiveTextField(
                                "Bank Account Number",
                                bankaccountController,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please enter Bank Account Number";
                                  }
                                  if (!RegExp(r'^\d{12}$').hasMatch(value)) {
                                    return "Bank Account Number must be exactly 12 digits";
                                  }
                                  return null;
                                },
                              ),
                              buildResponsiveTextField(
                                "IFSC Code",
                                ifscController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please enter IFSC Code";
                                  }
                                  if (!RegExp(r'^[A-Za-z]{4}0\d{6}$')
                                      .hasMatch(value)) {
                                    return "Invalid IFSC Code format (e.g., ABCD0123456)";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
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
                                  color: Color.fromARGB(255, 133, 131, 131),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ElevatedButton.icon(
                                onPressed: _uploadProfilePicture,
                                icon: const Icon(
                                  Icons.upload,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  "Upload Profile Picture",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF0753C),
                                  foregroundColor: Colors.white,
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
                                child: const Text(
                                  "Submit Details",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildResponsiveTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator, // Accept custom validators
  }) {
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
          validator: validator ??
              (value) {
                // Use provided validator or default
                if (value == null || value.isEmpty) {
                  return "Please enter $label";
                }
                return null;
              },
        ),
      ),
    );
  }
}