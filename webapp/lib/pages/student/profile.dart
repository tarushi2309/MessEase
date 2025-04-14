import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:webapp/components/header_student.dart';
import 'package:webapp/models/student.dart';
import 'package:webapp/services/database.dart';

class ProfileStudentPage extends StatefulWidget {
  const ProfileStudentPage({super.key});

  @override
  State<ProfileStudentPage> createState() => _ProfileStudentPageState();
}

class _ProfileStudentPageState extends State<ProfileStudentPage> {
  File? _image;
  final picker = ImagePicker();

  StudentModel? student;
  bool isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _fetchUserData(uid);
    }
  }

  Future<void> _fetchUserData(String uid) async {
    DatabaseModel dbService = DatabaseModel(uid: uid);
    try {
      DocumentSnapshot studentInfo = await dbService.getStudentInfo(uid);
      setState(() {
        student =
            StudentModel.fromJson(studentInfo.data() as Map<String, dynamic>);
        isDataLoaded = true;
      });
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        isDataLoaded = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Header(currentPage: 'Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left - Profile image and name
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color:Colors.black, width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.4),
                                spreadRadius: 1,
                                blurRadius: 1,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey[200],
                            backgroundImage:
                                _image != null ? FileImage(_image!) : null,
                            child: _image == null
                                ? const Icon(Icons.person, size: 50)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Name",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 20),

                  // Vertical Divider
                  Container(
                    width: 1,
                    height: _buildInfoHeight(),
                    color: Colors.black,
                  ),

                  const SizedBox(width: 20),

                  // Right - Details
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow("Entry Number", "2022csb1112"),
                          _buildInfoRow("Email", "2022csb1112@iitrpr.ac.in"),
                          _buildInfoRow("Degree", "btech"),
                          _buildInfoRow("Year", "2022"),
                          _buildInfoRow("Bank Account", "123456789"),
                          _buildInfoRow("IFSC Code", "1234"),
                          _buildInfoRow("Mess", "konark"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Bottom Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xFFF0753C),
                  ),
                  onPressed: () {
                    _showBankDetailsDialog();
                  },
                  child: const Text("UPLOAD BANK DETAILS", 
                      style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xFFF0753C),
                  ),
                  onPressed: () {
                    // Issue new mess card
                  },
                  child: const Text("ISSUE NEW MESS CARD", 
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  void _showBankDetailsDialog() {
  final _formKey = GlobalKey<FormState>();
  String accountNumber = '';
  String ifscCode = '';

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Update Bank Details'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Bank Account Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter account number';
                  }
                  return null;
                },
                onChanged: (value) {
                  accountNumber = value;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'IFSC Code',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter IFSC code';
                  }
                  return null;
                },
                onChanged: (value) {
                  ifscCode = value;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF0753C),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // TODO: Save to Firebase or local state
                print('Account Number: $accountNumber');
                print('IFSC Code: $ifscCode');
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}


  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 140,
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueGrey),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(value,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            ],
          ),
          const Divider(thickness: 1),
        ],
      ),
    );
  }

  double _buildInfoHeight() {
    return 7 * 44.0; // Approx height per row
  }
}
