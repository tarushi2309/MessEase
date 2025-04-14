import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/user_provider.dart';
import 'package:flutter_application_1/models/student.dart';
import 'package:flutter_application_1/pages/get_details.dart';
import 'package:flutter_application_1/services/database.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
// Import your home screen or any other destination after sign in.
import 'home.dart';
import 'image.dart';

const authOutlineInputBorder = OutlineInputBorder(
  borderSide: BorderSide(color: Color(0xFF757575)),
  borderRadius: BorderRadius.all(Radius.circular(100)),
);

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Prevent keyboard causing overflow
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            // Ensures content is scrollable
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Image.asset(
                    'assets/MessEase.png',
                    height: 100,
                    width: 200,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Welcome",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Sign in with your Google Account",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF757575)),
                ),
                const SizedBox(height: 30),
                const SignInForm(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  // Define controllers for the email and password fields.
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? selectedDegree;
  String? downloadUrl;
  String? uid;
  // This function authenticates the user using Firebase.
  Future<void> signIn() async {
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      try {
        // Attempt to sign in using Firebase Authentication.
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: emailController.text, password: passwordController.text);

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "Sign In Successful",
            style: TextStyle(fontSize: 20.0),
          ),
        ));
        String uid = userCredential.user!.uid;
        Provider.of<UserProvider>(context, listen: false).setUid(uid);
        // Navigate to your home screen after successful login.
        // Replace HomeScreen() with your actual home screen widget.
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      } on FirebaseAuthException catch (e) {
        if (e.code == "user-not-found") {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "No user found with that email.",
                style: TextStyle(fontSize: 18.0),
              )));
        } else if (e.code == "wrong-password") {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "Incorrect password.",
                style: TextStyle(fontSize: 18.0),
              )));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "Sign In Failed. Please try again.",
                style: TextStyle(fontSize: 18.0),
              )));
        }
      }
    } else {
      // If any of the fields are empty, inform the user.
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.orangeAccent,
          content: Text(
            "Please fill in both email and password.",
            style: TextStyle(fontSize: 18.0),
          )));
    }
  }

  Future<void> signInGoogle() async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
      final googleUser = await GoogleSignIn().signIn();
      final googleAuth = await googleUser?.authentication;
      final cred = GoogleAuthProvider.credential(
          idToken: googleAuth?.idToken, accessToken: googleAuth?.accessToken);
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(cred);
      uid = userCredential.user!.uid;
      Provider.of<UserProvider>(context, listen: false).setUid(uid!);

      final AdditionalUserInfo? info = userCredential.additionalUserInfo;
      Map<String, dynamic>? userInfo = info?.profile;
      bool newUser = info!.isNewUser;
      if(newUser)
      {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "This account does not exist.Please signUp.",
              style: TextStyle(fontSize: 18.0),
            )));
      }
      if (userInfo != null) {
        String checkIIT = userInfo['hd'];
        if (checkIIT == "iitrpr.ac.in") {
              final DatabaseModel dbService = DatabaseModel(uid: uid!);
              DocumentSnapshot student=await dbService.getStudentInfo(uid!);
              if(student.exists)
              {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                "Sign In Successful",
                style: TextStyle(fontSize: 20.0),
              ),
            ));
            // Navigate to your home screen after successful login.
            // Replace HomeScreen() with your actual home screen widget.
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => HomeScreen()));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                backgroundColor: Colors.orangeAccent,
                content: Text(
                  "This app is for students , please use the website for other stakeholders!!.",
                  style: TextStyle(fontSize: 18.0),
                )));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "You are not authorised to use this app.",
                style: TextStyle(fontSize: 18.0),
              )));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "No user found.",
              style: TextStyle(fontSize: 18.0),
            )));
      }
    } on FirebaseAuthException {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.orangeAccent,
          content: Text(
            "Sign In Failed. Please try again.",
            style: TextStyle(fontSize: 18.0),
          )));
    }
  }

  Future<void> signUpGoogle() async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
      final googleUser = await GoogleSignIn().signIn();
      final googleAuth = await googleUser?.authentication;
      final cred = GoogleAuthProvider.credential(
          idToken: googleAuth?.idToken, accessToken: googleAuth?.accessToken);
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(cred);

      final AdditionalUserInfo? info = userCredential.additionalUserInfo;
      Map<String, dynamic>? userInfo = info?.profile;
      bool newUser = info!.isNewUser;
      if(!newUser){
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "You are already registered.",
              style: TextStyle(fontSize: 18.0),
            )));
      }
      if (userInfo != null) {
        String? checkIIT = userInfo['hd'] ??'';
        if (checkIIT == "iitrpr.ac.in") {
              final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GetStudentDetails()),
              );
              print("Result: $result");
              Map<String, String?> _studentDetails=result as Map<String, String?>;
              print(_studentDetails);
              String name = userInfo['given_name'] + " " + userInfo['family_name'];
              String email = userInfo['email'];
              uid = userCredential.user!.uid;
              Provider.of<UserProvider>(context, listen: false).setUid(uid!);
                      final DatabaseModel dbService = DatabaseModel(uid: uid!);
                      StudentModel student = StudentModel(
                        name: name,
                        email: email,
                        uid: uid!,
                        degree: _studentDetails['degree'] ?? '',
                        entryNumber: _studentDetails['entryNo'] ?? '',
                        year: _studentDetails['year'] ?? '',
                        url: _studentDetails['downloadUrl'] ?? '',
                        bank_account_number: _studentDetails['bankAccount'] ?? '',
                        ifsc_code: _studentDetails['ifsc'] ?? '',
                        mess: _studentDetails['mess']!.toLowerCase(),
                        last_rebate: DateTime.now(),
                      );
                      await dbService.addStudentDetails(student);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                        "Sign up Successful",
                        style: TextStyle(fontSize: 20.0),
                      ),
                    ));
                    // Navigate to your home screen after successful login.
                    // Replace HomeScreen() with your actual home screen widget.
                    Navigator.push(
                        context, MaterialPageRoute(builder: (context) => HomeScreen()));
              }
                 else {
                  print("User is not from IIT Ropar");
                  await userCredential.user!.delete(); 
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "You are not authorised to use this app.",
                style: TextStyle(fontSize: 18.0),
              )));
        }
      } else {
        print("User not found");
        await userCredential.user!.delete(); 
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "No user found.",
              style: TextStyle(fontSize: 18.0),
            )));
      }}
     on FirebaseAuthException {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await currentUser.delete(); 
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.orangeAccent,
          content: Text(
            "Sign Up Failed. Please try again.",
            style: TextStyle(fontSize: 18.0),
          )));
    }
  }

  
  @override
  void dispose() {
    // Clean up controllers when the widget is disposed.
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
           Center(
            child: SizedBox(
              width: 250, // 👈 smaller width — adjust as you like
              child: ElevatedButton.icon(
                onPressed: signInGoogle,
                icon: ClipOval(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Image.asset(
                      'assets/google_logo.png',
                      height: 24,
                      width: 24,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                label: const Text(
                  "Sign in with Google",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Color(0xFFFF7643),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20,),
          Center(
            child: SizedBox(
              width: 250, // 👈 smaller width — adjust as you like
              child: ElevatedButton.icon(
                onPressed: signUpGoogle,
                icon: ClipOval(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Image.asset(
                      'assets/google_logo.png',
                      height: 24,
                      width: 24,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                label: const Text(
                  "Sign up with Google",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Color(0xFFFF7643),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Icons
const mailIcon =
    '''<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-envelope" viewBox="0 0 16 16">
  <path d="M0 4a2 2 0 0 1 2-2h12a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2zm2-1a1 1 0 0 0-1 1v.217l7 4.2 7-4.2V4a1 1 0 0 0-1-1zm13 2.383-4.708 2.825L15 11.105zm-.034 6.876-5.64-3.471L8 9.583l-1.326-.795-5.64 3.47A1 1 0 0 0 2 13h12a1 1 0 0 0 .966-.741M1 11.105l4.708-2.897L1 5.383z"/>
</svg>''';

const lockIcon =
    '''<svg width="15" height="18" viewBox="0 0 15 18" fill="none" xmlns="http://www.w3.org/2000/svg">
<path fill-rule="evenodd" clip-rule="evenodd" d="M9.24419 11.5472C9.24419 12.4845 8.46279 13.2453 7.5 13.2453C6.53721 13.2453 5.75581 12.4845 5.75581 11.5472C5.75581 10.6098 6.53721 9.84906 7.5 9.84906C8.46279 9.84906 9.24419 10.6098 9.24419 11.5472ZM13.9535 14.0943C13.9535 15.6863 12.6235 16.9811 10.9884 16.9811H4.01163C2.37645 16.9811 1.04651 15.6863 1.04651 14.0943V9C1.04651 7.40802 2.37645 6.11321 4.01163 6.11321H10.9884C12.6235 6.11321 13.9535 7.40802 13.9535 9V14.0943ZM4.53488 3.90566C4.53488 2.31368 5.86483 1.01887 7.5 1.01887C8.28488 1.01887 9.03139 1.31943 9.59477 1.86028C10.1564 2.41387 10.4651 3.14066 10.4651 3.90566V5.09434H4.53488V3.90566ZM11.5116 5.12745V3.90566C11.5116 2.87151 11.0956 1.89085 10.3352 1.14028C9.5686 0.405 8.56221 0 7.5 0C5.2875 0 3.48837 1.7516 3.48837 3.90566V5.12745C1.52267 5.37792 0 7.01915 0 9V14.0943C0 16.2484 1.79913 18 4.01163 18H10.9884C13.2 18 15 16.2484 15 14.0943V9C15 7.01915 13.4773 5.37792 11.5116 5.12745Z" fill="#000000"/>
</svg>''';
