import 'package:team12_flutter_juggle/domain/models/profile/app_settings.dart';

// TODO: back this with the shared_preferences package so settings survive app restarts
class SettingsLocalService {
  AppSettings _storedSettings = const AppSettings(
    themeMode: AppThemeMode.system,
    languageCode: 'en',
    soundAndVibrationEnabled: true,
  );

  Future<AppSettings> readSettings() async {
    return _storedSettings;
  }

  Future<void> writeSettings(AppSettings settings) async {
    _storedSettings = settings;
  }
}
