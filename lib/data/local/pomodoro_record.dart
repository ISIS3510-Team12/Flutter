import 'package:team12_flutter_juggle/domain/models/pomodoro/pomodoro.dart';

class PomodoroRecord {
  const PomodoroRecord({
    this.settings = const PomodoroSettings(),
    this.timer = const PomodoroTimer(),
  });

  final PomodoroSettings settings;
  final PomodoroTimer timer;

  PomodoroRecord copyWith({PomodoroSettings? settings, PomodoroTimer? timer}) =>
      PomodoroRecord(
        settings: settings ?? this.settings,
        timer: timer ?? this.timer,
      );

  Map<String, dynamic> toJson() => {
    'settings': settings.toJson(),
    'timer': timer.toJson(),
  };

  factory PomodoroRecord.fromJson(Map<String, dynamic> json) => PomodoroRecord(
    settings: PomodoroSettings.fromJson(
      json['settings'] as Map<String, dynamic>,
    ),
    timer: PomodoroTimer.fromJson(json['timer'] as Map<String, dynamic>),
  );
}
