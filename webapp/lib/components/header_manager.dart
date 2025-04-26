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
          _navLink("Home", "/home_mess_manager", context),
          _navLink("Mess Details", "/mess_details_mess_manager", context),
          _navLink("Pending Rebates", "/pending-request", context),
          _navLink("Current Rebates", "/current-request", context),
          _navLink("Feedback", "/feedback_mess", context),
          _navLink("Logout", "/login", context),

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
                      value: "Mess Details",
                      child: Text(
                        "Mess Details",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    DropdownMenuItem(
                      value: "Pending Rebates",
                      child: Text(
                        "Pending Rebates",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    DropdownMenuItem(
                      value: "Current Rebates",
                      child: Text(
                        "Current Rebates",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    DropdownMenuItem(
                      value: "Feedback",
                      child: Text(
                        "Feedback",
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
                      case "Mess Details":
                        Navigator.pushNamed(context, "/mess_details_mess_manager");
                        break;
                      case "Feedback":
                        Navigator.pushNamed(context, "/feedback_mess");
                        break;
                      case "Pending Rebates":
                        Navigator.pushNamed(context, "/pending-request");
                        break;
                      case "Current Rebates":
                        Navigator.pushNamed(context, "/current-request");
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
