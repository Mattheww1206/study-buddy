import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class StreakNotificationService {
  static final StreakNotificationService instance = StreakNotificationService._internal();
  factory StreakNotificationService() => instance;
  StreakNotificationService._internal();

  final notifPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  static const int morningId = 1;
  static const int afternoonId = 2;
  static const int eveningId = 3;
  static const int midnightId = 4;

  Future<void> initNotification() async {
    if (_isInitialized) return;

    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Manila'));

    const initSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: initSettingsAndroid);

    await notifPlugin.initialize(initSettings);

    await notifPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _isInitialized = true;
  }

  NotificationDetails notificationDetails(String channelId, String channelName) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: 'Daily Notification Reminder',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
  }

  Future<void> showNotif({
    int id = 0,
    String? title,
    String? body,
  }) async {
    if (!_isInitialized) await initNotification();
    return notifPlugin.show(id, title, body, notificationDetails('general', 'General'));
  }

  Future<void> scheduleNotif({
  required int id,
  required String title,
  required String body,
  required int hour,
  required int minute,
  required String channelId,
  required String channelName,
}) async {
  if (!_isInitialized) await initNotification();

  final now = tz.TZDateTime.now(tz.local);
  var scheduledDate = tz.TZDateTime(
    tz.local,
    now.year,
    now.month,
    now.day,
    hour,
    minute,
  );

  if (scheduledDate.isBefore(now)) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }

  try {
    await notifPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      notificationDetails(channelId, channelName),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    debugPrint('Notification scheduled: $title at $hour:$minute ✅');
  } catch (e) {
    // Fallback to inexact if exact alarms are not permitted
    debugPrint('Exact alarm failed, trying inexact: $e');
    try {
      await notifPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        notificationDetails(channelId, channelName),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle, // ← fallback
        matchDateTimeComponents: DateTimeComponents.time,
      );
      debugPrint('Notification scheduled (inexact): $title at $hour:$minute ✅');
    } catch (e2) {
      debugPrint('Failed to schedule notification entirely: $e2');
    }
  }
}

  /// Called once at the start of each day (e.g. on app launch or after midnight reset).
  /// Schedules all reminders including the midnight "streak ended" notification.
  /// Only schedules notifications whose time hasn't passed yet today.
  Future<void> scheduleAllReminders() async {
     final now = tz.TZDateTime.now(tz.local);
    final hour = now.hour;
    final minute = now.minute;

    // ⚠️ TEMPORARY TEST — schedule 2 minutes from now
    // Delete this block after testing ↓
    final testMinute = (minute + 2) % 60;
    final testHour = (minute + 2) >= 60 ? hour + 1 : hour;
    await scheduleNotif(
      id: 99,
      title: '🧪 Test Scheduled Notification',
      body: 'Scheduled notifications are working! ✅',
      hour: testHour,
      minute: testMinute,
      channelId: 'test',
      channelName: 'Test',
    );
    return; // ← remove this return after testing
    // ⚠️ END OF TEST BLOCK

    if (hour < 9) {
      await scheduleNotif(
        id: morningId,
        title: '🌄 Good Morning!',
        body: 'Start your day right — do a quiz to activate your STREAK! 🔥',
        hour: 9,
        minute: 0,
        channelId: 'morning',
        channelName: 'Morning Reminder',
      );
    }

    if (hour < 15) {
      await scheduleNotif(
        id: afternoonId,
        title: '🌞 Good Afternoon!',
        body: 'Don\'t forget to study and take a quiz today to keep your streak going! 🫶',
        hour: 15,
        minute: 26,
        channelId: 'afternoon',
        channelName: 'Afternoon Reminder',
      );
    }

    if (hour < 21) {
      await scheduleNotif(
        id: eveningId,
        title: '🌙 Evening Reminder!',
        body: 'Last chance! Take a quiz tonight to maintain your streak 😨',
        hour: 21,
        minute: 0,
        channelId: 'evening',
        channelName: 'Evening Reminder',
      );

      // Only schedule "streak ended" if there's still time to fail today
      await scheduleNotif(
        id: midnightId,
        title: '💔 Streak Ended!',
        body: 'Oh no! Your streak has ended. Start a new one tomorrow! 😉',
        hour: 0,
        minute: 0,
        channelId: 'midnight',
        channelName: 'Streak Ended',
      );
    }
  }

  /// Called when the user successfully completes a quiz.
  /// Cancels all remaining reminders for today — streak is safe! ✅
  Future<void> cancelUpcomingRemindersForToday() async {
    await notifPlugin.cancel(morningId);
    await notifPlugin.cancel(afternoonId);
    await notifPlugin.cancel(eveningId);
    await notifPlugin.cancel(midnightId); // streak is kept, no "ended" notif needed
    debugPrint('All reminders cancelled — streak secured!');
  }

  Future<void> cancelEveningReminder() async {
    await notifPlugin.cancel(eveningId);
  }

  Future<void> cancelAllNotifs() async {
    await notifPlugin.cancelAll();
  } 
}
