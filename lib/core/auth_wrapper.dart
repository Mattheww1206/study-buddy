import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:studybuddy/features/auth/presentation/landing_page.dart';
import 'package:studybuddy/features/auth/presentation/nav_button.dart';
import 'package:studybuddy/features/auth/presentation/opening_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const OpeningPage();
        }

        final user = snapshot.data;

        // User is logged in AND email is verified
        if (user != null && user.emailVerified) {
          return const NavButton();
        }

        // User is logged in but email is NOT verified
        if (user != null && !user.emailVerified) {
          return const LandingPage(); // Or show a page asking to verify email
        }

        // No user is logged in
        return const LandingPage();
      },
    );
  }
}