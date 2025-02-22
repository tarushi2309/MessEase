import 'package:flutter/material.dart';

import '../components/footer.dart'; // Import your footer
import  '../components/header.dart'; // Import your header
import  '../components/navbar.dart'; // Import your navbar

class HomeScreen extends StatelessWidget {
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
        child: Text("Home Page"),
      ),
      bottomNavigationBar: CustomNavigationBar(),
    );
  }
}
