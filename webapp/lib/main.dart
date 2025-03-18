import 'package:flutter/material.dart';
import 'package:webapp/pages/admin/refund.dart'; // Ensure this path is correct

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hides the debug banner
      title: 'MessEase',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: RefundPage(), // Load RefundPage instead of HomePage
    );
  }
}
