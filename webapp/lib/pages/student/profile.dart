import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:webapp/components/header_student.dart';
import 'package:webapp/models/student.dart';
import 'package:webapp/services/database.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

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
  String? uid;
  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _fetchUserData(uid!);
    }
  }

  Future<void> _fetchUserData(String uid) async {
    DatabaseModel dbService = DatabaseModel();
    try {
      DocumentSnapshot studentInfo = await dbService.getStudentInfo(uid);
      setState(() {
        student = StudentModel.fromJson(studentInfo.data() as Map<String, dynamic>);
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
    uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _fetchUserData(uid!);
    }
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
                                student?.url != null ? NetworkImage(student!.url) : null,
                            child: student?.url == null
                                ? const Icon(Icons.person, size: 50)
                                : null,
                            
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          student?.name ?? "Unknown",
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
                          _buildInfoRow("Entry Number", student?.name ?? "N/A"),
                          _buildInfoRow("Email", student?.email ?? "N/A"),
                          _buildInfoRow("Degree", student?.degree ?? "N/A"),
                          _buildInfoRow("Year", student?.year ?? "N/A"),
                          _buildInfoRow("Bank Account", student?.bank_account_number ?? "N/A"),
                          _buildInfoRow("IFSC Code", student?.ifsc_code ?? "N/A"),
                          _buildInfoRow("Mess", student?.mess != null ? student!.mess[0].toUpperCase() + student!.mess.substring(1) : "N/A"),
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
                    } else if (!RegExp(r'^\d{12}$').hasMatch(value)){
                      return 'Account number must be exactly 12 digits';
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
                    } else if (!RegExp(r'^[A-Za-z]{4}0\d{6}$').hasMatch(value)){
                      return 'Invalid IFSC code format';
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
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    final currentUser = FirebaseAuth.instance.currentUser;

                    if (currentUser != null) {
                      final uid = currentUser.uid;

                      await FirebaseFirestore.instance
                          .collection('students')
                          .doc(uid)
                          .update({
                        'bank_account_number': accountNumber,
                        'ifsc_code': ifscCode,
                      });

                      print('Bank details updated for $uid');
                      Navigator.of(context).pop();

                      // Optionally show a lil confirmation snackie
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Bank details updated successfully'),
                          backgroundColor: Color(0xFF4CAF50),
                        ),
                      );
                    } else {
                      print("User not logged in");
                    }
                  } catch (e) {
                    print(' Error updating bank details: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to update bank details'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
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