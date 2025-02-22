import 'package:flutter/material.dart';
import 'pages/signup.dart';
import 'pages/signin.dart';
import 'pages/RebateForm.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
      home: const SignInScreen(),
      //home: RebateFormPage(),
    );
  }
}

