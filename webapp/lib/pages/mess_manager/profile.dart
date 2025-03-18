import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class MessManagerProfile extends StatefulWidget {
  @override
  _MessManagerProfileState createState() => _MessManagerProfileState();
}

class _MessManagerProfileState extends State<MessManagerProfile> {
  File? _image;
  bool isEditing = false;

  // Initial details (pre-filled)
  String firstName = "John";
  String lastName = "Doe";
  String messName = "Sunrise Mess";

  // Controllers for editing
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController messNameController = TextEditingController();

  // List of Mess Committee Members
  List<Map<String, String>> messCommittee = [
    {"name": "Alice Johnson", "role": "Treasurer"},
    {"name": "Bob Smith", "role": "Food Quality Head"},
    {"name": "Charlie Brown", "role": "Procurement Manager"},
    {"name": "David Lee", "role": "Inventory Head"},
  ];

  @override
  void initState() {
    super.initState();
    firstNameController.text = firstName;
    lastNameController.text = lastName;
    messNameController.text = messName;
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mess Manager Profile'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            width: 350, // Fixed width for a card-like design
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Profile Picture Upload
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _image != null ? FileImage(_image!) : null,
                    child: _image == null
                        ? Icon(Icons.camera_alt, size: 40, color: Colors.grey[700])
                        : null,
                  ),
                ),
                SizedBox(height: 15),

                // Editable Details
                buildProfileField("First Name", firstNameController),
                buildProfileField("Last Name", lastNameController),
                buildProfileField("Mess Name", messNameController),

                SizedBox(height: 15),

                // Edit Button
                isEditing
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                            onPressed: () {
                              setState(() {
                                isEditing = false;
                                // Reset fields if canceled
                                firstNameController.text = firstName;
                                lastNameController.text = lastName;
                                messNameController.text = messName;
                              });
                            },
                            child: Text("Cancel", style: TextStyle(fontSize: 16)),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                            ),
                            onPressed: () {
                              setState(() {
                                isEditing = false;
                                firstName = firstNameController.text;
                                lastName = lastNameController.text;
                                messName = messNameController.text;
                              });
                            },
                            child: Text("Save", style: TextStyle(fontSize: 16)),
                          ),
                        ],
                      )
                    : TextButton.icon(
                        onPressed: () {
                          setState(() {
                            isEditing = true;
                          });
                        },
                        icon: Icon(Icons.edit, color: Colors.orange),
                        label: Text("Edit Profile", style: TextStyle(color: Colors.orange)),
                      ),

                SizedBox(height: 20),

                // Mess Committee Section
                Text(
                  "Mess Committee Members",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),

                // Mess Committee List
                Column(
                  children: messCommittee.map((member) {
                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.symmetric(vertical: 5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.person, color: Colors.orange),
                        title: Text(member["name"]!, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        subtitle: Text(member["role"]!, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                        trailing: Icon(Icons.more_vert, color: Colors.black54),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget for displaying profile fields
  Widget buildProfileField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        isEditing
            ? TextField(
                controller: controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              )
            : Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(controller.text, style: TextStyle(fontSize: 16)),
              ),
        SizedBox(height: 10),
      ],
    );
  }
}
