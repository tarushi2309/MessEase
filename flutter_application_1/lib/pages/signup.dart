import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/student.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/services/database.dart';
import 'package:flutter_svg/flutter_svg.dart';
import './signin.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Ensure the scaffold resizes when the keyboard appears
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        // Using ListView for scrolling content
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            Center(
              child: Image.asset(
                'assets/MessEase.png',
                height: 100,
                width: 200,
                fit: BoxFit.contain,
              ),
            ),
            const Text(
              "Register Account",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Complete your details",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF757575),
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 24),
            const SignUpForm(),
            const SizedBox(height: 16),
            const AccountExists(),
          ],
        ),
      ),
    );
  }
}

const authOutlineInputBorder = OutlineInputBorder(
  borderSide: BorderSide(color: Color(0xFF757575)),
  borderRadius: BorderRadius.all(Radius.circular(100)),
);

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  String email = "", password = "", name = "",degree="",entry_no="",year="";
  TextEditingController namecontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController mailcontroller = TextEditingController();
  TextEditingController entry_nocontroller = TextEditingController();
  TextEditingController yearcontroller = TextEditingController();
  String? selectedDegree;

  final _formkey = GlobalKey<FormState>();

  Future<dynamic> registration() async {
    if (namecontroller.text!=""&& mailcontroller.text!=""&& passwordcontroller.text!=""&& selectedDegree!=""&& yearcontroller.text!=""&& entry_nocontroller.text!="") {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        final DatabaseModel dbService = DatabaseModel(uid: userCredential.user!.uid);
        UserModel user=UserModel(uid: userCredential.user!.uid,
          name: namecontroller.text,
          email: mailcontroller.text,
          role_:"student",);
        StudentModel student=StudentModel(uid: userCredential.user!.uid,
          degree: selectedDegree ?? '',
          entryNumber: entry_nocontroller.text,
          year: int.tryParse(yearcontroller.text) ?? 0,
          password: password,);

        await dbService.addUserDetails(user);
        await dbService.addStudentDetails(student);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
          "Registered Successfully",
          style: TextStyle(fontSize: 20.0),
        )));
        // ignore: use_build_context_synchronously
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SignInForm()));
      } on FirebaseAuthException catch (e) {
         if (e.code == "email-already-in-use") {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "Account Already exists",
                style: TextStyle(fontSize: 18.0),
              )));
        }
      }
    }
  }

  
  final List<String> degreeOptions = ['Btech', 'Mtech', 'Phd', 'Others'];

  @override
  Widget build(BuildContext context) {
     return Form(
      key: _formkey,
      child: Column(
        children: <Widget>[
          // Name Field
          TextFormField(
            validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter Name';
                          }
                          return null;
                        },
            controller: namecontroller,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: "Enter your Name",
              labelText: "Name",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              hintStyle: const TextStyle(color: Color(0xFF757575)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              suffix: SvgPicture.string(nameIcon),
              border: authOutlineInputBorder,
              enabledBorder: authOutlineInputBorder,
              focusedBorder: authOutlineInputBorder.copyWith(
                borderSide: const BorderSide(color: Color(0xFFFF7643)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Email Field
          TextFormField(
            validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter Email';
                          }
                          return null;
                        },
            controller: mailcontroller,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: "Enter your email",
              labelText: "Email",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              hintStyle: const TextStyle(color: Color(0xFF757575)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              suffix: SvgPicture.string(mailIcon),
              border: authOutlineInputBorder,
              enabledBorder: authOutlineInputBorder,
              focusedBorder: authOutlineInputBorder.copyWith(
                borderSide: const BorderSide(color: Color(0xFFFF7643)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Password Field
          TextFormField(
            validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter Password';
                          }
                          return null;
                        },
                        controller: passwordcontroller,
            obscureText: true,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: "Enter your password",
              labelText: "Password",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              hintStyle: const TextStyle(color: Color(0xFF757575)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              suffix: SvgPicture.string(lockIcon),
              border: authOutlineInputBorder,
              enabledBorder: authOutlineInputBorder,
              focusedBorder: authOutlineInputBorder.copyWith(
                borderSide: const BorderSide(color: Color(0xFFFF7643)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Confirm Password Field
          TextFormField(
            onSaved: (password) {},
            onChanged: (password) {},
            obscureText: true,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: "Re-enter your password",
              labelText: "Confirm Password",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              hintStyle: const TextStyle(color: Color(0xFF757575)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              suffix: SvgPicture.string(lockIcon),
              border: authOutlineInputBorder,
              enabledBorder: authOutlineInputBorder,
              focusedBorder: authOutlineInputBorder.copyWith(
                borderSide: const BorderSide(color: Color(0xFFFF7643)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Degree Type Drop-Down Field
          DropdownButtonFormField<String>(
             validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Select Degree Type';
                          }
                          return null;
                        },
            decoration: InputDecoration(
              labelText: 'Degree Type',
              floatingLabelBehavior: FloatingLabelBehavior.always,
              hintText: 'Select Degree Type',
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              border: authOutlineInputBorder,
              enabledBorder: authOutlineInputBorder,
              focusedBorder: authOutlineInputBorder.copyWith(
                borderSide: const BorderSide(color: Color(0xFFFF7643)),
              ),
            ),
            items: degreeOptions.map((degree) {
              return DropdownMenuItem(
                value: degree,
                child: Text(degree),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedDegree = value;
              });
            },
            value: selectedDegree,
          ),
          const SizedBox(height: 16),
          // Year Field
          TextFormField(
            validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter Year';
                          }
                          return null;
                        },
                        controller: yearcontroller,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: "Enter your Year",
              labelText: "Year",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              hintStyle: const TextStyle(color: Color(0xFF757575)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              suffix: SvgPicture.string(yearIcon),
              border: authOutlineInputBorder,
              enabledBorder: authOutlineInputBorder,
              focusedBorder: authOutlineInputBorder.copyWith(
                borderSide: const BorderSide(color: Color(0xFFFF7643)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Entry Number Field
          TextFormField(
            validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter Entry Number';
                          }
                          return null;
                        },
                        controller: entry_nocontroller,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: "Enter your Entry Number",
              labelText: "Entry Number",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              hintStyle: const TextStyle(color: Color(0xFF757575)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              suffix: SvgPicture.string(idIcon),
              border: authOutlineInputBorder,
              enabledBorder: authOutlineInputBorder,
              focusedBorder: authOutlineInputBorder.copyWith(
                borderSide: const BorderSide(color: Color(0xFFFF7643)),
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
                  onPressed: () {
                    final formState = _formkey.currentState;
                    if (formState != null && formState.validate()) {
                      setState(() {
                        email = mailcontroller.text;
                        name = namecontroller.text;
                        password = passwordcontroller.text;
                      });
                      registration();
                    } else {
                      // Optionally handle the case when formState is null.
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Form is not ready")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF7643),
                    padding: const EdgeInsets.symmetric(vertical: 13.0, horizontal: 30.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: Size(MediaQuery.of(context).size.width, 48),
                  ),
                  child: const Center(
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
        Text( '' )  
        ],
      
      ),
      
      );
    
  }
}

class AccountExists extends StatelessWidget {
  const AccountExists({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: const Text(
            "Already have an Account? ",
            style: TextStyle(color: Color(0xFF757575)),
          ),
        ),
        GestureDetector(
          onTap: () {
            // Handle navigation to Sign Up
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignInScreen()),
            );
          },
          child: const Text(
            "Sign In",
            style: TextStyle(
              color: Color(0xFFFF7643),
            ),
          ),
        ),
      ],
    ),);
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

const yearIcon =
    '''<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="#000000" class="bi bi-calendar" viewBox="0 0 16 16">
  <path d="M3.5 0a.5.5 0 0 1 .5.5V1h8V.5a.5.5 0 0 1 1 0V1h1a2 2 0 0 1 2 2v11a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2V3a2 2 0 0 1 2-2h1V.5a.5.5 0 0 1 .5-.5M1 4v10a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1V4z"/>
</svg>''';

const nameIcon =
    '''<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-person" viewBox="0 0 16 16">
  <path d="M8 8a3 3 0 1 0 0-6 3 3 0 0 0 0 6m2-3a2 2 0 1 1-4 0 2 2 0 0 1 4 0m4 8c0 1-1 1-1 1H3s-1 0-1-1 1-4 6-4 6 3 6 4m-1-.004c-.001-.246-.154-.986-.832-1.664C11.516 10.68 10.289 10 8 10s-3.516.68-4.168 1.332c-.678.678-.83 1.418-.832 1.664z"/>
</svg>''';

const idIcon =
    '''<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-person-vcard" viewBox="0 0 16 16">
  <path d="M5 8a2 2 0 1 0 0-4 2 2 0 0 0 0 4m4-2.5a.5.5 0 0 1 .5-.5h4a.5.5 0 0 1 0 1h-4a.5.5 0 0 1-.5-.5M9 8a.5.5 0 0 1 .5-.5h4a.5.5 0 0 1 0 1h-4A.5.5 0 0 1 9 8m1 2.5a.5.5 0 0 1 .5-.5h3a.5.5 0 0 1 0 1h-3a.5.5 0 0 1-.5-.5"/>
  <path d="M2 2a2 2 0 0 0-2 2v8a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V4a2 2 0 0 0-2-2zM1 4a1 1 0 0 1 1-1h12a1 1 0 0 1 1 1v8a1 1 0 0 1-1 1H8.96q.04-.245.04-.5C9 10.567 7.21 9 5 9c-2.086 0-3.8 1.398-3.984 3.181A1 1 0 0 1 1 12z"/>
</svg>''';