import 'package:shared_preferences/shared_preferences.dart';
import 'package:team12_flutter_juggle/domain/models/profile/app_settings.dart';

class SettingsRepository {
  SettingsRepository(this._preferences);

  static const _themeModeKey = 'settings_theme_mode';
  static const _soundAndVibrationKey = 'settings_sound_and_vibration';

  final SharedPreferencesAsync _preferences;

  Future<AppSettings> getSettings() async {
    final themeName = await _preferences.getString(_themeModeKey);
    final soundAndVibration = await _preferences.getBool(_soundAndVibrationKey);
    return AppSettings(
      themeMode: AppThemeMode.values.firstWhere(
        (mode) => mode.name == themeName,
        orElse: () => AppThemeMode.system,
      ),
      soundAndVibrationEnabled: soundAndVibration ?? true,
    );
  }

  Future<void> updateSettings(AppSettings settings) async {
    await _preferences.setString(_themeModeKey, settings.themeMode.name);
    await _preferences.setBool(
      _soundAndVibrationKey,
      settings.soundAndVibrationEnabled,
    );
  }
}
