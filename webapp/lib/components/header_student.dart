import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final String currentPage; // Receives the current page name

  const Header({super.key, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1000) {
          // Desktop or larger screens
          return _buildDesktopHeader(context);
        } else {
          // Mobile or smaller screens
          return _buildMobileHeader(context);
        }
      },
    );
  }

  Widget _buildDesktopHeader(BuildContext context) {
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
          _navLink("Home", "/home_student", context),
          _navLink("Rebate Form", "/rebate_form", context),
          _navLink("Rebate History", "/rebate_history_student", context),
          _navLink("Mess Menu", "/mess_menu_student", context),
          _navLink("Logout", "/login", context),

          // Profile Icon (Clickable)
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, "/profile_student"); // Navigate to profile page
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

  Widget _buildMobileHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: const Color(0xFFF0753C), // Theme color
      child: Column(
        children: [
          Row(
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

              // Dropdown Menu
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  dropdownColor: const Color(0xFFF0753C),
                  items: [
                    DropdownMenuItem(
                      value: "Home",
                      child: Text(
                        "Home",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    DropdownMenuItem(
                      value: "Rebate Form",
                      child: Text(
                        "Rebate Form",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    DropdownMenuItem(
                      value: "Rebate History",
                      child: Text(
                        "Rebate History",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    DropdownMenuItem(
                      value: "Mess Menu",
                      child: Text(
                        "Mess Menu",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    DropdownMenuItem(
                      value: "Profile",
                      child: Text(
                        "Profile",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    DropdownMenuItem(
                      value: "Logout",
                      child: Text(
                        "Logout",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    switch (value) {
                      case "Home":
                        Navigator.pushNamed(context, "/home_mess_manager");
                        break;
                      case "Rebate Form":
                        Navigator.pushNamed(context, "/rebate_form");
                        break;
                      case "Rebate History":
                        Navigator.pushNamed(context, "/rebate_history_student");
                        break;
                      case "Mess Menu":
                        Navigator.pushNamed(context, "/mess_menu_student");
                        break;
                      case "Profile":
                        Navigator.pushNamed(context, "/profile_student");
                        break;
                      case "Logout":
                        Navigator.pushNamed(context, "/login");
                        break;
                    }
                  },
                ),
              ),
            ],
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
            fontWeight: isActive
                ? FontWeight.bold
                : FontWeight.w500, // Bold for active link
          ),
        ),
      ),
    );
  }
}
