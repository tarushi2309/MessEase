import 'package:flutter/material.dart';

class CustomNavigationBar extends StatefulWidget {
  @override
  _CustomNavigationBarState createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _navItems = [
    {'icon': Icons.home, 'label': 'Home', 'route': '/home'},
    {'icon': Icons.history, 'label': 'Rebate History', 'route': '/rebate-history'},
    {'icon': Icons.restaurant_menu, 'label': 'Mess Menu', 'route': '/mess-menu'},
    {'icon': Icons.chat, 'label': 'Chat'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      color: Color(0xFFF0753C), // Background color of the nav bar
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          _navItems.length,
          (index) => GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: index == _selectedIndex
                    ? Colors.black87 // Selected item background
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    _navItems[index]['icon'],
                    color: index == _selectedIndex ? Colors.white : Colors.white70,
                    size: 24,
                  ),
                  if (index == _selectedIndex)
                    Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Text(
                        _navItems[index]['label'],
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
