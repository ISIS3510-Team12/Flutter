import 'dart:math';

const pomodoroCycles = 4;

String formatCountdown(int seconds) {
  final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
  final rest = (seconds % 60).toString().padLeft(2, '0');
  return '$minutes:$rest';
}

enum PomodoroPhase { focus, shortBreak }

enum PomodoroStatus { idle, running, paused, finished }

class PomodoroSettings {
  const PomodoroSettings({this.focusMinutes = 25, this.breakMinutes = 5});

  static const minFocusMinutes = 1;
  static const maxFocusMinutes = 180;
  static const minBreakMinutes = 1;
  static const maxBreakMinutes = 60;

  final int focusMinutes;
  final int breakMinutes;

  int secondsFor(PomodoroPhase phase) =>
      60 * (phase == PomodoroPhase.focus ? focusMinutes : breakMinutes);

  PomodoroSettings copyWith({int? focusMinutes, int? breakMinutes}) =>
      PomodoroSettings(
        focusMinutes: (focusMinutes ?? this.focusMinutes).clamp(
          minFocusMinutes,
          maxFocusMinutes,
        ),
        breakMinutes: (breakMinutes ?? this.breakMinutes).clamp(
          minBreakMinutes,
          maxBreakMinutes,
        ),
      );

  Map<String, dynamic> toJson() => {
    'focus_minutes': focusMinutes,
    'break_minutes': breakMinutes,
  };

  factory PomodoroSettings.fromJson(Map<String, dynamic> json) =>
      PomodoroSettings(
        focusMinutes: json['focus_minutes'] as int,
        breakMinutes: json['break_minutes'] as int,
      );
}

class PomodoroTimer {
  const PomodoroTimer({
    this.phase = PomodoroPhase.focus,
    this.cycle = 1,
    this.status = PomodoroStatus.idle,
    this.remainingSeconds,
    this.endsAt,
  });

  final PomodoroPhase phase;
  final int cycle;
  final PomodoroStatus status;
  final int? remainingSeconds;
  final DateTime? endsAt;

  bool get completedAllCycles =>
      status == PomodoroStatus.finished &&
      phase == PomodoroPhase.shortBreak &&
      cycle == pomodoroCycles;

  PomodoroTimer settle(DateTime now) {
    final end = endsAt;
    if (status != PomodoroStatus.running || end == null || end.isAfter(now)) {
      return this;
    }
    return PomodoroTimer(
      phase: phase,
      cycle: cycle,
      status: PomodoroStatus.finished,
      endsAt: end,
    );
  }

  int remainingAt(DateTime now, PomodoroSettings settings) => switch (status) {
    PomodoroStatus.idle => settings.secondsFor(phase),
    PomodoroStatus.paused => remainingSeconds ?? 0,
    PomodoroStatus.finished => 0,
    PomodoroStatus.running => max(
      0,
      (endsAt!.difference(now).inMilliseconds / 1000).ceil(),
    ),
  };

  PomodoroTimer start(DateTime now, PomodoroSettings settings) {
    final current = settle(now);
    final PomodoroTimer from;
    if (current.status == PomodoroStatus.idle) {
      from = current;
    } else if (current.status == PomodoroStatus.finished) {
      from = current._following();
    } else {
      return this;
    }
    return _running(from, now, settings.secondsFor(from.phase));
  }

  PomodoroTimer pause(DateTime now) {
    final current = settle(now);
    if (current.status != PomodoroStatus.running) return current;
    return PomodoroTimer(
      phase: phase,
      cycle: cycle,
      status: PomodoroStatus.paused,
      remainingSeconds: current.remainingAt(now, const PomodoroSettings()),
    );
  }

  PomodoroTimer resume(DateTime now) {
    final remaining = remainingSeconds;
    if (status != PomodoroStatus.paused || remaining == null) return this;
    return _running(this, now, remaining);
  }

  PomodoroTimer reset() => const PomodoroTimer();

  PomodoroTimer skip() => _following();

  PomodoroTimer _following() => phase == PomodoroPhase.focus
      ? PomodoroTimer(phase: PomodoroPhase.shortBreak, cycle: cycle)
      : PomodoroTimer(cycle: cycle % pomodoroCycles + 1);

  static PomodoroTimer _running(
    PomodoroTimer from,
    DateTime now,
    int seconds,
  ) => PomodoroTimer(
    phase: from.phase,
    cycle: from.cycle,
    status: PomodoroStatus.running,
    endsAt: now.toUtc().add(Duration(seconds: seconds)),
  );

  Map<String, dynamic> toJson() => {
    'phase': phase.name,
    'cycle': cycle,
    'status': status.name,
    if (remainingSeconds != null) 'remaining_seconds': remainingSeconds,
    if (endsAt != null) 'ends_at': endsAt!.toUtc().toIso8601String(),
  };

  factory PomodoroTimer.fromJson(Map<String, dynamic> json) {
    final endsAt = json['ends_at'] as String?;
    return PomodoroTimer(
      phase: PomodoroPhase.values.byName(json['phase'] as String),
      cycle: json['cycle'] as int,
      status: PomodoroStatus.values.byName(json['status'] as String),
      remainingSeconds: json['remaining_seconds'] as int?,
      endsAt: endsAt == null ? null : DateTime.parse(endsAt).toUtc(),
    );
  }
}
