import 'package:flutter/material.dart';
<<<<<<< HEAD

import 'pages/RebateForm.dart';
import 'pages/home.dart';
import 'pages/messmenu.dart';
import 'pages/rebate_history.dart';
import 'pages/signin.dart';
import 'pages/signup.dart';
import 'pages/user.dart';
=======
import 'pages/signup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
>>>>>>> origin/test

void main() async{
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
      initialRoute: '/home',  // Default screen when app starts
      routes: {
        '/home': (context) => HomeScreen(),
        '/rebate-history': (context) => RebateHistoryScreen(),
        '/mess-menu': (context) => MessMenuScreen(),
        '/rebate-form': (context) => RebateFormPage(),
        '/user': (context) => UserScreen(),
        '/signin': (context) => SignInScreen(),
        '/signup': (context) => SignUpScreen(),
      },
    );
  }
}

