enum AppThemeMode { system, light, dark }

class AppSettings {
  const AppSettings({
    required this.themeMode,
    required this.languageCode,
    required this.soundAndVibrationEnabled,
  });

  final AppThemeMode themeMode;
  final String languageCode;
  final bool soundAndVibrationEnabled;

  AppSettings copyWith({
    AppThemeMode? themeMode,
    String? languageCode,
    bool? soundAndVibrationEnabled,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      languageCode: languageCode ?? this.languageCode,
      soundAndVibrationEnabled:
          soundAndVibrationEnabled ?? this.soundAndVibrationEnabled,
    );
  }
}
