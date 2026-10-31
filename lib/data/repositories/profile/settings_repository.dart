import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team12_flutter_juggle/domain/models/profile/app_settings.dart';

class SettingsRepository {
  SettingsRepository(this._dio);

  final Dio _dio;

  static const _dailyRemindersEnabledKey = 'daily_reminders_enabled';
  static const _dailyReminderTimeKey = 'daily_reminder_time';

  Future<AppSettings> getSettings() async {
    bool soundAndVibrationEnabled = true;

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/users/preferences',
      );

      soundAndVibrationEnabled =
          response.data!['push_enabled'] as bool;
    } on DioException {
      // Keep the default value if the backend is unavailable.
    }

    final preferences = await SharedPreferences.getInstance();

    return AppSettings(
      soundAndVibrationEnabled: soundAndVibrationEnabled,
      dailyRemindersEnabled:
          preferences.getBool(_dailyRemindersEnabledKey) ?? false,
      dailyReminderTime:
          preferences.getString(_dailyReminderTimeKey),
    );
  }

  Future<void> updateSoundAndVibration(bool enabled) async {
    try {
      await _dio.patch<Map<String, dynamic>>(
        '/users/preferences',
        data: {'push_enabled': enabled},
      );
    } catch (e) {
      throw Exception('Failed to update sound and vibration: $e');
    }
  }

  Future<void> updateDailyReminders(bool enabled) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setBool(
      _dailyRemindersEnabledKey,
      enabled,
    );

    if (!enabled) {
      await preferences.remove(_dailyReminderTimeKey);
    }
  }

  Future<void> updateDailyReminderTime(String time) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(
      _dailyReminderTimeKey,
      time,
    );
  }
}
