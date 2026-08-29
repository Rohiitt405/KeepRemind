import 'package:flutter/material.dart';
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

  static const String defaultChannelId = 'keepremind_reminders';
  static const String defaultChannelName = 'KeepRemind Reminders';
  static const String defaultChannelDescription =
      'Reminders to revisit saved content and AI memories';

  void clearLaunchPayload() {
    _launchPayload = null;
  }

  Future<void> initialize() async {
    tz_data.initializeTimeZones();

    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));
    } catch (e) {
      debugPrint('NotificationService: Failed to configure local timezone, falling back to local/UTC: $e');
      try {
        final rawTimezone = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(rawTimezone.toString()));
      } catch (_) {
        tz.setLocalLocation(tz.getLocation('UTC'));
      }
    }

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

        if (payload != null && payload.isNotEmpty) {
          onNotificationTap?.call(payload);
        }
      },
    );

    final android = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      const channel = AndroidNotificationChannel(
        defaultChannelId,
        defaultChannelName,
        description: defaultChannelDescription,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );
      await android.createNotificationChannel(channel);
    }

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      _launchPayload = launchDetails?.notificationResponse?.payload;
    }
  }

  Future<bool> requestPermission() async {
    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      if (android != null) {
        final granted = await android.requestNotificationsPermission() ?? false;
        final exactAlarmGranted = await android.canScheduleExactNotifications() ?? false;

        debugPrint('Notification permission: $granted, exact alarm: $exactAlarmGranted');

        if (!exactAlarmGranted) {
          try {
            await android.requestExactAlarmsPermission();
          } catch (e) {
            debugPrint('Error requesting exact alarms permission: $e');
          }
        }

        return granted;
      }

      final ios = _plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        final granted = await ios.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ?? false;
        return granted;
      }
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
    }

    return true;
  }

  Future<AndroidScheduleMode> _getScheduleMode() async {
    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        final canExact = await android.canScheduleExactNotifications() ?? false;
        if (canExact) {
          return AndroidScheduleMode.exactAllowWhileIdle;
        }
      }
    } catch (e) {
      debugPrint('Error checking exact alarm support: $e');
    }
    return AndroidScheduleMode.inexactAllowWhileIdle;
  }

  List<SavedLink> _getPrioritizedLinks(List<SavedLink> savedLinks) {
    return savedLinks
      .where(
        (link) => !link.isReviewed && 
          link.aiMemory != null && 
          link.aiMemory!.trim().isNotEmpty,
      )
      .toList();
  }

  Future<void> scheduleWeeklyReminder({
    int weekday = DateTime.monday,
    int hour = 10,
    int minute = 0,
    SavedLink? savedLink,
  }) async {
    await cancelAll();

    final scheduledDate = _nextWeekdayTime(weekday, hour, minute);

    if (savedLink != null) {
      await _scheduleNotification(
        id: _weeklyReminderId,
        scheduledDate: scheduledDate,
        title: buildNotificationTitle(savedLink),
        body: buildNotificationBody(savedLink),
        payload: savedLink.id,
      );
    } else {
      await _scheduleNotification(
        id: _weeklyReminderId,
        scheduledDate: scheduledDate,
        title: 'KeepRemind Weekly',
        body: 'Check out your saved content and organize your weekly insights!',
        payload: null,
      );
    }
  }

  Future<void> scheduleWeeklyReminderBatch({
    required int weekday,
    required int hour,
    required int minute,
    List<SavedLink> savedLinks = const [],
  }) async {
    await cancelAll();

    final firstDate = _nextWeekdayTime(weekday, hour, minute);
    final eligibleLinks = _getPrioritizedLinks(savedLinks);

    if(eligibleLinks.isEmpty) {
      return;
    }

    for (int i = 0; i < _weeklyScheduleCount; i++) {
      final scheduledDate = tz.TZDateTime(
        tz.local,
        firstDate.year,
        firstDate.month,
        firstDate.day + (7 * i),
        firstDate.hour,
        firstDate.minute,
      );

      final savedLink = eligibleLinks[i % eligibleLinks.length];

      await _scheduleNotification(
        id: _weeklyReminderId + i,
        scheduledDate: scheduledDate,
        title: buildNotificationTitle(savedLink),
        body: buildNotificationBody(savedLink),
        payload: savedLink.id,
      );
    }
  }

  Future<void> scheduleDailyReminder({
    int hour = 10,
    int minute = 0,
    SavedLink? savedLink,
  }) async {
    await cancelAll();

    final scheduledDate = _nextDailyTime(hour, minute);

    if (savedLink != null) {
      await _scheduleNotification(
        id: _dailyReminderId,
        scheduledDate: scheduledDate,
        title: buildNotificationTitle(savedLink),
        body: buildNotificationBody(savedLink),
        payload: savedLink.id,
      );
    } else {
      await _scheduleNotification(
        id: _dailyReminderId,
        scheduledDate: scheduledDate,
        title: 'KeepRemind Daily',
        body: 'Take a moment to revisit your saved ideas or add new links!',
        payload: null,
      );
    }
  }

  Future<void> scheduleDailyReminderBatch({
    required int hour,
    required int minute,
    List<SavedLink> savedLinks = const [],
  }) async {
    await cancelAll();

    final firstDate = _nextDailyTime(hour, minute);
    final eligibleLinks = _getPrioritizedLinks(savedLinks);

    if(eligibleLinks.isEmpty) {
      return;
    }

    for (int i = 0; i < _dailyScheduleCount; i++) {
      final scheduledDate = tz.TZDateTime(
        tz.local,
        firstDate.year,
        firstDate.month,
        firstDate.day + i,
        firstDate.hour,
        firstDate.minute,
      );

      final savedLink = eligibleLinks[i % eligibleLinks.length];
        
      await _scheduleNotification(
        id: _dailyReminderId + i,
        scheduledDate: scheduledDate,
        title: buildNotificationTitle(savedLink),
        body: buildNotificationBody(savedLink),
        payload: savedLink.id,
      );
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required tz.TZDateTime scheduledDate,
    required String title,
    required String body,
    String? payload,
    String channelId = defaultChannelId,
    String channelName = defaultChannelName,
    String channelDescription = defaultChannelDescription,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final scheduleMode = await _getScheduleMode();

    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: details,
        androidScheduleMode: scheduleMode,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Exact schedule failed ($e), falling back to inexact schedule mode.');
      try {
        await _plugin.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: scheduledDate,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: payload,
        );
      } catch (fallbackError) {
        debugPrint('Fallback scheduling failed: $fallbackError');
      }
    }
  }

  Future<void> cancelWeeklyReminder() async {
    for (int i = 0; i < _weeklyScheduleCount; i++) {
      await _plugin.cancel(id: _weeklyReminderId + i);
    }
  }

  Future<void> cancelDailyReminder() async {
    for (int i = 0; i < _dailyScheduleCount; i++) {
      await _plugin.cancel(id: _dailyReminderId + i);
    }
  }

  Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
    } catch (e) {
      debugPrint('Error in plugin.cancelAll: $e');
    }
    for (int i = 0; i < _weeklyScheduleCount; i++) {
      await _plugin.cancel(id: _weeklyReminderId + i);
    }
    for (int i = 0; i < _dailyScheduleCount; i++) {
      await _plugin.cancel(id: _dailyReminderId + i);
    }
  }

  Future<void> debugScheduledNotifications() async {
    try {
      final pending = await _plugin.pendingNotificationRequests();

      debugPrint('Pending notifications count: ${pending.length}');
      for (final notification in pending) {
        debugPrint(
          'Notification ID: ${notification.id}, '
          'Title: ${notification.title}, '
          'Body: ${notification.body}, '
          'Payload: ${notification.payload}',
        );
      }
    } catch (e) {
      debugPrint('Error fetching pending notifications: $e');
    }
  }

  String buildNotificationTitle(SavedLink savedLink) {
    final title = savedLink.title.trim();
    return title.isNotEmpty ? title : 'Your saved memory';
  }

  String buildNotificationBody(SavedLink savedLink) {
    final memory = savedLink.aiMemory?.trim();
    if (memory != null && memory.isNotEmpty) {
      return memory;
    }

    final caption = savedLink.caption.trim();
    if (caption.isNotEmpty) {
      return caption;
    }

    return 'Take a moment to revisit this saved content.';
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

    return tz.TZDateTime(
      tz.local,
      scheduled.year,
      scheduled.month,
      scheduled.day,
      hour,
      minute,
    );
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

    return tz.TZDateTime(
      tz.local,
      scheduled.year,
      scheduled.month,
      scheduled.day,
      hour,
      minute,
    );
  }
}
