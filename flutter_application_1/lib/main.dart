import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/home.dart';

import 'firebase_options.dart';
import 'pages/RebateForm.dart';
import 'pages/messmenu.dart';
import 'pages/rebate_history.dart';
import 'pages/signin.dart';
import 'pages/signup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MessEase',
      theme: ThemeData(
        primarySwatch: MaterialColor(0xFFF0753C, {
          50: Color(0xFFFFEBE0),
          100: Color(0xFFFFCCB3),
          200: Color(0xFFFFAA80),
          300: Color(0xFFFF8850),
          400: Color(0xFFFF6F2B),
          500: Color(0xFFF0753C),
          600: Color(0xFFE06635),
          700: Color(0xFFC0552E),
          800: Color(0xFFA04527),
          900: Color(0xFF80351F),
        }),
        fontFamily: "Roboto",
      ),
      initialRoute: '/signin', // Default screen when app starts
      onGenerateRoute: (settings) {
        final user = FirebaseAuth.instance.currentUser;

        switch (settings.name) {
          case '/home':
            return MaterialPageRoute(builder: (context) => HomeScreen());

          case '/rebate-history':
            if (user != null) {
              return MaterialPageRoute(
                builder: (context) => RebateHistoryScreen(userId: user.uid),
              );
            } else {
              return MaterialPageRoute(builder: (context) => SignInScreen());
            }

          case '/mess-menu':
            return MaterialPageRoute(builder: (context) => MessMenuScreen());

          case '/rebate-form':
            return MaterialPageRoute(builder: (context) => RebateFormPage());

          case '/signin':
            return MaterialPageRoute(builder: (context) => SignInScreen());

          case '/signup':
            return MaterialPageRoute(builder: (context) => SignUpScreen());

          default:
            return MaterialPageRoute(builder: (context) => SignInScreen());
        }
      },
    );
  }
}
