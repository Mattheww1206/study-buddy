import 'package:flutter/material.dart';
import 'package:studybuddy/core/auth_wrapper.dart';
import 'package:studybuddy/features/auth/presentation/landing_page.dart';
import 'package:studybuddy/features/auth/presentation/login_page.dart';
import 'package:studybuddy/features/auth/presentation/nav_button.dart';
import 'package:studybuddy/features/auth/presentation/register_page.dart';
import 'package:studybuddy/features/deck/presentation/create_page.dart';
import 'package:studybuddy/features/profile/presentation/profile_page.dart';
import 'package:studybuddy/features/quiz/presentation/study_page.dart';
import 'package:studybuddy/services/firebase_service.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    await FirebaseService.initializeFirebase();

  
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