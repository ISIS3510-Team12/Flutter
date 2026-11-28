import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/local/pomodoro_record.dart';
import 'package:team12_flutter_juggle/data/repositories/pomodoro/pomodoro_notification_repository_provider.dart';
import 'package:team12_flutter_juggle/data/repositories/pomodoro/pomodoro_service.dart';
import 'package:team12_flutter_juggle/data/repositories/pomodoro/pomodoro_service_provider.dart';
import 'package:team12_flutter_juggle/domain/models/pomodoro/pomodoro.dart';

class PomodoroUiState {
  const PomodoroUiState({required this.record, required this.remainingSeconds});

  final PomodoroRecord record;
  final int remainingSeconds;

  PomodoroTimer get timer => record.timer;
  PomodoroSettings get settings => record.settings;

  bool get isRunning => timer.status == PomodoroStatus.running;

  bool get canEditSettings =>
      timer.status == PomodoroStatus.idle ||
      timer.status == PomodoroStatus.finished;

  double get progress =>
      (1 - remainingSeconds / settings.secondsFor(timer.phase)).clamp(0.0, 1.0);
}

class PomodoroViewModel extends Notifier<PomodoroUiState> {
  late PomodoroService _service;
  Timer? _ticker;

  @override
  PomodoroUiState build() {
    _service = ref.watch(pomodoroServiceProvider);
    final subscription = _service.changes.listen((_) => _refresh());
    ref.onDispose(subscription.cancel);
    ref.onDispose(() => _ticker?.cancel());
    final initial = _read();
    _updateTicker(initial);
    return initial;
  }

  Future<void> toggle() async {
    final service = _service;
    final notifications = ref.read(pomodoroNotificationRepositoryProvider);
    await service.toggle();
    if (service.record.timer.status != PomodoroStatus.running) return;
    if (await notifications.requestPermissions()) {
      await notifications.show(service.record.timer, force: true);
    }
  }

  Future<void> reset() => _service.reset();

  Future<void> skip() => _service.skip();

  Future<void> setFocusMinutes(int minutes) =>
      _service.updateSettings(focusMinutes: minutes);

  Future<void> setBreakMinutes(int minutes) =>
      _service.updateSettings(breakMinutes: minutes);

  PomodoroUiState _read() {
    final record = _service.record;
    return PomodoroUiState(
      record: record,
      remainingSeconds: record.timer.remainingAt(_service.now, record.settings),
    );
  }

  void _refresh() {
    if (!ref.mounted) return;
    final next = _read();
    state = next;
    _updateTicker(next);
  }

  void _updateTicker(PomodoroUiState current) {
    if (!current.isRunning) {
      _ticker?.cancel();
      _ticker = null;
      return;
    }
    _ticker ??= Timer.periodic(const Duration(milliseconds: 250), (_) {
      unawaited(_service.expireIfDue());
      final next = _read();
      if (next.remainingSeconds != state.remainingSeconds) {
        state = next;
        _updateTicker(next);
      }
    });
  }
}
