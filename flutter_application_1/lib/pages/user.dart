import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/components/navbar.dart';
import 'package:flutter_application_1/components/user_provider.dart';
import 'package:flutter_application_1/models/student.dart';
import 'package:flutter_application_1/services/database.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';

import '../components/footer.dart';
import '../components/header.dart';

class UserPage extends StatefulWidget {
  
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  UserPage({super.key});

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  File? _image;
  final picker = ImagePicker();

  
  late StudentModel student;
  bool isDataLoaded = false; // Track data loading state

  // Separate method to handle async work
  Future<void> _fetchUserData(String uid) async {
    // Initialize the DatabaseModel to fetch user and student data

    DatabaseModel dbService = DatabaseModel(uid: uid);
    try {
      
      DocumentSnapshot? studentInfo = await dbService.getStudentInfo(uid);

      // Update the user and student models inside setState to rebuild the UI
      setState(() {
        student =
            StudentModel.fromJson(studentInfo!.data() as Map<String, dynamic>);
            print("Student data");
            print(studentInfo.data());
        isDataLoaded = true; // Set the loading flag to true
      });
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        isDataLoaded =
            false; // Ensure data loading flag is set in case of error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String? uid = Provider.of<UserProvider>(context).uid;

    // If the UID is null, show an error message or loading indicator
    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: Text('User Page')),
        body: Center(
          child: Text("No user found. Please log in."),
        ),
      );
    }

    // Fetch data if UID is available and not already loaded
    if (!isDataLoaded) {
      _fetchUserData(uid);
    }
    return Scaffold(
      key: widget.scaffoldKey,
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56),
        child: Header(scaffoldKey: widget.scaffoldKey),
      ),
      drawer: Navbar(),
      body: !isDataLoaded
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Container(
                //   height: 220,
                //   decoration: BoxDecoration(
                //     color: Colors.white,
                //     borderRadius: BorderRadius.only(
                //       bottomLeft: Radius.circular(40),
                //       bottomRight: Radius.circular(40),
                //     ),
                //   ),
                // ),
                SizedBox(height: 20),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: student.url != ''
                      ? NetworkImage(student.url)
                      : null,
                  child: student.url == ''
                      ? Icon(Icons.person, size: 50, color: Colors.white)
                      : null,
                ),
                SizedBox(height: 20),
                Text(student.name.toUpperCase(),
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
                SizedBox(height: 10),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 32.0),
                      child:
                          Column(crossAxisAlignment:
                              CrossAxisAlignment.start, children:
                              [
                                infoRow("Entry Number", student.entryNumber),
                                infoRow("Degree", student.degree),
                                infoRow("Year", student.year),
                                infoRow("Mess", "${student.mess.toUpperCase()} MESS"),
                             const SizedBox(height: 30),
                                _buildBankDetailsTile(),
                                //_buildIssueNewMessIDTile(),
                              ]),
                    ),
                  ),
                ),
                 CustomNavigationBar(),
              ],
            ),
    );
  }

  /// Builds the Issue New Mess ID Card accordion tile.
Widget _buildIssueNewMessIDTile() {
  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    color: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: Theme(
      data: ThemeData().copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        backgroundColor: Colors.white,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          "Issue New Mess ID Card",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0,2,16,16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _image == null
                                  ? Center(child: Text("No image selected."))
                                  : Center(child: Image.file(_image!, height: 100)),
                              SizedBox(height: 10),
                              Center(child: 
                              ElevatedButton(
                                onPressed: _pickImage,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFFF6F2B),
                                ),
                                child: Text("Upload Photo"
                                , style: TextStyle(
                                  color: Color(0xFFFFFFFF),
                                ),),
                              ),
                              ),
                              SizedBox(height: 10),
                              Center(
                                child:ElevatedButton(
                                onPressed: _uploadImage,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFFF6F2B),
                                ),
                                child: Text(
                                  "Submit", 
                                  style: TextStyle(
                                  color: Color(0xFFFFFFFF),
                                  ),
                                ),
                              ),
                              ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}


  /// Builds the bank details accordion tile.
  Widget _buildBankDetailsTile() {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          backgroundColor: Colors.white,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Bank Details",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          childrenPadding: const EdgeInsets.all(20),
          children: [
            infoRow("Account Number", student.bank_account_number),
            infoRow("IFSC Code", student.ifsc_code),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: _showBankDetailsDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF0753C),
                  foregroundColor: Colors.white,
                ),
                child: const Text("Change Bank Details"),
              ),
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
                    } else if (!RegExp(r'^\d{12}$').hasMatch(value)) {
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
                    } else if (!RegExp(r'^[A-Za-z]{4}0\d{6}$').hasMatch(value)) {
                      return 'Enter a valid IFSC (e.g., SBIN0123456)';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    ifscCode = value.toUpperCase();
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
                    await FirebaseFirestore.instance
                        .collection('students')
                        .doc(student.uid)
                        .update({
                      'bank_account_number': accountNumber,
                      'ifsc_code': ifscCode,
                    });
                    //print("bank details updated");

                    setState(() {
                      student.bank_account_number = accountNumber;
                      student.ifsc_code = ifscCode;
                    });

                    Navigator.of(context).pop();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Bank details updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    print("Error updating bank details: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to update details. Try again.'),
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



  Widget infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
          Text(value, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      String extension = path.extension(pickedFile.path).toLowerCase();
      if (extension == '.jpg' || extension == '.jpeg' || extension == '.png') {
        setState(() {
          _image = File(pickedFile.path);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Only JPG, JPEG, and PNG files are allowed.')),
        );
      }
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://your-backend-url.com/upload'),
    );
    request.files.add(
      await http.MultipartFile.fromPath('file', _image!.path),
    );
    var response = await request.send();
    if (response.statusCode == 200) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Upload Successful'),
            content: Text(
                'Photo uploaded successfully. You can collect your ID card from the mess manager in 2-3 days.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}