import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final String currentPage; // Receives the current page name

  const Header({super.key, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      color: const Color(0xFFF0753C), // Theme color
      child: Row(
        children: [
          // Logo Image
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Image.asset(
              'assets/MessEaseWhite.png', // Ensure this image is in your assets folder
              height: 50,
              width: 150,
              fit: BoxFit.contain,
            ),
          ),

          // Push everything else to the right
          const Spacer(),

          // Navigation Links with Highlighting
          _navLink("Home", "/home_mess_manager", context),
          _navLink("Mess Details", "/mess_details_mess_manager", context),
          _navLink("Pending Rebate", "/pending-request", context),
          _navLink("Current Rebate", "/current-request", context),
          _navLink("Feedback", "/feedback_mess", context),
          _navLink("Logout", "/login", context),

          // Profile Icon (Clickable)
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, "/profile"); // Navigate to profile page
              },
              child: const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Color(0xFFF0753C)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navLink(String text, String route, BuildContext context) {
    bool isActive = currentPage == text; // Check if current page matches

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, route);
        },
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white, // Highlight active link
            fontSize: 16,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500, // Bold for active link
          ),
        ),
      ),
    );
  }
}
