import 'package:flutter/material.dart';

class CustomNavigationBar extends StatelessWidget {
  final int selectedIndex;

  const CustomNavigationBar({super.key, required this.selectedIndex});

  void _onItemTapped(BuildContext context, int index) {
    if (index == selectedIndex) return; // Prevent reloading the same page

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/rebate-history');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/mess-menu');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/chat');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> navItems = [
      {'icon': Icons.home, 'label': 'Home'},
      {'icon': Icons.history, 'label': 'Rebate History'},
      {'icon': Icons.restaurant_menu, 'label': 'Mess Menu'},
      {'icon': Icons.chat, 'label': 'Chat'},
    ];

    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      color: Color(0xFFF0753C),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          navItems.length,
          (index) => GestureDetector(
            onTap: () => _onItemTapped(context, index),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: index == selectedIndex ? Colors.black87 : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    navItems[index]['icon'],
                    color: index == selectedIndex ? Colors.white : Colors.white70,
                    size: 24,
                  ),
                  if (index == selectedIndex)
                    Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Text(
                        navItems[index]['label'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
