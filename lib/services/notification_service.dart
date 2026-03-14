import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';

class StreakNotificationService {
  static final StreakNotificationService instance = StreakNotificationService._internal();
  factory StreakNotificationService() => instance;
  StreakNotificationService._internal();
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized; 

  static const int _morningNotifId = 001; 
  static const int _eveningNotifId = 002; 

  Future<void> initNotification() async {
    if (_isInitialized) return;

    tz_data.initializeTimeZones(); 
    var ph = tz.getLocation('Asia/Manila');
    tz.setLocalLocation(ph);

    const initSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher'); 
                                                              
    const initSettings = InitializationSettings(
      android: initSettingsAndroid,
    );

    await _plugin.initialize(settings: initSettings); 

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();

    _isInitialized = true; 
  }

  NotificationDetails _notifDetails({
    required String channelId,
    required String channelName,
  }) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher', 
      ),
    );
  }

  Future<void> requestPermission() async {
    await _plugin
        .resolvePlatformSpecificImplementation<  
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> _scheduleMorningReminder() async {
    final now = tz.TZDateTime.now(tz.local);

    var scheduledTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      9,
    );

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id: _morningNotifId,
      title: '🔥 Keep your streak alive!',
      body: 'Complete a study session today to maintain your streak.',
      scheduledDate:  scheduledTime,
      notificationDetails:  _notifDetails(channelId: 'streak_morning', channelName: 'Morning Reminder'),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _scheduleEveningReminder() async {
    final now = tz.TZDateTime.now(tz.local);

    var scheduledTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      22,
    );

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id: _eveningNotifId,
      title: '⏰ Your streak ends in 2 hours!',
      body: 'You haven\'t studied today yet. Don\'t lose your streak!',
      scheduledDate: scheduledTime,
      notificationDetails:  _notifDetails(channelId: 'streak_evening', channelName: 'Evening Reminder'),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleStreakReminders() async {
    await _scheduleMorningReminder();
    await _scheduleEveningReminder();
  }

  Future<void> cancelEveningReminder() async {
    await _plugin.cancel(id: _eveningNotifId);
    await _scheduleEveningReminder();
  }

  Future<void> cancelAll() async { 
    await _plugin.cancelAll(); 
  }


}