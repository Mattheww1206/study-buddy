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
  // FLAG: Para masiguro na isang beses lang natin kukunin ang index galing sa arguments
  bool _isInitialLoad = true; 

  final List<Widget> _pages = const [
    HomeContentPage(),
    CreatePage(),
    StudyPage(),
    ProfilePage(),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Ang logic na ito ay tatakbo lang sa unang beses na ma-load ang widget
    if (_isInitialLoad) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is int) {
        _selectedIndex = args;
      }
      // I-set sa false para hindi na maulit ang pag-override sa _selectedIndex
      _isInitialLoad = false;
    }
  }

  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _navigateBottomBar,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF665FBE), // Violet primary color
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