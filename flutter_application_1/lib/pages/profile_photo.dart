import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_application_1/components/user_provider.dart';
import 'package:flutter_application_1/services/database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'home.dart';  // Import your HomeScreen
import 'dart:io';  // Add this import to use the File class


class ProfileSetupScreen extends StatefulWidget {
  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  late User? _user;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    if (_user != null && _user?.photoURL == null) {
      // If the user has not uploaded a profile picture, prompt them to upload
      _showUploadProfilePictureDialog();
    }
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // You can safely access inherited widgets here, like Theme.of(context), MediaQuery.of(context), etc.
    // E.g., accessing the theme or media query now after the widget tree is built
  }
  
  // Show dialog to upload profile picture
  void _showUploadProfilePictureDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Profile Picture Required"),
          content: Text("Please upload a profile picture to proceed."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _pickImage();
              },
              child: Text("Upload Picture"),
            ),
          ],
        );
      },
    );
  }

  // Pick image from gallery or camera
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Upload image to Firebase Storage
      await _uploadProfilePicture(image);
    }
  }

  // Upload the image to Firebase Storage and update the user's profile
  Future<void> _uploadProfilePicture(XFile image) async {
    try {
      setState(() {
        _isLoading = true;
      });
      String? uid = Provider.of<UserProvider>(context).uid;
      if(uid==null)
      {
        return null;
      }
      DatabaseModel dbService = DatabaseModel(uid: uid);
      DocumentSnapshot student_info = await dbService.getStudentInfo(uid);
      // Upload the image to Firebase Storage
      String fileName = student_info['name'];
      Reference storageRef = FirebaseStorage.instance.ref().child("profile_pictures/$fileName.jpg");

      UploadTask uploadTask = storageRef.putFile(
        File(image.path),
      );

      // Wait for the upload to complete
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);

      // Get the download URL of the uploaded image
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      // Update the user's profile with the image URL
      await _user?.updateProfile(photoURL: downloadUrl);

      // Successfully uploaded image, navigate to Home Screen
      setState(() {
        _isLoading = false;
      });

      // Navigate to Home Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()), // HomeScreen is your main page
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error uploading image: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Upload Profile Picture")),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _user?.photoURL != null
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(_user!.photoURL!),
                          radius: 50,
                        )
                      : Icon(Icons.account_circle, size: 100),
                  SizedBox(height: 20),
                  _user?.photoURL == null
                      ? ElevatedButton(
                          onPressed: _pickImage,
                          child: Text("Upload Profile Picture"),
                        )
                      : Container(),
                ],
              ),
      ),
    );
  }
}
