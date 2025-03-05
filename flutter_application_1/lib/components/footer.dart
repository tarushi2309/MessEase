import 'package:flutter/material.dart';
import '../pages/home.dart';
import '../pages/messmenu.dart';
import '../pages/rebate_history.dart';
import '../pages/chat.dart';


class CustomNavigationBar extends StatefulWidget {
  const CustomNavigationBar({super.key});

  @override
  _CustomNavigationBarState createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _navItems = [
    {'icon': Icons.home, 'label': 'Home', 'route': HomeScreen()},
    {'icon': Icons.history, 'label': 'Rebate History', 'route': RebateHistoryScreen()},
    {'icon': Icons.restaurant_menu, 'label': 'Mess Menu', 'route': MessMenuScreen()},
    {'icon': Icons.chat, 'label': 'Chat', 'route': ChatScreen()},
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to the respective screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => _navItems[index]['route']),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 243, 242, 242), // Background color
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          _navItems.length,
              (index) => GestureDetector(
            onTap: () => _onItemTapped(index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _onItemTapped(index),
                  icon: Icon(
                    _navItems[index]['icon'],
                    color:Colors.grey[700],
                    size: 22,
                  ),
                  constraints: const BoxConstraints(), // Removes extra padding from IconButton
                  padding: EdgeInsets.zero,
                ),
                Text(
                  _navItems[index]['label'],
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
