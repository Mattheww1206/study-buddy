import 'package:flutter/material.dart';
import 'package:studybuddy/core/auth_wrapper.dart';
import 'package:studybuddy/screens/create_page.dart';
import 'package:studybuddy/screens/login_page.dart';
import 'package:studybuddy/screens/nav_button.dart';
import 'package:studybuddy/screens/profile_page.dart';
import 'package:studybuddy/screens/register_page.dart';
import 'package:studybuddy/screens/study_page.dart';
import 'package:studybuddy/services/firebase_service.dart';
import 'package:studybuddy/screens/landing_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await FirebaseService.initializeFirebase();
    print("Firebase initialized successfully");
  } catch (e, st) {
    print("Firebase init error: $e\n$st");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
      routes: {
       'landing': (context) => const LandingPage(),
       'login': (context) => const LoginPage(),
       'register':(context) => const RegisterPage(),
       'home':(context) => const NavButton(),
       'create':(context) => const CreatePage(),
       'study':(context) => const StudyPage(),
       'profile':(context) => const ProfilePage(),
      },
    );
  }
}