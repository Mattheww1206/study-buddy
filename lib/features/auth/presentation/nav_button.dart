import 'package:flutter/material.dart';
import 'package:studybuddy/features/deck/presentation/create_page.dart';
import 'package:studybuddy/features/home/presentation/HomeContent_page.dart';
import 'package:studybuddy/features/profile/presentation/profile_page.dart';
import 'package:studybuddy/features/quiz/presentation/study_page.dart';





class NavButton extends StatefulWidget {
  const NavButton({super.key});

  @override
  State<NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<NavButton> {
    int _selectedIndex = 0;

    final List<Widget> _pages = const [
    HomeContentPage(),
    CreatePage(),
    StudyPage(),
    ProfilePage(),
  ];

    void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _navigateBottomBar,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF16056B),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Create'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Study'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}