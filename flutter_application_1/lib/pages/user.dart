import 'package:flutter/material.dart';

class UserScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Profile"),
        backgroundColor: Color(0xFFF0753C), // Same orange color
      ),
      body: Center(
        child: Text("User Profile Page Content"),
      ),
    );
  }
}
