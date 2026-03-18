import 'package:flutter/material.dart';
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

  // Color Palette
  final Color primaryBlue = const Color(0xFF1976D2);
  final Color backgroundBlue = const Color(0xFFE3F2FD);
  final Color accentBlue = const Color(0xFF2196F3);

  void _showLogoutDialog(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          child: Container(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.logout_rounded, color: accentBlue, size: 60),
                const SizedBox(height: 20),
                const Text('Oh no! Leaving?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text('Are you sure you want to log out?', textAlign: TextAlign.center),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(side: BorderSide(color: accentBlue)),
                        child: Text('Stay', style: TextStyle(color: accentBlue)),
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
                        style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
                        child: const Text('Logout', style: TextStyle(color: Colors.white)),
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
      backgroundColor: backgroundBlue,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SECTION 1: ACCOUNT & PREFERENCES ---
            const Padding(
              padding: EdgeInsets.only(left: 5, bottom: 10),
              child: Text("Account & Preferences", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _buildSettingsTile(
                    icon: Icons.person_outline,
                    title: "Account",
                    subtitle: "Profile & Security Settings",
                    iconColor: accentBlue,
                    onTap: () => Navigator.pushNamed(context, 'account'),
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    icon: Icons.emoji_events_outlined,
                    title: "Achievement",
                    subtitle: "Your rewards and badges",
                    iconColor: accentBlue,
                    onTap: () => Navigator.pushNamed(context, 'achievement'),
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    icon: Icons.delete_outline,
                    title: "Recently Deleted",
                    subtitle: "Manage your trashed items",
                    iconColor: const Color.fromARGB(255, 216, 116, 115),
                    onTap: () => Navigator.pushNamed(context, 'delete'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25), // Space between sections

            // --- SECTION 2: LOGOUT (HIWALAY NA BOX) ---
            const Padding(
              padding: EdgeInsets.only(left: 5, bottom: 10),
              child: Text("Actions", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: _buildSettingsTile(
                icon: Icons.logout,
                title: "Logout",
                subtitle: "Sign out of your account",
                iconColor: primaryBlue,
                onTap: () => _showLogoutDialog(context),
                showArrow: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
    bool showArrow = true,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
      ),
      trailing: showArrow 
          ? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey) 
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, indent: 70, endIndent: 20, color: Colors.grey[100]);
  }
}