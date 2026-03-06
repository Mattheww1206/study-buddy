import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/core/auth_wrapper.dart';
import 'package:studybuddy/features/auth/presentation/landing_page.dart';
import 'package:studybuddy/features/auth/presentation/login_page.dart';
import 'package:studybuddy/features/auth/presentation/nav_button.dart';
import 'package:studybuddy/features/auth/presentation/register_page.dart';
import 'package:studybuddy/features/auth/provider/user_provider.dart';
import 'package:studybuddy/features/deck/presentation/create_deck_page.dart';
import 'package:studybuddy/features/deck/presentation/create_page.dart';
import 'package:studybuddy/features/profile/presentation/account_information_page.dart';
import 'package:studybuddy/features/profile/presentation/achievement_page.dart';
import 'package:studybuddy/features/profile/presentation/change_password_page.dart';
import 'package:studybuddy/features/profile/presentation/profile_page.dart';
import 'package:studybuddy/features/profile/presentation/settings_page.dart';
import 'package:studybuddy/features/quiz/presentation/study_page.dart';
import 'package:studybuddy/features/theme/theme_data.dart';
import 'package:studybuddy/services/firebase_service.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    await FirebaseService.initializeFirebase();
  runApp(
    ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: defaultColor,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
       'landing': (context) => const LandingPage(),
       'login': (context) => const LoginPage(),
       'register':(context) => const RegisterPage(),
       'home':(context) => const NavButton(),
       'create':(context) => const CreatePage(),
       'study':(context) => const StudyPage(),
       'profile':(context) => const ProfilePage(),
       'settings':(context) => const SettingsPage(),
       'account':(context) => const AccountInformationPage(),
       'achievement': (context) => const AchievementPage(),
       'change_password':(context) => const ChangePasswordPage(),
       'create_deck':(context) => const CreateDeckPage(),
      },
    );
  }
}