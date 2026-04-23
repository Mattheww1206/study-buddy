import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:studybuddy/features/results/model/study_result.dart';

class StreakService {

  Future<int> updateUserStreak(String userId, List<StudyResult> results) async {
    int streak = 0;

    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (results.isNotEmpty) {
      final dates = results
          .map((r) => DateTime(r.completedAt.year, r.completedAt.month, r.completedAt.day))
          .toSet()
          .toList()
        ..sort((a, b) => b.compareTo(a));

      // If the most recent study date is older than yesterday, streak is 0
      if (dates.first.isBefore(yesterday)) {
        await _updateStreakInFirestore(userId, 0);
        return 0;
      }

      // Accept streak starting from today OR yesterday
      DateTime expectedDate = dates.first == today ? today : yesterday;

      for (final date in dates) {
        if (date.isAtSameMomentAs(expectedDate)) {
          streak++;
          expectedDate = expectedDate.subtract(const Duration(days: 1));
        } else if (date.isBefore(expectedDate)) {
          break;
        }
      }

      // Only cancel reminders if the user actually studied today
      final studiedToday = dates.contains(today);
      if (streak > 0 && studiedToday) {
      }
    }

    await _updateStreakInFirestore(userId, streak);
    return streak;
  }

  Future<void> _updateStreakInFirestore(String userId, int streak) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'streak': streak});
    } catch (e) {
      debugPrint('Failed to update streak in Firestore: $e');
    }
  }
}