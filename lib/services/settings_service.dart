import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _reminderTypeKey = 'reminder_type'; // 'daily' | 'weekly'
  static const String _reminderDayKey = 'reminder_day';
  static const String _reminderHourKey = 'reminder_hour';
  static const String _reminderMinuteKey = 'reminder_minute';
  static const String _lastUpdateCheckKey = 'last_update_check';

  Future<void> saveReminderSettings({
    required String type, // 'daily' or 'weekly'
    required int weekday,
    required int hour,
    required int minute,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_reminderTypeKey, type);
    await prefs.setInt(_reminderDayKey, weekday);
    await prefs.setInt(_reminderHourKey, hour);
    await prefs.setInt(_reminderMinuteKey, minute);
  }

  Future<Map<String, dynamic>> loadReminderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'type': prefs.getString(_reminderTypeKey) ?? 'weekly',
      'weekday': prefs.getInt(_reminderDayKey) ?? DateTime.monday,
      'hour': prefs.getInt(_reminderHourKey) ?? 10,
      'minute': prefs.getInt(_reminderMinuteKey) ?? 0,
    };
  }

  Future<void> saveLastUpdateCheck(DateTime dateTime) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_lastUpdateCheckKey, dateTime.toIso8601String());
  }

  Future<DateTime?> getLastUpdateCheck() async {
    final prefs = await SharedPreferences.getInstance();

    final value = prefs.getString(_lastUpdateCheckKey);

    if(value == null) {
      return null;
    }

    return DateTime.tryParse(value);
  }

  Future<bool> shouldCheckForUpdate() async {
    final lastCheck = await getLastUpdateCheck();

    if(lastCheck == null) {
      return true;
    }

    final difference = DateTime.now().difference(lastCheck);

    return difference.inHours >= 24;
  }
}