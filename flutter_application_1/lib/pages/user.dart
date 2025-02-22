/*import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../components/footer.dart';
import '../components/header.dart';

class UserScreen extends StatefulWidget {
  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  Map<String, dynamic>? userData;
  File? _image;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final response = await http.get(Uri.parse('https://your-backend-api.com/user-details'));
    if (response.statusCode == 200) {
      setState(() {
        userData = json.decode(response.body);
      });
    } else {
      print('Failed to load user data');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://your-backend-api.com/upload-photo'),
    );
    request.files.add(
      await http.MultipartFile.fromPath('photo', _image!.path),
    );
    var response = await request.send();
    if (response.statusCode == 200) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Upload Successful'),
          content: Text('Photo uploaded successfully. Collect ID card from mess manager in 2-3 days.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      print('Failed to upload image');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Header(scaffoldKey: GlobalKey<ScaffoldState>()),
          Expanded(
            child: userData == null
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[300],
                          child: Icon(Icons.person, size: 50, color: Colors.black),
                        ),
                        SizedBox(height: 10),
                        Text(
                          userData!['name'],
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildUserInfoRow('Entry Number', userData!['entry_number']),
                            buildUserInfoRow('Degree', userData!['degree']),
                            buildUserInfoRow('Year', userData!['year'].toString()),
                            buildUserInfoRow('Mess', userData!['mess']),
                          ],
                        ),
                        SizedBox(height: 20),
                        ExpansionTile(
                          title: Text('Bank Details', style: TextStyle(fontWeight: FontWeight.bold)),
                          children: [
                            buildUserInfoRow('Account Name', userData!['bank']['account_name']),
                            buildUserInfoRow('IFSC Code', userData!['bank']['ifsc_code']),
                            buildUserInfoRow('Bank Name', userData!['bank']['bank_name']),
                          ],
                        ),
                        ExpansionTile(
                          title: Text('Issue New Mess ID Card', style: TextStyle(fontWeight: FontWeight.bold)),
                          children: [
                            _image == null
                                ? Text('No image selected')
                                : Image.file(_image!, height: 150),
                            ElevatedButton(
                              onPressed: _pickImage,
                              child: Text('Upload Photo'),
                            ),
                            ElevatedButton(
                              onPressed: _uploadImage,
                              child: Text('Submit'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
          ),
          CustomNavigationBar(selectedIndex: 0),
        ],
      ),
    );
  }

  Widget buildUserInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
*/

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import '../components/footer.dart';
import '../components/header.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  File? _image;
  final picker = ImagePicker();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
                    Text("Ananya Sethi", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    infoRow("Entry Number", "2025CS101"),
                    infoRow("Degree", "B.Tech CSE"),
                    infoRow("Year", "3rd Year"),
                    infoRow("Mess", "Mess A"),
                    SizedBox(height: 20),
                    ExpansionTile(
                      title: Text("Bank Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      children: [
                        infoRow("Account Name", "Ananya Sethi"),
                        infoRow("IFSC Code", "SBIN0001234"),
                        infoRow("Bank Name", "State Bank of India"),
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
          CustomNavigationBar(selectedIndex: 0),
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
}
