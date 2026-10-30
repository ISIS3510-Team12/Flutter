class AppSettings {
  const AppSettings({
    required this.soundAndVibrationEnabled,
    this.dailyRemindersEnabled = false,
    this.dailyReminderTime,
  });

  final bool soundAndVibrationEnabled;
  final bool dailyRemindersEnabled;
  final String? dailyReminderTime;

  AppSettings copyWith({
    bool? soundAndVibrationEnabled,
    bool? dailyRemindersEnabled,
    String? dailyReminderTime,
    bool clearDailyReminderTime = false,
  }) {
    return AppSettings(
      soundAndVibrationEnabled:
          soundAndVibrationEnabled ?? this.soundAndVibrationEnabled,
      dailyRemindersEnabled:
          dailyRemindersEnabled ?? this.dailyRemindersEnabled,
      dailyReminderTime: clearDailyReminderTime
          ? null
          : dailyReminderTime ?? this.dailyReminderTime,
    );
  }
}
