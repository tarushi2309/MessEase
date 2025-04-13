import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final String currentPage;

  const Header({super.key, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 600;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          height: 60,
          color: const Color(0xFFF0753C),
          child: Row(
            children: [
              if (isMobile)
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Image.asset(
                  'assets/MessEaseWhite.png',
                  height: 50,
                  width: 140,
                  fit: BoxFit.contain,
                ),
              ),

              const Spacer(),

              if (!isMobile) ...[
                _navLink("Home", "/home_admin", context),
                _navLink("Rebate Form", "/rebateform", context),
                _navLink("MessMenu", "/mess_menu", context),
                _navLink("Logout", "/login", context),
              ] else
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (String route) {
                    Navigator.pushNamed(context, route);
                  },
                  itemBuilder: (BuildContext context) => [
                    _popupItem("Home", "/home_admin"),
                    _popupItem("Rebate Form", "/rebateform"),
                    _popupItem("MessMenu", "/mess_menu"),
                    _popupItem("Logout", "/login"),
                  ],
                ),

              Padding(
                padding: const EdgeInsets.all(10.0),
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, "/profile");
                  },
                  child: const CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Color(0xFFF0753C)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _navLink(String text, String route, BuildContext context) {
    bool isActive = currentPage == text;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, route);
        },
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _popupItem(String label, String route) {
    return PopupMenuItem<String>(
      value: route,
      child: Text(label),
    );
  }
}

class NavDrawer extends StatelessWidget {
  const NavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Text(
              'Navigation Bar',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.description, color: Color(0xFFF0753C)),
            title: const Text('Rebate Form'),
            onTap: () {
              Navigator.pushNamed(context, '/rebateform');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.restaurant_menu, color: Color(0xFFF0753C)),
            title: const Text('Mess Menu'),
            onTap: () {
              Navigator.pushNamed(context, '/mess_menu');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.history, color: Color(0xFFF0753C)),
            title: const Text('Rebate History'),
            onTap: () {
              Navigator.pushNamed(context, '/rebate_history');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat, color: Color(0xFFF0753C)),
            title: const Text('Community Chat'),
            onTap: () {
              Navigator.pushNamed(context, '/community_chat');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Color(0xFFF0753C)),
            title: const Text('Home'),
            onTap: () {
              Navigator.pushNamed(context, '/home_admin');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Color(0xFFF0753C)),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pushNamed(context, '/profile');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
