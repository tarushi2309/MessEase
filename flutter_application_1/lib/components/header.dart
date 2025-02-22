import 'package:flutter/material.dart';

import '../pages/user.dart';

class Header extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const Header({Key? key, required this.scaffoldKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Color(0xFFF0753C), // Orange color
      elevation: 0, // No shadow
      leading: IconButton(
        icon: Icon(Icons.menu, color: Colors.black), // 3-bar menu icon
        onPressed: () {
          scaffoldKey.currentState?.openDrawer(); // Open the navbar
        },
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.person, color: Colors.black), // Profile icon
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserScreen()),
            );
          },
        ),
      ],
    );
  }
}
