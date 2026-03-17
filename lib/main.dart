import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/core/ConnectivityProvider.dart';
import 'package:studybuddy/core/auth_wrapper.dart';
import 'package:studybuddy/features/auth/presentation/landing_page.dart';
import 'package:studybuddy/features/auth/presentation/login_page.dart';
import 'package:studybuddy/features/auth/presentation/nav_button.dart';
import 'package:studybuddy/features/auth/presentation/register_page.dart';
import 'package:studybuddy/features/auth/provider/user_provider.dart';
import 'package:studybuddy/features/deck/presentation/create_deck_page.dart';
import 'package:studybuddy/features/deck/presentation/create_page.dart';
import 'package:studybuddy/features/deck/presentation/create_upload_page.dart';
import 'package:studybuddy/features/deck/presentation/create_view_page.dart';
import 'package:studybuddy/features/deck/provider/deck_provider.dart';
import 'package:studybuddy/features/profile/presentation/account_information_page.dart';
import 'package:studybuddy/features/profile/presentation/achievement_page.dart';
import 'package:studybuddy/features/profile/presentation/change_password_page.dart';
import 'package:studybuddy/features/profile/presentation/profile_page.dart';
import 'package:studybuddy/features/profile/presentation/recently_deleted_page.dart';
import 'package:studybuddy/features/profile/presentation/settings_page.dart';
import 'package:studybuddy/features/quiz/presentation/True_False_mode_page.dart';
import 'package:studybuddy/features/quiz/presentation/flashcard_missed_page.dart';
import 'package:studybuddy/features/quiz/presentation/flashcard_result_again_page.dart';
import 'package:studybuddy/features/quiz/presentation/flashcard_mode_page.dart';
import 'package:studybuddy/features/quiz/presentation/flashcard_result_great_page.dart';
import 'package:studybuddy/features/quiz/presentation/identification_mode_page.dart';
import 'package:studybuddy/features/quiz/presentation/identification_page.dart';
import 'package:studybuddy/features/quiz/presentation/identification_result_page.dart';
import 'package:studybuddy/features/quiz/presentation/identification_review_page.dart';
import 'package:studybuddy/features/quiz/presentation/mode_page.dart';
import 'package:studybuddy/features/quiz/presentation/multiple_choice_mode_page.dart';
import 'package:studybuddy/features/quiz/presentation/multiple_choice_page.dart';
import 'package:studybuddy/features/quiz/presentation/multiple_result_page.dart';
import 'package:studybuddy/features/quiz/presentation/multiple_review_answer_page.dart';
import 'package:studybuddy/features/quiz/presentation/quiz_mode_page.dart';
import 'package:studybuddy/features/quiz/presentation/random_mode_page.dart';
import 'package:studybuddy/features/quiz/presentation/random_page.dart';
import 'package:studybuddy/features/quiz/presentation/random_result_page.dart';
import 'package:studybuddy/features/quiz/presentation/random_review_page.dart';
import 'package:studybuddy/features/quiz/presentation/study_page.dart';
import 'package:studybuddy/features/quiz/presentation/true_false_page.dart';
import 'package:studybuddy/features/quiz/presentation/true_false_result_page.dart';
import 'package:studybuddy/features/quiz/presentation/true_false_review_page.dart';
import 'package:studybuddy/features/theme/theme_data.dart';
import 'package:studybuddy/services/firebase_service.dart';
import 'package:studybuddy/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => DeckProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
      ],
      child: const MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<void> _initialize() async {  
    try {
    await FirebaseService.initializeFirebase();
    await StreakNotificationService.instance.initNotification();
    final granted = await StreakNotificationService.instance.notifPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.areNotificationsEnabled();
    debugPrint('Notifications enabled: $granted');

    } catch (e, stack) {
      debugPrint('Initialization error: $e');
      debugPrint('Stack trace: $stack');
    rethrow; 
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: defaultColor,
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: _initialize(),
        builder: (context, snapshot) {
          // Still initializing — show splash
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Error during init
          if (snapshot.hasError) {
           return Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }

          // Done — go to normal flow
          return const AuthWrapper();
        },
      ),
      routes: {
        'landing': (context) => const LandingPage(),
        'login': (context) => const LoginPage(),
        'register': (context) => const RegisterPage(),
        'home': (context) => const NavButton(),
        'create': (context) => const CreatePage(),
        'study': (context) => const StudyPage(),
        'profile': (context) => const ProfilePage(),
        'settings': (context) => const SettingsPage(),
        'account': (context) => const AccountInformationPage(),
        'achievement': (context) => const AchievementPage(),
         'delete': (context) => const RecentlyDeletedPage(),
        'change_password': (context) => const ChangePasswordPage(),
        'create_deck': (context) => const CreateDeckPage(),
        'upload': (context) => const CreateUploadPage(),
        'create_view': (context) => const CreateViewPage(),
        'mode': (context) => const ModePage(),
        'flashcard_mode': (context) => const FlashcardModePage(),
        'missed': (context) => const FlashcardMissedPage(),
        'flashcard_result_great': (context) => const FlashcardResultGreatPage(),
        'flashcard_result_again': (context) => const FlashcardResultAgainPage(),
        'flashcard_missed': (context) => const FlashcardMissedPage(),
        'quiz_mode': (context) => const QuizModePage(),
        'multiple_mode': (context) => const MultipleChoiceModePage(),
        'multiple_choice': (context) => const MultipleChoicePage(),
        'multiple_result': (context) => const MultipleResultPage(),
        'multiple_review': (context) => const MultipleReviewAnswerPage(),
        'iden_mode': (context) => const IdentificationModePage(),
        'iden_result': (context) => const IdentificationResultPage(),
        'identification': (context) => const IdentificationPage(),
        'iden_review': (context) => const IdentificationReviewPage(),
        'ran_mode': (context) => const RandomModePage(),
        'random': (context) => const RandomPage(),
        'ran_result': (context) => const RandomResultPage(),
        'ran_review': (context) => const RandomReviewPage(),
        'tf_mode': (context) => const TrueFalseModePage(),
        'tf': (context) => const TrueFalsePage(),
        'tf_result': (context) => const TrueFalseResultPage(),
        'tf_review': (context) => const TrueFalseReviewPage(),
      },
    );
  }
}