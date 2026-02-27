import 'package:flutter/material.dart';
import 'package:studybuddy/screens/create_page.dart';
import 'package:studybuddy/screens/login_page.dart';
import 'package:studybuddy/screens/home_page.dart';
import 'package:studybuddy/screens/profile_page.dart';
import 'package:studybuddy/screens/register_page.dart';
import 'package:studybuddy/screens/study_page.dart';
import 'package:studybuddy/services/firebase_service.dart';
import 'package:studybuddy/screens/opening_page.dart';
import 'package:studybuddy/screens/landing_page.dart';


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
      initialRoute: 'opening',
      routes: {
       'opening': (context) => const OpeningPage(),
       'landing': (context) => const LandingPage(),
       'login': (context) => const LoginPage(),
       'register':(context) => const RegisterPage(),
       'home':(context) => const HomePage(),
       'create':(context) => const CreatePage(),
       'study':(context) => const StudyPage(),
       'profile':(context) => const ProfilePage(),
      },
    );
  }
}