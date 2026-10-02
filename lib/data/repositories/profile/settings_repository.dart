import 'package:team12_flutter_juggle/domain/models/profile/app_settings.dart';

class SettingsRepository {
  AppSettings _settings = const AppSettings(
    themeMode: AppThemeMode.system,
    soundAndVibrationEnabled: true,
  );

  Future<AppSettings> getSettings() async {
    return _settings;
  }

  Future<void> updateSettings(AppSettings settings) async {
    _settings = settings;
  }
}
