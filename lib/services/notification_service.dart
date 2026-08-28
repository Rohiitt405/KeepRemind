import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/saved_link_model.dart';

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static const int _weeklyReminderId = 1;
  static const int _dailyReminderId = 2;

  Future<void> initialize() async {
    tz_data.initializeTimeZones();

    final timezoneInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

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

  Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }

    return true;
  }

  Future<void> scheduleWeeklyReminder({
    int weekday = DateTime.monday,
    int hour = 10,
    int minute = 0,
    SavedLink? savedLink,
  }) async {
    await cancelAll();

    if (savedLink == null) {
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'weekly_reminder',
      'Weekly Reminder',
      channelDescription: 'Weekly reminder to revisit your saved content',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    final scheduledDate = _nextWeekdayTime(weekday, hour, minute);

    await _plugin.zonedSchedule(
      id: _weeklyReminderId,
      title: buildNotificationTitle(savedLink),
      body: buildNotificationBody(savedLink),
      scheduledDate: scheduledDate,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  Future<void> scheduleDailyReminder({
    int hour = 10, 
    int minute = 0,
    SavedLink? savedLink,
    }) async {
    await cancelAll();

    if(savedLink == null) {
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'daily_reminder',
      'Daily Reminder',
      channelDescription: 'Daily reminder to revisit your saved content',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    final scheduledDate = _nextDailyTime(hour, minute);

    await _plugin.zonedSchedule(
      id: _dailyReminderId,
      title: buildNotificationTitle(savedLink),
      body: buildNotificationBody(savedLink),
      scheduledDate: scheduledDate,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelWeeklyReminder() async {
    await _plugin.cancel(id: _weeklyReminderId);
  }

  Future<void> cancelDailyReminder() async {
    await _plugin.cancel(id: _dailyReminderId);
  }

  Future<void> cancelAll() async {
    await _plugin.cancel(id: _weeklyReminderId);
    await _plugin.cancel(id: _dailyReminderId);
  }

  String buildNotificationTitle(SavedLink savedLink) {
    return savedLink.title.isNotEmpty
      ? savedLink.title
      : 'Your saved memory';
  }

  String buildNotificationBody(SavedLink savedLink) {
    final memory = savedLink.aiMemory?.trim();

    if(memory == null || memory.isEmpty) {
      return 'Take a moment to revisit this saved content.';
    }

    return memory;
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

  tz.TZDateTime _nextDailyTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);

    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }
}
