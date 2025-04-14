import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  const UserPage({super.key});

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
      
      DocumentSnapshot studentInfo = await dbService.getStudentInfo(uid);

      // Update the user and student models inside setState to rebuild the UI
      setState(() {
        student =
            StudentModel.fromJson(studentInfo.data() as Map<String, dynamic>);
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
      backgroundColor: Colors.white,
      body: !isDataLoaded
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 220,
                      decoration: BoxDecoration(
                        color: Color(0xFFFF8850),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 60,
                      left: 20,
                      child:
                          Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    ),
                    Positioned(
                      bottom: -50,
                      left: MediaQuery.of(context).size.width / 2 - 50,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: student.url != ''
                            ? NetworkImage(student.url)
                            : null,
                        child: student.url == ''
                            ? Icon(Icons.person, size: 50, color: Colors.white)
                            : null,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 60),
                Text(student.name.toUpperCase(),
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
                SizedBox(height: 10),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16.0),
                      child:
                          Column(crossAxisAlignment:
                              CrossAxisAlignment.start, children:
                              [
                                infoRow("Entry Number", student.entryNumber),
                                infoRow("Degree", student.degree),
                                infoRow("Year", student.year),
                                infoRow("Mess", "${student.mess.toUpperCase()} MESS"),
                             const SizedBox(height: 10),
                                _buildBankDetailsTile(),
                                _buildIssueNewMessIDTile(),
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
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
          childrenPadding: EdgeInsets.all(20),
          children: [
            // infoRow("Account Number", "${student.bank_account_number}"),
            // infoRow("IFSC Code", "${student.ifsc_code}"),
            infoRow("Account Number", student.bank_account_number),
            infoRow("IFSC Code", student.ifsc_code)
          ],
        ),
      ),
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
