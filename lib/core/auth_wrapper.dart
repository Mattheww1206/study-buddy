import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/features/auth/model/user_model.dart';
import 'package:studybuddy/features/auth/presentation/landing_page.dart';
import 'package:studybuddy/features/auth/presentation/nav_button.dart';
import 'package:studybuddy/features/auth/presentation/opening_page.dart';
import 'package:studybuddy/features/auth/provider/user_provider.dart';
import 'package:studybuddy/features/deck/provider/deck_provider.dart';
import 'package:studybuddy/features/results/provider/result_provider.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _showSplash = true;

  @override
void initState() {
  super.initState();
  Future.delayed(const Duration(seconds: 3), () {
    if (mounted) {
      setState(() => _showSplash = false); 
    }
  });
}



  @override
  Widget build(BuildContext context) {
    if (_showSplash) return const OpeningPage();

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return FutureBuilder(
            future: _loadUser(context, snapshot.data!.uid),
            builder: (context, futureSnapshot) {
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
  final deckProvider = Provider.of<DeckProvider>(context, listen: false);
  final resultProvider = Provider.of<ResultProvider>(context, listen: false);

  // ✅ Always start listeners — even if user already set
   Future.microtask(() {
    deckProvider.listenToDecks(uid);
    resultProvider.loadResults(uid);
  });
  if (userProvider.user != null) return; // user data already loaded

  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .get();

  if (doc.exists) {
    final data = doc.data() as Map<String, dynamic>;
    userProvider.setUser(AppUser(
      userId: uid,
      username: data['username'],
      email: data['email'],
      provider: data['provider'] ?? 'password',
      photoUrl: data['photoUrl'],
    ));
  }
}
  
}