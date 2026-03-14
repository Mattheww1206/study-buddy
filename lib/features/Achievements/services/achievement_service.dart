import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studybuddy/features/Achievements/model/achievement_model.dart';
import 'package:studybuddy/features/deck/model/deck_model.dart';
import 'package:studybuddy/features/results/model/study_result.dart';

class AchievementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final List<Achievement> allAchievement = [
    Achievement(achieveId: 'welcome', title: 'Welcome!', desc: 'Create your account', icon: 'handshake'),
    Achievement(achieveId: 'card_maker', title: 'Card Maker', desc: 'Create your first flashcard deck', icon: 'note_add'),
    Achievement(achieveId: 'bookworm', title: 'Bookworm', desc: 'Create 5 different decks', icon: 'menu_book'),
    Achievement(achieveId: 'collector', title: 'Collector', desc: 'Have 10 decks saved', icon: 'collections_bookmark'),
    Achievement(achieveId: 'fox_favorite', title: 'Fox Favorite', desc: 'Complete 5 quizzes total', icon: 'favorite'),
    Achievement(achieveId: 'quiz_x10', title: 'Quiz x10', desc: 'Complete 10 quizzes total', icon: 'quiz'),
    Achievement(achieveId: 'quiz_x50', title: 'Quiz x50', desc: 'Complete 50 quizzes total', icon: 'psychology'),
    Achievement(achieveId: 'fox_friend', title: 'Fox Friend', desc: 'Log in 3 days in a row', icon: 'face'),
    Achievement(achieveId: 'two_weeks', title: 'Two Weeks Strong', desc: 'Study 14 days in a row', icon: 'calendar_month'),
    Achievement(achieveId: 'monthly', title: 'Monthly Champion', desc: 'Study 30 days in a row', icon: 'emoji_events'),
    Achievement(achieveId: 'rising_star', title: 'Rising Star', desc: 'Score 70%+ on your first quiz', icon: 'star_border'),
    Achievement(achieveId: 'high_achiever', title: 'High Achiever', desc: 'Score 90%+ three times', icon: 'military_tech'),
    Achievement(achieveId: 'top_class', title: 'Top of the Class', desc: 'Score 100% three times', icon: 'workspace_premium'),
    Achievement(achieveId: 'clean_sweep', title: 'Clean Sweep', desc: 'Answer all questions correctly in one sitting', icon: 'auto_awesome'),
    Achievement(achieveId: 'explorer', title: 'Explorer', desc: 'Try all quiz modes (MC, ID, T/F, Random)', icon: 'explore_outlined'),
    Achievement(achieveId: 'mix_master', title: 'Mix Master', desc: 'Complete a Random Mix quiz', icon: 'shuffle'),
    Achievement(achieveId: 'identifier', title: 'Identifier', desc: 'Complete an Identification quiz', icon: 'search'),
    Achievement(achieveId: 'choice_maker', title: 'Choice Maker', desc: 'Complete a Multiple Choice quiz', icon: 'checklist'),
    Achievement(achieveId: 'true_false_taker', title: 'True or False?', desc: 'Complete a True or False quiz', icon: 'rule'),
    Achievement(achieveId: 'reviewer', title: 'Reviewer', desc: 'Review wrong answers after a quiz', icon: 'rate_review'),
    Achievement(achieveId: 'unstoppable', title: 'Unstoppable', desc: 'Score 100% five times', icon: 'bolt'),
    Achievement(achieveId: 'fox_legend', title: 'Fox Legend', desc: 'Unlock 10 achievements', icon: 'diamond'),
  ];

  Future<List<String>> getUnlockedIds(String userId) async {
    try {
      final snapshot = await _firestore
                       .collection('users')
                       .doc(userId)
                       .collection('achievements')
                       .get();
      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print('AchievementService: getUnlockedIds error: $e');
      return [];
    }
  }

  Future<List<Achievement>> getAchievements(String userId) async {
    final unlockedIds = await getUnlockedIds(userId);
    final unlockedMap = <String, DateTime>{};

    try {
      final snapshot = await _firestore
                       .collection('users')
                       .doc(userId)
                       .collection('achievements')
                       .get();

      for(final doc in snapshot.docs){
        final timeStamp = doc.data()['unlockedAt'];
        if(timeStamp != null) {
          unlockedMap[doc.id] = (timeStamp as Timestamp).toDate();
        }
      }
    } catch (e) {
      print('Achievement Service: getAchivements error: $e');
    }
    return allAchievement.map((a) {
      if(unlockedIds.contains(a.achieveId)) {
        return a.copyWith(isUnlocked: true, unlockedAt: unlockedMap[a.achieveId]);
      }
      return a;
    }).toList();
  }

  Future<void> _unlock(String userId, String achivementId) async {
    try {
      final ref = _firestore
            .collection('users')
            .doc(userId)
            .collection('achievements')
            .doc(achivementId);

      final doc = await ref.get();
      if(!doc.exists) {
        await ref.set({'unlockedAt': FieldValue.serverTimestamp()});
        print('Achievement unlocked: $achivementId');
      }
    } catch (e) {
      print('Achievement Service: unlock error: $e');
    }
  }

  Future<List<String>> evaluateAndUnlock({
    required String userId,
    required List<StudyResult> results,
    required List<Deck> decks,
    required int streak,
    bool reviewedWrongAnswers = false,
  }) async {
    final alreadyUnlocked = await getUnlockedIds(userId);
    final newlyUnlocked = <String>[];
 
    Future<void> tryUnlock(String id, bool condition) async {
      if (condition && !alreadyUnlocked.contains(id)) {
        await _unlock(userId, id);
        newlyUnlocked.add(id);
      }
    }

    final quizResults = results.where((r) => r.mode != 'flashcard').toList();
    final totalQuizzes = quizResults.length;
 
    // Score helpers
    double scorePercent(StudyResult r) => r.totalCards > 0 ? r.correctCount / r.totalCards : 0.0;
 
    final perfectScores = quizResults.where((r) => scorePercent(r) == 1.0).length;
    final ninetyPlusScores = quizResults.where((r) => scorePercent(r) >= 0.9).length;
    final modesUsed = quizResults.map((r) => r.mode).toSet();

    await tryUnlock('welcome', true); // always unlocked
    await tryUnlock('card_maker', decks.isNotEmpty);
    await tryUnlock('bookworm', decks.length >= 5);
    await tryUnlock('collector', decks.length >= 10);
    await tryUnlock('fox_favorite', totalQuizzes >= 5);
    await tryUnlock('quiz_x10', totalQuizzes >= 10);
    await tryUnlock('quiz_x50', totalQuizzes >= 50);
    await tryUnlock('fox_friend', streak >= 3);
    await tryUnlock('two_weeks', streak >= 14);
    await tryUnlock('monthly', streak >= 30);
    await tryUnlock('clean_sweep', perfectScores >= 1);
    await tryUnlock('unstoppable', perfectScores >= 5);
    await tryUnlock('high_achiever', ninetyPlusScores >= 3);
    await tryUnlock('top_class', perfectScores >= 3);
    await tryUnlock('mix_master', modesUsed.contains('random'));
    await tryUnlock('identifier', modesUsed.contains('identification'));
    await tryUnlock('choice_maker', modesUsed.contains('multiple_choice'));
    await tryUnlock('true_false_taker', modesUsed.contains('true_false'));
    await tryUnlock('reviewer', reviewedWrongAnswers);
    await tryUnlock('explorer',modesUsed.contains('multiple_choice') &&
          modesUsed.contains('identification') &&
          modesUsed.contains('true_false') &&
          modesUsed.contains('random'),
    );

    if (quizResults.isNotEmpty) {
      final firstQuiz = quizResults.last; 
      await tryUnlock('rising_star', scorePercent(firstQuiz) >= 0.7);
    }
 
    final totalUnlocked = alreadyUnlocked.length + newlyUnlocked.length;
    await tryUnlock('fox_legend', totalUnlocked >= 10);
 
    return newlyUnlocked;
  }


}