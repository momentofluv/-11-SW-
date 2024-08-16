import 'package:flutter/material.dart';
import 'package:fithubfe/screens/article_screen.dart';
import 'package:fithubfe/screens/calendar_screen.dart';
import 'package:fithubfe/screens/user_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final int userId; // Add this field to accept the user ID

  const HomeScreen({super.key, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      const CalendarScreen(),
      const ArticleScreen(),
      UserProfileScreen(id: widget.userId), // Use the passed userId
    ];

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        unselectedItemColor: Colors.grey,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.comment),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'My Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromRGBO(67, 254, 120, 1),
        onTap: _onItemTapped,
      ),
      body: pages[_selectedIndex],
    );
  }
}
