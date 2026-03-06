import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/features/auth/model/user_model.dart';
import 'package:studybuddy/features/auth/presentation/landing_page.dart';
import 'package:studybuddy/features/auth/presentation/nav_button.dart';
import 'package:studybuddy/features/auth/provider/user_provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          // wait na maload si user bago mapunta sa navbutton
          return FutureBuilder(
            future: _loadUser(context, snapshot.data!.uid),
            builder: (context, futureSnapshot) {

              // loading users sa firestore
              if (futureSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              return const NavButton();
            },
          );
        }

        return const LandingPage();
      },
    );
  }

  Future<void> _loadUser(BuildContext context, String uid) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (userProvider.user != null) return; // already loaded

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      userProvider.setUser(AppUser(
        userId: uid,
        username: data['username'],
        emailAdd: data['email'],
        provider: data['provider'] ?? 'password',
      ));
    }
  }
}