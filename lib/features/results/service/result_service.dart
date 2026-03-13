import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studybuddy/features/results/model/study_result.dart';

class ResultService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> saveResult(StudyResult result) async {
    final resultDoc = _firestore.collection('results').doc();
       resultDoc.set(StudyResult(
      resultId: resultDoc.id,
      userId: result.userId,
      deckId: result.deckId,
      deckTitle: result.deckTitle,
      mode: result.mode,
      totalCards: result.totalCards,
      correctCount: result.correctCount,
      easyCount: result.easyCount,
      againCount: result.againCount,
      completedAt: result.completedAt,
    ).toMap()).catchError((e) => print('ResultService save error: $e'));
    return resultDoc.id;
  }

  Future<List<StudyResult>> getUserResults(String userId) async {
    try {
    final snapshot = await _firestore
        .collection('results')
        .where('userId', isEqualTo: userId)
        .orderBy('completedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => StudyResult.fromMap(doc.id, doc.data()))
        .toList();

    } catch (e) {
      try {
      final snapshot = await _firestore
          .collection('results')
          .where('userId', isEqualTo: userId)
          .orderBy('completedAt', descending: true)
          .get(const GetOptions(source: Source.cache));

      return snapshot.docs
          .map((doc) => StudyResult.fromMap(doc.id, doc.data()))
          .toList();
    } catch (cacheError) {
      print('ResultService cache error: $cacheError');
      return []; // return empty list if both fail
    }
  }
}

  int calculateStreak(List<StudyResult> results) {
    if (results.isEmpty) return 0;

    final dates = results
        .map((r) => DateTime(
            r.completedAt.year, r.completedAt.month, r.completedAt.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

      print('Unique study dates: $dates');

    int streak = 0;
    DateTime expected = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);

    for (final date in dates) {
      print('Checking date: $date vs expected: $expected');
      if (date == expected) {
        streak++;
        expected = expected.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  int todayQuizCount(List<StudyResult> results) {
    final today = DateTime.now();
    return results
        .where((r) =>
            r.completedAt.year == today.year &&
            r.completedAt.month == today.month &&
            r.completedAt.day == today.day)
            .length;
  }

  int weekQuizCount(List<StudyResult> results) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(
        startOfWeek.year, startOfWeek.month, startOfWeek.day);
    return results.where((r) => r.completedAt.isAfter(start)).length;
  }


}


