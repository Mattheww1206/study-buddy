import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'dart:io';

class StreakNotificationService {
  static StreakNotificationService? _instance;
  static StreakNotificationService get instance =>
      _instance ??= StreakNotificationService._();

  StreakNotificationService._();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // ✅ FIXED: Initialize timezone
    tz_data.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(settings);
    await _createChannels();

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();

    _initialized = true;
    print('✅ Initialized');
  }

  Future<void> _createChannels() async {
    const AndroidNotificationChannel morningChannel = AndroidNotificationChannel(
      'morning', 'Morning Reminder', importance: Importance.high,
    );

    const AndroidNotificationChannel eveningChannel = AndroidNotificationChannel(
      'evening', 'Evening Reminder', importance: Importance.high,
    );

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(morningChannel);
    await androidPlugin?.createNotificationChannel(eveningChannel);
  }

  Future<void> scheduleReminders() async {
    if (!_initialized) await initialize();
    
    // ✅ FIXED: Now tz.local works!
    final now = tz.TZDateTime.now(tz.local);
    final morningTomorrow = tz.TZDateTime(tz.local, now.year, now.month, now.day + 1, 9, 0);
    final eveningTomorrow = tz.TZDateTime(tz.local, now.year, now.month, now.day + 1, 21, 0);

    await _notifications.zonedSchedule(
      1,
      '🔥 Keep Streak Alive!',
      'Study today!',
      morningTomorrow,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'morning',
          'Morning Reminder',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    await _notifications.zonedSchedule(
      2,
      '⏰ Streak Ending!',
      'Study now!',
      eveningTomorrow,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'evening',
          'Evening Reminder',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    print('✅ Both scheduled for tomorrow');
  }

  Future<void> cancelEveningReminder() async {
    await _notifications.cancel(2);
    print('❌ Evening cancelled');
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
    print('❌ All cancelled');
  }
}