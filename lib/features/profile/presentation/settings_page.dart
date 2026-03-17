import 'package:flutter/material.dart';
// Tinanggal ang google_fonts import
import 'package:provider/provider.dart';
import 'package:studybuddy/features/auth/provider/user_provider.dart';
import 'package:studybuddy/features/auth/service/auth_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AuthService _authService = AuthService();

  void _showLogoutDialog(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          elevation: 10,
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFF665FBE), // Dominant Color
                  size: 60,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Oh no! Leaving?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Are you sure you want to log out of your StudyBuddy account?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          side: const BorderSide(color: Color(0xFF665FBE)), // Dominant Color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Stay',
                          style: TextStyle(
                            color: Color(0xFF665FBE), // Dominant Color
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final nav = Navigator.of(context);
                          userProvider.clearUser();
                          await _authService.signOut();
                          nav.pushNamedAndRemoveUntil('/', (route) => false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF665FBE), // Dominant Color
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAEEFF), // Dominant Color
      appBar: AppBar(
        backgroundColor: const Color(0xFF665FBE),
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25, 
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 25, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0), 
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(30), 
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255), // Secondary Color
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, 'account');
                    },
                    child: Row(
                      children: [
                        Container(
                          height: 50, 
                          width: 50,  
                          decoration: const BoxDecoration(
                            color: Color(0xFF665FBE), // Dominant Color
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person,
                              size: 25, color: Colors.white), 
                        ),
                        const SizedBox(width: 15),
                        const Text(
                          'Account',
                          style: TextStyle(
                            fontSize: 20, 
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_forward_ios, size: 20), 
                      ],
                    ),
                  ),
                  const Divider(height: 25), 
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, 'achievement');
                    },
                    child: Row(
                      children: [
                        Container(
                          height: 50, 
                          width: 50,  
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF810E), // Accent Color
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.notifications,
                              size: 25, color: Colors.white), 
                        ),
                        const SizedBox(width: 15),
                        const Text(
                          'Achievement',
                          style: TextStyle(
                            fontSize: 20, 
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_forward_ios, size: 20), 
                      ],
                    ),
                  ),
                  const Divider(height: 25), 
                  // ITO YUNG DAGDAG: Recently Deleted Section
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, 'delete');
                    },
                    child: Row(
                      children: [
                        Container(
                          height: 50,
                          width: 50,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE53935), // Red color for delete
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.delete_sweep,
                              size: 25, color: Colors.white),
                        ),
                        const SizedBox(width: 15),
                        const Text(
                          'Recently Deleted',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_forward_ios, size: 20),
                      ],
                    ),
                  ),
                  const Divider(height: 25), 
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () async {
                      _showLogoutDialog(context);
                    },
                    child: Row(
                      children: [
                        Container(
                          height: 50, 
                          width: 50,  
                          decoration: const BoxDecoration(
                            color: Color(0xFF665FBE), // Dominant Color
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.lock,
                              size: 25, color: Colors.white), 
                        ),
                        const SizedBox(width: 20), 
                        const Text(
                          'Logout',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold), 
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}