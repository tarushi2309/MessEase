import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:webapp/components/user_provider.dart';
import 'package:webapp/pages/student/image.dart';

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

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
        content:
            Text("Error saving profile picture to Firestore:\n$e"),
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
        await _firestore.collection('students').doc(uid).set({
          'year': yearController.text.trim(),
          'degree': degreeController.text.trim(),
          'bankAccount': bankaccountController.text.trim(),
          'ifsc': ifscController.text.trim(),
          'profileImage': downloadUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Details submitted successfully!"),
        ));
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
                                "Year", yearController,
                                keyboardType: TextInputType.number,
                              ),
                              buildResponsiveTextField(
                                "Degree", degreeController,
                              ),
                              buildResponsiveTextField(
                                "Bank Account Number",
                                bankaccountController,
                                keyboardType: TextInputType.number,
                              ),
                              buildResponsiveTextField(
                                "IFSC Code", ifscController,
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
                              ElevatedButton.icon(
                                onPressed: _uploadProfilePicture,
                                icon: const Icon(Icons.upload, color: Colors.white,),
                                label: const Text("Upload Profile Picture", style: TextStyle(color: Colors.white, 
                                fontWeight: FontWeight.w500, fontSize: 16
                                ),),
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
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: FractionallySizedBox(
        widthFactor: 0.85,
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
          validator: (value) {
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
