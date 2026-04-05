import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _reminderDayKey = 'reminder_day';
  static const String _reminderHourKey = 'reminder_hour';
  static const String _reminderMinuteKey = 'reminder_minute';


  Future<void> saveReminderSettings({
    required int weekday,
    required int hour,
    required int minute,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_reminderDayKey, weekday);
    await prefs.setInt(_reminderHourKey, hour);
    await prefs.setInt(_reminderMinuteKey, minute);
  }

  Future<Map<String, int>> loadReminderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'weekday' : prefs.getInt(_reminderDayKey) ?? DateTime.monday,
      'hour' : prefs.getInt(_reminderHourKey) ?? 10,
      'minute' : prefs.getInt(_reminderMinuteKey) ?? 0,
    };
  }
}