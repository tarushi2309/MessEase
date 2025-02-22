import 'package:flutter/material.dart';

import '../components/footer.dart'; // Import the footer
import '../components/header.dart';
import '../components/navbar.dart'; 

class MessMenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56),
        child: Header(scaffoldKey: scaffoldKey), // Pass scaffoldKey to Header
      ),
      drawer: Navbar(), // Attach the Navbar as a drawer
      body: Center(
        child: Text("Mess Menu Content Here"),
      ),
      bottomNavigationBar: CustomNavigationBar(), // Use the Footer
    );
  }
}