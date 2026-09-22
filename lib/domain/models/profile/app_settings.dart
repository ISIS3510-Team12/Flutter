enum AppThemeMode { system, light, dark }

class AppSettings {
  const AppSettings({
    required this.themeMode,
    required this.soundAndVibrationEnabled,
  });

  final AppThemeMode themeMode;
  final bool soundAndVibrationEnabled;

  AppSettings copyWith({
    AppThemeMode? themeMode,
    bool? soundAndVibrationEnabled,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      soundAndVibrationEnabled:
          soundAndVibrationEnabled ?? this.soundAndVibrationEnabled,
    );
  }
}
