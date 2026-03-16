import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz; 




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
      if(_isInitialized) return; // prevents re-initialization

      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Manila'));

      const initSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

      const initSettings = InitializationSettings(
        android: initSettingsAndroid
      );

      await notifPlugin.initialize(initSettings);

      await notifPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();

      await notifPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.requestExactAlarmsPermission();

       _isInitialized = true;

    } 

    NotificationDetails notificationDetails(String channelId, String channelName) {
      return NotificationDetails(
        android: AndroidNotificationDetails(
          channelId, 
          channelName,
          channelDescription: 'Daily Notification Reminder',
          importance: Importance.max,
          priority: Priority.high
          )
      );
    }

    Future<void> showNotif({
      int id = 0,
      String? title,
      String? body,
    }) async { 
      return notifPlugin.show(id, title, body, notificationDetails('general', 'General'));
      
    }

    Future<void> scheduleNotif({
      int id = 1,
      required String title,
      required String body,
      required int hour,
      required int minute,
      required String channelId,
      required String channelName,
    }) async {

      final now = tz.TZDateTime.now(tz.local);

      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute
      );

      if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

      await notifPlugin.zonedSchedule(
        id, 
        title, 
        body, 
        scheduledDate, 
        notificationDetails(channelId, channelName), 
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        );
        print('Notification scheduled');
    }

    Future<void> scheduleAllReminders() async {
      await scheduleNotif(
        id: morningId,
        title: '🌄 Good Morning', 
        body: 'Start your day right - Do a quiz to activate your STREAK! 🔥', 
        hour: 2, 
        minute: 5,
        channelId: 'morning',
        channelName: 'morning reminder',
        );
      await scheduleNotif(
        id: afternoonId,
        title: '🌞 Good Afternoon', 
        body: 'Don\'t forget to study and take a quiz today to keep your streak going! 🫶', 
        hour: 15, 
        minute: 0,
        channelId: 'afternoon',
        channelName: 'afternoon reminder',
        );
      await scheduleNotif(
        id: eveningId,
        title: '🌙 Evening Reminder!', 
        body: 'Last chance! Take a quiz tonight to maintain your streak 😨', 
        hour: 21, 
        minute: 0,
        channelId: 'evening',
        channelName: 'evening reminder',
        );
      await scheduleNotif(
        id: midnightId,
        title: '💔 STREAK ENDED!', 
        body: 'Oh no! Your streak has ended. Start a new one today! 😉', 
        hour: 0, 
        minute: 0,
        channelId: 'midnight',
        channelName: 'streak ended',
        );
        
    }

    Future<void> cancelUpcomingRemindersForToday() async {
    final hour = tz.TZDateTime.now(tz.local).hour;

    if (hour < 9) await notifPlugin.cancel(morningId);
    if (hour < 15) await notifPlugin.cancel(afternoonId);
    if (hour < 21) await notifPlugin.cancel(eveningId);
    await notifPlugin.cancel(midnightId);

      await scheduleNotif(
      id: morningId,
      title: '🌅 Good Morning!',
      body: 'Start your day right — do a quick quiz to keep your streak alive!',
      hour: 2, minute: 5,
      channelId: 'morning', channelName: 'Morning Reminder',
    );
    await scheduleNotif(
      id: afternoonId,
      title: '☀️ Afternoon Check-in',
      body: 'Don\'t forget to study today and keep your streak going!',
      hour: 15, minute: 0,
      channelId: 'afternoon', channelName: 'Afternoon Reminder',
    );
    await scheduleNotif(
      id: eveningId,
      title: '🌙 Evening Reminder',
      body: 'Last chance! Take a quiz tonight to maintain your streak.',
      hour: 21, minute: 0,
      channelId: 'evening', channelName: 'Evening Reminder',
    );

     if (hour < 21) {
    await scheduleNotif(
      id: midnightId,
      title: '💔 Streak Ended',
      body: 'Oh no! Your streak has ended. Start a new one today!',
      hour: 0, minute: 0,
      channelId: 'midnight', channelName: 'Streak Ended',
    );
  }
  }

  Future<void> cancelEveningReminder() async {
    await notifPlugin.cancel(eveningId);
  }

  Future<void> cancelAllNotifs() async {
    await notifPlugin.cancelAll();
  }


 
}