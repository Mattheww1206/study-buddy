import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:studybuddy/screens/landing_page.dart';
import 'package:studybuddy/screens/nav_button.dart';
import 'package:studybuddy/screens/opening_page.dart';


class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting){
          return const OpeningPage();
        }
        if(snapshot.hasData){
          return const NavButton();
        }
        return const LandingPage();

      },
    );
  }
}