import 'dart:convert';
import 'dart:io';

import 'package:hive_ce/hive.dart';
import 'package:team12_flutter_juggle/data/local/pending_op.dart';

class OutboxStore {
  OutboxStore(this._box);

  final Box<String> _box;

  List<PendingOp> all() {
    final ops = <PendingOp>[];
    for (final raw in _box.values) {
      try {
        ops.add(PendingOp.fromJson(jsonDecode(raw) as Map<String, dynamic>));
      } catch (_) {}
    }
    ops.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return ops;
  }

  List<PendingOp> forUser(String userId) =>
      all().where((op) => op.userId == userId).toList();

  Stream<List<PendingOp>> watch() async* {
    yield all();
    await for (final _ in _box.watch()) {
      yield all();
    }
  }

  Future<void> put(PendingOp op) => _box.put(op.id, jsonEncode(op.toJson()));

  Future<void> remove(String id) async {
    final raw = _box.get(id);
    await _box.delete(id);
    if (raw == null) return;
    try {
      final path = PendingOp.fromJson(jsonDecode(raw) as Map<String, dynamic>)
          .photoPath;
      if (path != null) await _deleteFile(path);
    } catch (_) {}
  }

  Future<void> clear() async {
    final paths = [for (final op in all()) ?op.photoPath];
    await _box.clear();
    for (final path in paths) {
      await _deleteFile(path);
    }
  }

  Future<void> _deleteFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }
}
