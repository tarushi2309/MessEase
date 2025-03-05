import 'package:flutter/material.dart';
import '../pages/user.dart';
import '../pages/signup.dart';
import '../pages/messmenu.dart';

import '../pages/rebate_history.dart';
import '../pages/home.dart';
import '../pages/RebateForm.dart';

class Navbar extends StatelessWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      child: Drawer(
        child: Column(
          children: [
            SizedBox(height: statusBarHeight),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 5, 5),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Navigation Bar',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
                ),
              ),
            ),
            const Divider(thickness: 2),
            Expanded(
              child: ListView(
                children: [
                  _buildDrawerItem(Icons.receipt_long, 'Rebate Form', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RebateFormPage()),
                    );
                  }),
                  _buildDrawerItem(Icons.restaurant_menu, 'Mess Menu', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MessMenuScreen()),
                    );
                  }),
                  _buildDrawerItem(Icons.history, 'Rebate History', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RebateHistoryScreen()),
                    );
                  }),
                  _buildDrawerItem(Icons.chat, 'Community Chat', () {}),
                  _buildDrawerItem(Icons.home, 'Home', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  }),
                  _buildDrawerItem(Icons.person, 'Profile', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserPage()),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFF0753C)),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }
}
