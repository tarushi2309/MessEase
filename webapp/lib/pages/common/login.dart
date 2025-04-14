
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
//import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:webapp/components/user_provider.dart';
import 'package:webapp/pages/student/get_details.dart';
import 'package:webapp/services/database.dart';
import 'package:webapp/models/student.dart';



class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool rememberMe = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? selectedDegree;
  String? downloadUrl;
  String? uid;

  final GoogleSignIn googleSignIn = GoogleSignIn(
  clientId: "848249088068-ho514oghje4aga9qalj0l1fb65pi4lh9.apps.googleusercontent.com", // Add your Web Client ID here
  
  );

  
   Future<void> signInGoogle() async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
      
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.setCustomParameters({'prompt': 'select_account'});
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithPopup(googleProvider);

      uid = userCredential.user!.uid;
      Provider.of<UserProvider>(context, listen: false).setUid(uid!);

      final AdditionalUserInfo? info = userCredential.additionalUserInfo;
      Map<String, dynamic>? userInfo = info?.profile;
      bool newUser = info!.isNewUser;
      if(newUser)
      {
        await userCredential.user!.delete(); 
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
              final DatabaseModel dbService = DatabaseModel();
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
            Navigator.pushReplacementNamed(context, "/home_student");
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
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.setCustomParameters({'prompt': 'select_account'});
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithPopup(googleProvider);

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
            return;
      }
      if (userInfo != null) {
        String? checkIIT = userInfo['hd'] ??'';
        if (checkIIT == "iitrpr.ac.in") {
              final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GetStudentDetails()),
              );
              print("Result: $result");
              Map<String, String?> studentDetails=result as Map<String, String?>;
              print(studentDetails);
              String name = userInfo['given_name'] + " " + userInfo['family_name'];
              String email = userInfo['email'];
              uid = userCredential.user!.uid;
              Provider.of<UserProvider>(context, listen: false).setUid(uid!);
                      final DatabaseModel dbService = DatabaseModel();
                      StudentModel student = StudentModel(
                        name: name,
                        email: email,
                        uid: uid!,
                        degree: studentDetails['degree'] ?? '',
                        entryNumber: studentDetails['entryNo'] ?? '',
                        year: studentDetails['year'] ?? '',
                        url: studentDetails['downloadUrl'] ?? '',
                        bank_account_number: studentDetails['bankAccount'] ?? '',
                        ifsc_code: studentDetails['ifsc'] ?? '',
                        mess: studentDetails['mess']!.toLowerCase(),
                        last_rebate: DateTime.now(),
                      );
                      await dbService.addStudentDetails(student,uid!);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                        "Sign up Successful",
                        style: TextStyle(fontSize: 20.0),
                      ),
                    ));
                    // Navigate to your home screen after successful login.
                    // Replace HomeScreen() with your actual home screen widget.
                   Navigator.pushReplacementNamed(context, "/home_student");
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

  
  Future<void> signIn(String role) async {
    if (_emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      try {
        // Attempt to sign in using Firebase Authentication.
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
              email: _emailController.text,
              password: _passwordController.text,
            );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFFF0753C),
            content: Text(
              "Sign In Successful",
              style: TextStyle(fontSize: 20.0),
            ),
          ),
        );
        String uid = userCredential.user!.uid;
        print(uid);
        Provider.of<UserProvider>(context, listen: false).setUid(uid);
        // Navigate to your home screen after successful login.
        // Replace HomeScreen() with your actual home screen widget.

        //print(1);
        DatabaseModel db = DatabaseModel();
        DocumentSnapshot doc = await db.getUserInfo(uid);

        print(doc);

        if (doc["role"] == role) {
          print(doc["role"]);
          if (role == "mess_manager") {
            print(1);
            Navigator.pushReplacementNamed(context, "/home_mess_manager");
          } else if (role == "admin") {
            Navigator.pushReplacementNamed(context, "/home_admin");
          } else if (role == "boha") {
            Navigator.pushReplacementNamed(context, "/home_boha");
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                "Invalid role for this account.",
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == "user-not-found") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Color(0xFFF0753C),
              content: Text(
                "No user found with that email.",
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          );
        } else if (e.code == "wrong-password") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Color(0xFFF0753C),
              content: Text(
                "Incorrect password.",
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Color(0xFFF0753C),
              content: Text(
                "Sign In Failed. Please try again.",
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          );
        }
      }
    } else {
      // If any of the fields are empty, inform the user.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFF0753C),
          content: Text(
            "Please fill in both email and password.",
            style: TextStyle(fontSize: 18.0),
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo at the top
            Image.asset(
              "MessEase.png", // Make sure the image is in the assets folder
              width: 200, // Adjust size as needed
              height: 100,
            ),
            const SizedBox(height: 10), // Space between logo and form
            // Boxed login form
            Container(
              width:
                  MediaQuery.of(context).size.width > 500
                      ? 500
                      : MediaQuery.of(context).size.width * 0.9,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 2,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TabBar(
                    controller: _tabController,
                    tabs: const [Tab(text: "MANAGER"), Tab(text: "ADMIN"), Tab(text: "BOHA"), Tab(text: "STUDENT")],
                    indicatorColor: Color(0xFFF0753C),
                    labelColor: Color(0xFFF0753C),
                    unselectedLabelColor: Colors.grey,
                  ),
                  SizedBox(
                    height: 350,
                    child: TabBarView(
                      controller: _tabController,
                      children: [_buildLoginForm("mess_manager"), _buildLoginForm("admin"), _buildLoginForm("boha"), _buildStudentLoginForm()],
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

  Widget _buildStudentLoginForm() {
  return SingleChildScrollView(
    child: Column(
      children: [
        const SizedBox(height: 30),
        const Text(
          "Welcome",
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
        const SizedBox(height: 10),
        const Text(
          "Login with your Google Account",
          style: TextStyle(
            color: Color.fromARGB(255, 133, 131, 131),
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 20),
        
        // Sign Up with Google button
        SizedBox(
          width: MediaQuery.of(context).size.width > 350
              ? 300
              : MediaQuery.of(context).size.width * 0.8,
          child: ElevatedButton.icon(
            onPressed: () => signUpGoogle(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFF0753C),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            icon: Image.asset(
              'assets/google_logo.png', 
              width: 20,
            ),
            label: const Text(
              "Sign Up with Google",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          "OR",
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
        const SizedBox(height: 20),

        // Sign In with Google button
        SizedBox(
          width: MediaQuery.of(context).size.width > 350
              ? 300
              : MediaQuery.of(context).size.width * 0.8,
          child: ElevatedButton.icon(
            onPressed: () => signInGoogle(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFF0753C),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            icon: Image.asset(
              'assets/google_logo.png', 
              width: 20, 
            ),
            label: const Text(
              "Sign In with Google",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildLoginForm(String role) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 30),
          const Text(
            "Welcome Back",
            style: TextStyle(color: Colors.black, fontSize: 20),
          ),
          const SizedBox(height: 10),
          const Text(
            "Login with your email and password",
            style: TextStyle(
              color: Color.fromARGB(255, 133, 131, 131),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 20),

          _inputField(
            controller: _emailController,
            hintText: "Email or username",
          ),
          _inputField(
            controller: _passwordController,
            hintText: "Password",
            isPassword: true,
          ),

          const SizedBox(height: 20),
          SizedBox(
            width:
                MediaQuery.of(context).size.width > 350
                    ? 300
                    : MediaQuery.of(context).size.width * 0.8,
            child: ElevatedButton(
              onPressed:()=> signIn(role),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFF0753C),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text(
                "SIGN IN",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _inputField({
    TextEditingController? controller,
    required String hintText,
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        width: 300, // Reduced width for boxed input fields
        child: TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.black54),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 15,
            ),
          ),
        ),
      ),
    );
  }
}
