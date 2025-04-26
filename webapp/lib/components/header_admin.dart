import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final String currentPage; // Receives the current page name

  const Header({super.key, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
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

                    _navLink("Home", "/home_admin", context),
          //_navLink("Menu Page", "/menu_page", context),
          _navLink("Refund", "/refund", context),
          _navLink("Refund History", "/processed_rebates", context),
          _navLink("Hostel Leaving Data", "/hostel_leaving", context),
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
                      value: "Refund",
                      child: Text(
                        "Refund",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    DropdownMenuItem(
                      value: "Refund History",
                      child: Text(
                        "Refund History",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    DropdownMenuItem(
                      value: "Hostel Leaving Data",
                      child: Text(
                        "Hostel Leaving Data",
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
                        Navigator.pushNamed(context, "/home_admin");
                        break;
                      case "Refund":
                        Navigator.pushNamed(context, "/refund");
                        break;
                      case "Refund History":
                        Navigator.pushNamed(context, "/processed_rebates");
                        break;
                      case "Hostel Leaving Data":
                        Navigator.pushNamed(context, "/hostel_leaving");
                        break;
                      case "Logout":
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          "/login",
                          (Route<dynamic> route) => false,
                        );
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
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500, // Bold for active link
          ),
        ),
      ),
    );
  }
}