import 'package:flutter/material.dart';

import '../pages/user.dart';

class Header extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const Header({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80, // Ensuring the Stack has a defined height
      child: Stack(
        children: [
          _buildCustomAppBar(context),
        ],
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Positioned(
      top: 35,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              scaffoldKey.currentState?.openDrawer();
            },
            icon: const Icon(Icons.menu, color: Color(0xFFF0753C), size: 30),
          ),
          Center(
            child: Image.asset(
              'assets/MessEase.png',
              height: 50,
              width: 150,
              fit: BoxFit.contain,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle, color: Color(0xFFF0753C), size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
