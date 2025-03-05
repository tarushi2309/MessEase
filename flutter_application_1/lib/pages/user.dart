import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/user_provider.dart';
import 'package:flutter_application_1/models/student.dart';
import 'package:flutter_application_1/models/user.dart';
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

  late UserModel user;
  late StudentModel student;
  bool isDataLoaded = false; // Track data loading state

  
  
  // Separate method to handle async work
  Future<void> _fetchUserData(String uid) async {

    // Initialize the DatabaseModel to fetch user and student data
   
      DatabaseModel dbService = DatabaseModel(uid: uid);
      try {
        DocumentSnapshot user_info = await dbService.getUserInfo(uid);
        DocumentSnapshot student_info = await dbService.getStudentInfo(uid);

        // Update the user and student models inside setState to rebuild the UI
        setState(() {
          user = UserModel.fromJson(user_info.data() as Map<String, dynamic>);
          student = StudentModel.fromJson(student_info.data() as Map<String, dynamic>);
          isDataLoaded = true; // Set the loading flag to true
        });
      } catch (e) {
        print("Error fetching data: $e");
        setState(() {
          isDataLoaded = false; // Ensure data loading flag is set in case of error
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
      body: !isDataLoaded // Show a loading spinner while data is loading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Header(scaffoldKey: GlobalKey<ScaffoldState>()),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey.shade300,
                            child: Icon(Icons.person, size: 50, color: Colors.white),
                          ),
                          SizedBox(height: 10),
                          Text("${user.name}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(height: 5),
                          infoRow("Entry Number", "${student.entryNumber}"),
                          infoRow("Degree", "${student.degree}"),
                          infoRow("Year", "${student.year}"),
                          infoRow("Mess", "Konark Mess"),
                          SizedBox(height: 20),
                          ExpansionTile(
                            title: Text("Bank Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            children: [
                              infoRow("Account Number", "${student.bank_account_number}"),
                              infoRow("IFSC Code", "${student.ifsc_code}"),
                            ],
                          ),
                          ExpansionTile(
                            title: Text("Issue New Mess ID Card", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            children: [
                              _image == null
                                  ? Text("No image selected.")
                                  : Image.file(_image!, height: 100),
                              SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: _pickImage,
                                child: Text("Upload Photo"),
                              ),
                              SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: _uploadImage,
                                child: Text("Submit"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                CustomNavigationBar(),
              ],
            ),
    );
  }

  Widget infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
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
            content: Text('Photo uploaded successfully. You can collect your ID card from the mess manager in 2-3 days.'),
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
