import 'dart:async';

import 'package:team12_flutter_juggle/data/local/pomodoro_record.dart';
import 'package:team12_flutter_juggle/data/local/pomodoro_store.dart';
import 'package:team12_flutter_juggle/domain/models/pomodoro/pomodoro.dart';

class PomodoroService {
  PomodoroService({
    required PomodoroStore store,
    required String? Function() userId,
    DateTime Function()? now,
  }) : _store = store,
       _userId = userId,
       _now = now ?? DateTime.now;

  final PomodoroStore _store;
  final String? Function() _userId;
  final DateTime Function() _now;

  final _changes = StreamController<void>.broadcast();
  Timer? _expiry;
  bool _disposed = false;

  Stream<void> get changes => _changes.stream;

  DateTime get now => _now().toUtc();

  PomodoroRecord get record {
    final uid = _userId();
    if (uid == null) return const PomodoroRecord();
    final record = _store.read(uid);
    return record.copyWith(timer: record.timer.settle(now));
  }

  Future<void> toggle() => _act(
    (timer, settings) => switch (timer.status) {
      PomodoroStatus.running => timer.pause(now),
      PomodoroStatus.paused => timer.resume(now),
      PomodoroStatus.idle ||
      PomodoroStatus.finished => timer.start(now, settings),
    },
  );

  Future<void> reset() => _act((timer, _) => timer.reset());

  Future<void> skip() => _act((timer, _) => timer.skip());

  Future<void> updateSettings({int? focusMinutes, int? breakMinutes}) async {
    final uid = _userId();
    if (uid == null) return;
    final current = record;
    final status = current.timer.status;
    if (status == PomodoroStatus.running || status == PomodoroStatus.paused) {
      return;
    }
    await _save(
      uid,
      current.copyWith(
        settings: current.settings.copyWith(
          focusMinutes: focusMinutes,
          breakMinutes: breakMinutes,
        ),
      ),
    );
  }

  Future<void> expireIfDue() async {
    final uid = _userId();
    if (uid == null) return;
    final stored = _store.read(uid);
    final settled = stored.timer.settle(now);
    if (identical(settled, stored.timer)) return;
    await _save(uid, stored.copyWith(timer: settled));
  }

  void refresh() {
    if (_disposed) return;
    _scheduleExpiry();
    _changes.add(null);
  }

  Future<void> _act(
    PomodoroTimer Function(PomodoroTimer timer, PomodoroSettings settings)
    action,
  ) async {
    final uid = _userId();
    if (uid == null) return;
    final current = record;
    await _save(
      uid,
      current.copyWith(timer: action(current.timer, current.settings)),
    );
  }

  Future<void> _save(String uid, PomodoroRecord record) async {
    final written = _store.write(uid, record);
    refresh();
    await written;
  }

  void _scheduleExpiry() {
    _expiry?.cancel();
    final uid = _userId();
    if (uid == null) return;
    final timer = _store.read(uid).timer;
    final end = timer.endsAt;
    if (timer.status != PomodoroStatus.running || end == null) return;
    final left = end.difference(now);
    _expiry = Timer(
      (left.isNegative ? Duration.zero : left) +
          const Duration(milliseconds: 50),
      expireIfDue,
    );
  }

  void dispose() {
    _disposed = true;
    _expiry?.cancel();
    _changes.close();
  }
}
