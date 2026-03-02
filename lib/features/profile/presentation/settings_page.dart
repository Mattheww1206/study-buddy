import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studybuddy/features/profile/presentation/settings_page.dart';
import 'package:studybuddy/shared/widgets/custom_button.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0B70),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Settings',
          style: GoogleFonts.yesevaOne( 
            fontSize: 30,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new, 
            size: 30,
            color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 40.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () {
                      print("Navigating to Profile Page...");
                    },
                    child: Row(
                      children: [
                        Container(
                          height: 60,
                          width: 60,
                          decoration: const BoxDecoration(
                            color: Color(0xFF1A0B70),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person, 
                            size: 30,
                            color: Colors.white),
                        ),
                        const SizedBox(width: 15),
                        Text(
                          'Account',
                          style: GoogleFonts.yesevaOne(fontSize: 25),
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_forward_ios, size: 25),
                      ],
                    ),
                  ),

                  const Divider(height: 30),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () {
                      
                    },
                    child: Row(
                      children: [
                        Container(
                          height: 60,
                          width: 60,
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notifications, 
                            size: 30,
                            color: Colors.white),
                        ),
                        const SizedBox(width: 15),
                        Text(
                          'Notifications',
                          style: GoogleFonts.yesevaOne(fontSize: 25), 
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_forward_ios, size: 25),
                      ],
                    ),
                  ),

                  const Divider(height: 30),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () {
                       Navigator.pushNamed(context,'landing');
                    },
                    child: Row(
                      children: [
                        Container(
                          height: 60,
                          width: 60,
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lock, 
                            size: 30,
                            color: Colors.white),
                        ),
                        const SizedBox(width: 25),
                        Text(
                          'Logout',
                          style: GoogleFonts.yesevaOne(fontSize: 25),
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