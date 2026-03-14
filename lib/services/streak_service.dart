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

      DateTime expectedDate = DateTime.now();
      expectedDate = DateTime(expectedDate.year, expectedDate.month, expectedDate.day);

      for (final date in dates) {
        if (date.isAtSameMomentAs(expectedDate)) {
          streak++;
          expectedDate = expectedDate.subtract(const Duration(days: 1));
        } else if (date.isBefore(expectedDate)) {
          break;
        }
      }
    }

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'streak': streak,
    });
    if (streak > 0) {
      await StreakNotificationService.instance.cancelEveningReminder();
    }

    return streak;
  }
}