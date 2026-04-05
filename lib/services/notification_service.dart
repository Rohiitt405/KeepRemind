import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  // Single instance of the notifications plugin
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int _weeklyReminderId = 1;

  Future<void> initialize() async {
    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings: settings);
  }

  // Request notification permission (Android 13+ requires explicit permission)
  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation
        <AndroidFlutterLocalNotificationsPlugin>();

    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }

    // iOS handles permission during initialize()
    return true;
  }

  // Schedule a weekly notification
  // weekday: 1=Monday, 2=Tuesday ... 7=Sunday
  // hour and minute: time of day to send the notification
  Future<void> scheduleWeeklyReminder({
    int weekday = DateTime.monday,
    int hour = 10,
    int minute = 0,
  }) async {
    // Cancel any existing weekly reminder before scheduling a new one
    await cancelWeeklyReminder();

    // Build the notification details for Android
    const androidDetails = AndroidNotificationDetails(
      'weekly_reminder',        // channel ID
      'Weekly Reminder',        // channel name
      channelDescription: 'Weekly reminder to review your saved reels',
      importance: Importance.high,
      priority: Priority.high,
    );

    // Build the notification details for iOS
    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Calculate the next occurrence of the chosen weekday + time
    final scheduledDate = _nextWeekdayTime(weekday, hour, minute);

    // Schedule the notification to repeat weekly
    await _plugin.zonedSchedule(
      id : _weeklyReminderId,
      title:  '🎬 Time to review your saved reels!',
      body:  'You have saved reels waiting. Tap to review your key takeaways.',
      scheduledDate: scheduledDate,
      notificationDetails : details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  // Cancel the weekly reminder
  Future<void> cancelWeeklyReminder() async {
    await _plugin.cancel(id: _weeklyReminderId);
  }

  tz.TZDateTime _nextWeekdayTime(int weekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);

    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    while (scheduled.weekday != weekday || scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  // (called from provider before scheduling)
  String buildNotificationBody(int unreviewedCount) {
    if (unreviewedCount == 0) {
      return 'Open the app to revisit your saved reels.';
    } else if (unreviewedCount == 1) {
      return 'You have 1 unreviewed reel waiting. Tap to review it!';
    } else {
      return 'You have $unreviewedCount unreviewed reels waiting. Tap to review them!';
    }
  }
}