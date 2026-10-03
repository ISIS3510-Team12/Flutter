class AppSettings {
  const AppSettings({required this.soundAndVibrationEnabled});

  final bool soundAndVibrationEnabled;

  AppSettings copyWith({bool? soundAndVibrationEnabled}) {
    return AppSettings(
      soundAndVibrationEnabled:
          soundAndVibrationEnabled ?? this.soundAndVibrationEnabled,
    );
  }
}
