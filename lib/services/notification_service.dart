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

  Function(String savedLinkId)? onNotificationTap;
  String? _launchPayload;

  String? get launchPayload => _launchPayload;

  static const int _weeklyReminderId = 100;
  static const int _dailyReminderId = 200;

  static const int _dailyScheduleCount = 7;
  static const int _weeklyScheduleCount = 4;

  void clearLaunchPayload() {
    _launchPayload = null;
  }

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

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;

        if(payload != null && payload.isNotEmpty) {
          onNotificationTap?.call(payload);
        }
      },
    );

    final lauchDetails = await _plugin.getNotificationAppLaunchDetails();
    
    if(lauchDetails?.didNotificationLaunchApp ?? false) {
      _launchPayload = lauchDetails?.notificationResponse?.payload;
    }
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
    );
  }

  Future<void> scheduleWeeklyReminderBatch({
    required int weekday,
    required int hour,
    required int minute,
    required List<SavedLink> savedLinks,
  }) async {
    await cancelAll();

    if (savedLinks.isEmpty) {
      return;
    }

    final eligibleLinks = savedLinks
        .where(
          (link) =>
              !link.isReviewed &&
              link.aiMemory != null &&
              link.aiMemory!.trim().isNotEmpty,
        )
        .toList();

    if (eligibleLinks.isEmpty) {
      return;
    }

    final firstDate = _nextWeekdayTime(
      weekday,
      hour,
      minute,
    );

    for (int i = 0; i < _weeklyScheduleCount; i++) {
      final savedLink = eligibleLinks[i % eligibleLinks.length];

      final scheduledDate = firstDate.add(
        Duration(days: 7 * i),
      );

      await _scheduleNotification(
        id: _weeklyReminderId + i,
        scheduledDate: scheduledDate,
        savedLink: savedLink,
        channelId: 'weekly_reminder',
        channelName: 'Weekly Reminder',
        channelDescription:
            'Weekly reminder to revisit your saved content',
      );
    }
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
    );
  }

  Future<void> scheduleDailyReminderBatch({
    required int hour,
    required int minute,
    required List<SavedLink> savedLinks,
  }) async {
    await cancelAll();

    if (savedLinks.isEmpty) {
      return;
    }

    final eligibleLinks = savedLinks
        .where(
          (link) =>
              !link.isReviewed &&
              link.aiMemory != null &&
              link.aiMemory!.trim().isNotEmpty,
        )
        .toList();

    if (eligibleLinks.isEmpty) {
      return;
    }

    final firstDate = _nextDailyTime(hour, minute);

    for (int i = 0; i < _dailyScheduleCount; i++) {
      final savedLink = eligibleLinks[i % eligibleLinks.length];

      final scheduledDate = firstDate.add(
        Duration(days: i),
      );

      await _scheduleNotification(
        id: _dailyReminderId + i,
        scheduledDate: scheduledDate,
        savedLink: savedLink,
        channelId: 'daily_reminder',
        channelName: 'Daily Reminder',
        channelDescription:
            'Daily reminder to revisit your saved content',
      );
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required tz.TZDateTime scheduledDate,
    required SavedLink savedLink,
    required String channelId,
    required String channelName,
    required String channelDescription,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'keepremind_reminders',
      'KeepRemind Reminders',
      channelDescription:
          'Reminders to revisit saved content and AI memories',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      id: id,
      title: buildNotificationTitle(savedLink),
      body: buildNotificationBody(savedLink),
      scheduledDate: scheduledDate,
      notificationDetails: details,
      androidScheduleMode:
          AndroidScheduleMode.inexactAllowWhileIdle,
      payload: savedLink.id,
    );
  }

  Future<void> cancelWeeklyReminder() async {
    for(int i=0; i<_weeklyScheduleCount; i++) {
      await _plugin.cancel(id: _weeklyReminderId);
    }
  }

  Future<void> cancelDailyReminder() async {
    for(int i=0; i<_dailyScheduleCount; i++) {
      await _plugin.cancel(id: _dailyReminderId);
    }
  }

  Future<void> cancelAll() async {
    await cancelWeeklyReminder();
    await cancelDailyReminder();
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
