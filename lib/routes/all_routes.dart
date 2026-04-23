import 'package:flutter/material.dart';
import 'package:studybuddy/features/auth/presentation/landing_page.dart';
import 'package:studybuddy/features/auth/presentation/login_page.dart';
import 'package:studybuddy/features/auth/presentation/nav_button.dart';
import 'package:studybuddy/features/auth/presentation/register_page.dart';
import 'package:studybuddy/features/deck/presentation/create_deck_page.dart';
import 'package:studybuddy/features/deck/presentation/create_page.dart';
import 'package:studybuddy/features/deck/presentation/create_upload_page.dart';
import 'package:studybuddy/features/deck/presentation/create_view_page.dart';
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

class AllRoutes {
  static const String landing = 'landing';
  static const String login = 'login';
  static const String register = 'register';
  static const String home = 'home';
  static const String create = 'create';
  static const String study = 'study';
  static const String profile = 'profile';
  static const String settings = 'settings';
  static const String account = 'account';
  static const String achievement = 'achievement';
  static const String delete = 'delete';
  static const String changePassword = 'change_password';
  static const String createDeck = 'create_deck';
  static const String upload = 'upload';
  static const String createView = 'create_view';
  static const String mode = 'mode';
  static const String flashcardMode = 'flashcard_mode';
  static const String missed = 'missed';
  static const String flashcardResultGreat = 'flashcard_result_great';
  static const String flashcardResultAgain = 'flashcard_result_again';
  static const String flashcardMissed = 'flashcard_missed';
  static const String quizMode = 'quiz_mode';
  static const String multipleMode = 'multiple_mode';
  static const String multipleChoice = 'multiple_choice';
  static const String multipleResult = 'multiple_result';
  static const String multipleReview = 'multiple_review';
  static const String idenMode = 'iden_mode';
  static const String idenResult = 'iden_result';
  static const String identification = 'identification';
  static const String idenReview = 'iden_review';
  static const String ranMode = 'ran_mode';
  static const String random = 'random';
  static const String ranResult = 'ran_result';
  static const String ranReview = 'ran_review';
  static const String tfMode = 'tf_mode';
  static const String tf = 'tf';
  static const String tfResult = 'tf_result';
  static const String tfReview = 'tf_review';

  static Map<String, WidgetBuilder> get routes => {
        landing: (context) => const LandingPage(),
        login: (context) => const LoginPage(),
        register: (context) => const RegisterPage(),
        home: (context) => const NavButton(),
        create: (context) => const CreatePage(),
        study: (context) => const StudyPage(),
        profile: (context) => const ProfilePage(),
        settings: (context) => const SettingsPage(),
        account: (context) => const AccountInformationPage(),
        achievement: (context) => const AchievementPage(),
        delete: (context) => const RecentlyDeletedPage(),
        changePassword: (context) => const ChangePasswordPage(),
        createDeck: (context) => const CreateDeckPage(),
        upload: (context) => const CreateUploadPage(),
        createView: (context) => const CreateViewPage(),
        mode: (context) => const ModePage(),
        flashcardMode: (context) => const FlashcardModePage(),
        missed: (context) => const FlashcardMissedPage(),
        flashcardResultGreat: (context) => const FlashcardResultGreatPage(),
        flashcardResultAgain: (context) => const FlashcardResultAgainPage(),
        flashcardMissed: (context) => const FlashcardMissedPage(),
        quizMode: (context) => const QuizModePage(),
        multipleMode: (context) => const MultipleChoiceModePage(),
        multipleChoice: (context) => const MultipleChoicePage(),
        multipleResult: (context) => const MultipleResultPage(),
        multipleReview: (context) => const MultipleReviewAnswerPage(),
        idenMode: (context) => const IdentificationModePage(),
        idenResult: (context) => const IdentificationResultPage(),
        identification: (context) => const IdentificationPage(),
        idenReview: (context) => const IdentificationReviewPage(),
        ranMode: (context) => const RandomModePage(),
        random: (context) => const RandomPage(),
        ranResult: (context) => const RandomResultPage(),
        ranReview: (context) => const RandomReviewPage(),
        tfMode: (context) => const TrueFalseModePage(),
        tf: (context) => const TrueFalsePage(),
        tfResult: (context) => const TrueFalseResultPage(),
        tfReview: (context) => const TrueFalseReviewPage(),
      };
}