import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/media/photo_importer.dart';
import 'package:team12_flutter_juggle/data/media/photo_processing_worker.dart';
import 'package:team12_flutter_juggle/ui/core/sync/sync_providers.dart';

typedef PhotoImporterFactory = PhotoImporter Function(
  PhotoProcessingWorker worker,
);

final photoImporterFactoryProvider = Provider<PhotoImporterFactory>(
  (ref) => PhotoImporter.new,
);

class PhotoImportViewModel extends Notifier<Map<int, int>> {
  PhotoProcessingWorker? _worker;
  Future<void> _queue = Future.value();

  @override
  Map<int, int> build() {
    ref.onDispose(() => _worker?.dispose());
    return const {};
  }

  Future<int> addPhotos(int projectId, List<String> sources) {
    _change(projectId, sources.length);
    final batch = _queue.then((_) => _import(projectId, sources));
    _queue = batch.then((_) {}, onError: (_) {});
    return batch;
  }

  Future<int> _import(int projectId, List<String> sources) async {
    final worker = _worker ??= PhotoProcessingWorker();
    final importer = ref.read(photoImporterFactoryProvider)(worker);
    final sync = ref.read(outboxSyncServiceProvider);
    var failed = 0;
    for (final source in sources) {
      try {
        final id = sync.newOperationId();
        final photo = await importer.import(source, id);
        await sync.enqueuePhotoUpload(
          id: id,
          projectId: projectId,
          photoPath: photo.path,
          thumbnailPath: photo.thumbnailPath,
        );
      } catch (error) {
        failed++;
        debugPrint('Photo import failed: $error');
      }
      _change(projectId, -1);
    }
    if (state.isEmpty) {
      _worker?.dispose();
      _worker = null;
    }
    return failed;
  }

  void _change(int projectId, int delta) {
    final next = Map<int, int>.of(state);
    final count = (next[projectId] ?? 0) + delta;
    if (count > 0) {
      next[projectId] = count;
    } else {
      next.remove(projectId);
    }
    state = next;
  }
}
