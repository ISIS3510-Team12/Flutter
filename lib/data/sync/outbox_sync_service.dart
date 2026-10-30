import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:path_provider/path_provider.dart';
import 'package:team12_flutter_juggle/data/local/pending_op.dart';
import 'package:team12_flutter_juggle/data/local/task_codec.dart';
import 'package:team12_flutter_juggle/data/repositories/location/location_repository.dart';
import 'package:team12_flutter_juggle/data/repositories/tasks/task_repository.dart';
import 'package:team12_flutter_juggle/data/sync/outbox_store.dart';
import 'package:team12_flutter_juggle/data/sync/sync_status.dart';
import 'package:team12_flutter_juggle/domain/models/profile/user_location.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task_group.dart';
import 'package:team12_flutter_juggle/ui/core/utils/network_exceptions.dart';
import 'package:team12_flutter_juggle/ui/core/utils/photo_upload_exception.dart';

typedef PhotoStager = Future<String> Function(String source, String opId);

Future<String> stagePhotoInSupportDirectory(String source, String opId) async {
  final base = await getApplicationSupportDirectory();
  final directory = Directory(
    '${base.path}${Platform.pathSeparator}outbox_photos',
  );
  await directory.create(recursive: true);
  final dot = source.lastIndexOf('.');
  final extension = dot == -1 ? '' : source.substring(dot);
  final target = '${directory.path}${Platform.pathSeparator}$opId$extension';
  await File(source).copy(target);
  return target;
}

Duration outboxBackoff(int attempts, Random random) {
  final base = min(pow(2, attempts).toInt() * 2, 300);
  final jitter = (base * 1000 * 0.25 * random.nextDouble()).round();
  return Duration(milliseconds: base * 1000 + jitter);
}

class OutboxSyncService {
  OutboxSyncService({
    required OutboxStore store,
    required TaskRepository Function() repository,
    required LocationRepository Function() locationRepository,
    required String? Function() userId,
    required bool Function() isOnline,
    required void Function(Set<PendingOpType> types) onSynced,
    DateTime Function()? now,
    Random? random,
    PhotoStager? stagePhoto,
  }) : _store = store,
       _repository = repository,
       _locationRepository = locationRepository,
       _userId = userId,
       _isOnline = isOnline,
       _onSynced = onSynced,
       _now = now ?? DateTime.now,
       _random = random ?? Random(),
       _stagePhoto = stagePhoto ?? stagePhotoInSupportDirectory;

  final OutboxStore _store;
  final TaskRepository Function() _repository;
  final LocationRepository Function() _locationRepository;
  final String? Function() _userId;
  final bool Function() _isOnline;
  final void Function(Set<PendingOpType> types) _onSynced;
  final DateTime Function() _now;
  final Random _random;
  final PhotoStager _stagePhoto;

  final _controller = StreamController<SyncStatus>.broadcast();
  SyncStatus _status = const SyncStatus();
  Timer? _timer;
  bool _running = false;
  bool _disposed = false;

  SyncStatus get status => _status;

  Stream<SyncStatus> watch() async* {
    yield _status;
    yield* _controller.stream;
  }

  Future<PendingOp> enqueueCreate(
    Task task, {
    String? photoPath,
    bool verifyFirst = false,
  }) async {
    final uid = _userId();
    if (uid == null) throw StateError('No signed in user');
    final id = _newId();
    final stagedPhoto = photoPath == null
        ? null
        : await _stagePhoto(photoPath, id);
    final op = PendingOp(
      id: id,
      userId: uid,
      type: PendingOpType.createTask,
      payload: taskToJson(task),
      createdAt: _now(),
      photoPath: stagedPhoto,
      verifyFirst: verifyFirst,
      attempts: verifyFirst ? 1 : 0,
    );
    await _store.put(op);
    _publish();
    return op;
  }

  Future<PendingOp> enqueueSaveLocation(UserLocation location) async {
    final uid = _userId();
    if (uid == null) throw StateError('No signed in user');
    await _removeSaveLocation(uid);
    final op = PendingOp(
      id: _newId(),
      userId: uid,
      type: PendingOpType.saveLocation,
      payload: location.toJson(),
      createdAt: _now(),
    );
    await _store.put(op);
    _publish();
    if (_isOnline()) unawaited(flush());
    return op;
  }

  Future<void> discardSaveLocation() async {
    final uid = _userId();
    if (uid == null) return;
    await _removeSaveLocation(uid);
    _publish();
  }

  Future<void> _removeSaveLocation(String uid) async {
    for (final op in _store.forUser(uid)) {
      if (op.type == PendingOpType.saveLocation) await _store.remove(op.id);
    }
  }

  String _newId() =>
      '${_now().microsecondsSinceEpoch}-${_random.nextInt(1 << 32)}';

  Future<void> retry(String id) async {
    final op = _find(id);
    if (op == null) return;
    await _store.put(
      op.copyWith(
        status: PendingOpStatus.pending,
        nextAttemptAt: null,
        verifyFirst: op.isTask && op.attempts > 0,
      ),
    );
    _publish();
    unawaited(flush());
  }

  Future<void> discard(String id) async {
    await _store.remove(id);
    _publish();
  }

  Future<void> flush() async {
    if (_running || _disposed) return;
    final uid = _userId();
    if (uid == null || !_isOnline()) {
      _publish();
      return;
    }
    _running = true;
    _timer?.cancel();
    final synced = <PendingOpType>{};
    try {
      _status = _status.copyWith(isSyncing: true, message: null);
      _emit();
      for (final op in _store.forUser(uid)) {
        if (_disposed) break;
        if (op.status == PendingOpStatus.failed) continue;
        final next = op.nextAttemptAt;
        if (next != null && next.isAfter(_now())) continue;
        if (!_isOnline()) break;
        if (await _process(op)) synced.add(op.type);
      }
    } finally {
      _running = false;
      if (synced.isNotEmpty) {
        _status = _status.copyWith(lastSyncedAt: _now());
      }
      _status = _status.copyWith(isSyncing: false);
      _publish();
      _schedule();
      if (synced.isNotEmpty) _onSynced(synced);
    }
  }

  Future<bool> _process(PendingOp op) => switch (op.type) {
    PendingOpType.createTask => _processCreateTask(op),
    PendingOpType.saveLocation => _processSaveLocation(op),
  };

  Future<bool> _processSaveLocation(PendingOp op) async {
    try {
      await _locationRepository().saveLocation(op.location);
      await _store.remove(op.id);
      return true;
    } catch (error) {
      await _fail(op, error);
      return false;
    }
  }

  Future<bool> _processCreateTask(PendingOp original) async {
    var op = original;
    try {
      if (op.serverTaskId == null) {
        final task = op.task;
        String? existingId;
        if (op.verifyFirst) existingId = await _findExisting(task, op.userId);
        final id = existingId ?? (await _repository().createTask(task)).id;
        op = op.copyWith(serverTaskId: id, verifyFirst: false);
        await _store.put(op);
      }
      final photo = op.photoPath;
      if (photo != null) {
        try {
          await _repository().uploadTaskPhoto(op.serverTaskId!, photo);
        } on PhotoUploadException catch (e) {
          _status = _status.copyWith(
            message: 'A photo could not be uploaded. ${e.message}',
          );
        }
      }
      await _store.remove(op.id);
      return true;
    } catch (error) {
      await _fail(op, error);
      return false;
    }
  }

  Future<void> _fail(PendingOp op, Object error) async {
    if (isOfflineFailure(error)) {
      final attempts = op.attempts + 1;
      await _store.put(
        op.copyWith(
          attempts: attempts,
          nextAttemptAt: _now().add(outboxBackoff(attempts, _random)),
          verifyFirst: op.isTask && op.serverTaskId == null,
          lastError: error.toString(),
        ),
      );
      return;
    }
    await _store.put(
      op.copyWith(
        status: PendingOpStatus.failed,
        attempts: op.attempts + 1,
        lastError: error.toString(),
      ),
    );
    _status = _status.copyWith(
      message: switch (op.type) {
        PendingOpType.createTask =>
          "Couldn't upload '${op.task.title}'. Retry or discard it.",
        PendingOpType.saveLocation =>
          "Couldn't sync your saved place. Retry or discard it.",
      },
    );
  }

  Future<String?> _findExisting(Task task, String userId) async {
    final groupId = task.groupId;
    if (groupId == null) return null;
    final tasks = await _repository().getGroupTasks(
      TaskGroup(
        id: groupId,
        name: task.groupName,
        description: '',
        pendingCount: 0,
      ),
    );
    final deadline = task.deadline.toUtc().millisecondsSinceEpoch;
    for (final candidate in tasks) {
      if (candidate.isMine &&
          candidate.title == task.title &&
          candidate.deadline.toUtc().millisecondsSinceEpoch == deadline) {
        return candidate.id;
      }
    }
    return null;
  }

  void _schedule() {
    _timer?.cancel();
    if (_disposed) return;
    final uid = _userId();
    if (uid == null) return;
    DateTime? earliest;
    for (final op in _store.forUser(uid)) {
      final next = op.nextAttemptAt;
      if (op.status == PendingOpStatus.failed || next == null) continue;
      if (earliest == null || next.isBefore(earliest)) earliest = next;
    }
    if (earliest == null) return;
    var delay = earliest.difference(_now());
    if (delay < const Duration(seconds: 1)) delay = const Duration(seconds: 1);
    _timer = Timer(delay, flush);
  }

  PendingOp? _find(String id) {
    for (final op in _store.all()) {
      if (op.id == id) return op;
    }
    return null;
  }

  void _publish() {
    final uid = _userId();
    final ops = uid == null ? <PendingOp>[] : _store.forUser(uid);
    _status = SyncStatus(
      pendingCount: ops
          .where((op) => op.status == PendingOpStatus.pending)
          .length,
      failedCount: ops
          .where((op) => op.status == PendingOpStatus.failed)
          .length,
      isSyncing: _status.isSyncing,
      lastSyncedAt: _status.lastSyncedAt,
      message: _status.message,
    );
    _emit();
  }

  void _emit() {
    if (!_controller.isClosed) _controller.add(_status);
  }

  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _controller.close();
  }
}
