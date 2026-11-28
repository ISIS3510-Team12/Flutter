import 'dart:convert';

import 'package:hive_ce/hive.dart';
import 'package:team12_flutter_juggle/data/local/pomodoro_record.dart';

class PomodoroStore {
  PomodoroStore(this._box);

  final Box<String> _box;

  PomodoroRecord read(String userId) {
    final raw = _box.get(userId);
    if (raw == null) return const PomodoroRecord();
    try {
      return PomodoroRecord.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const PomodoroRecord();
    }
  }

  Future<void> write(String userId, PomodoroRecord record) =>
      _box.put(userId, jsonEncode(record.toJson()));
}
