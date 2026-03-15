import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studybuddy/features/results/model/study_result.dart';
import 'package:studybuddy/services/notification_service.dart';

class StreakService {

  Future<int> updateUserStreak(String userId, List<StudyResult> results) async {
  int streak = 0;
  if (results.isNotEmpty) {
    final dates = results
        .map((r) => DateTime(r.completedAt.year, r.completedAt.month, r.completedAt.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final yesterday = today.subtract(const Duration(days: 1));

    // Accept streak starting from today OR yesterday
    DateTime expectedDate = dates.first == today ? today : yesterday;

    // If the most recent study date is older than yesterday, streak is 0
    if (dates.first.isBefore(yesterday)) {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({'streak': 0});
      return 0;
    }

    for (final date in dates) {
      if (date.isAtSameMomentAs(expectedDate)) {
        streak++;
        expectedDate = expectedDate.subtract(const Duration(days: 1));
      } else if (date.isBefore(expectedDate)) {
        break;
      }
    }
  }

  await FirebaseFirestore.instance.collection('users').doc(userId).update({'streak': streak});
  if (streak > 0) {
    await StreakNotificationService.instance.cancelEveningReminder();
  }

  return streak;
}
}