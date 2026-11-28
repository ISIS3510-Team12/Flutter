import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:image/image.dart' as img;

const photoMaxSide = 1600;
const thumbnailMaxSide = 320;

class PhotoProcessingException implements Exception {
  const PhotoProcessingException(this.message);

  final String message;

  @override
  String toString() => message;
}

typedef _Job = ({int id, String source, String fullPath, String thumbPath});
typedef _JobResult = ({int id, String? error});

class PhotoProcessingWorker {
  final _pending = <int, Completer<void>>{};
  Completer<SendPort>? _ready;
  Future<SendPort>? _starting;
  ReceivePort? _port;
  Isolate? _isolate;
  int _nextId = 0;
  bool _disposed = false;

  bool get isRunning => _isolate != null;

  Future<void> process({
    required String source,
    required String fullPath,
    required String thumbPath,
  }) async {
    if (_disposed) throw const PhotoProcessingException('Worker disposed.');
    final commands = await (_starting ??= _start());
    if (_disposed) throw const PhotoProcessingException('Worker disposed.');
    final id = _nextId++;
    final completer = Completer<void>();
    _pending[id] = completer;
    commands.send((
      id: id,
      source: source,
      fullPath: fullPath,
      thumbPath: thumbPath,
    ));
    return completer.future;
  }

  Future<SendPort> _start() async {
    final port = ReceivePort();
    final ready = Completer<SendPort>();
    ready.future.ignore();
    _ready = ready;
    _port = port;
    port.listen((message) {
      if (message is SendPort) {
        ready.complete(message);
      } else if (message is _JobResult) {
        final completer = _pending.remove(message.id);
        final error = message.error;
        if (error == null) {
          completer?.complete();
        } else {
          completer?.completeError(PhotoProcessingException(error));
        }
      } else {
        _stop('The worker stopped unexpectedly.');
      }
    });
    try {
      final isolate = await Isolate.spawn(
        _photoWorkerMain,
        port.sendPort,
        onError: port.sendPort,
        onExit: port.sendPort,
        debugName: 'photo-processing',
      );
      if (_port == port) {
        _isolate = isolate;
      } else {
        isolate.kill(priority: Isolate.immediate);
      }
    } catch (_) {
      _stop('The worker could not start.');
      rethrow;
    }
    return ready.future;
  }

  void _stop(String reason) {
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _port?.close();
    _port = null;
    _starting = null;
    final ready = _ready;
    _ready = null;
    if (ready != null && !ready.isCompleted) {
      ready.completeError(PhotoProcessingException(reason));
    }
    final pending = _pending.values.toList();
    _pending.clear();
    for (final completer in pending) {
      completer.completeError(PhotoProcessingException(reason));
    }
  }

  void dispose() {
    _disposed = true;
    _stop('Worker disposed.');
  }
}

Future<void> _photoWorkerMain(SendPort results) async {
  final commands = ReceivePort();
  results.send(commands.sendPort);
  await for (final message in commands) {
    final job = message as _Job;
    try {
      _processPhoto(job);
      results.send((id: job.id, error: null));
    } catch (error) {
      results.send((id: job.id, error: error.toString()));
    }
  }
}

void _processPhoto(_Job job) {
  final decoded = img.decodeImage(File(job.source).readAsBytesSync());
  if (decoded == null) {
    throw const FormatException('The image could not be decoded.');
  }
  final upright = img.bakeOrientation(decoded);
  final full = _fit(upright, photoMaxSide);
  File(job.fullPath).writeAsBytesSync(img.encodeJpg(full, quality: 85));
  final thumbnail = _fit(full, thumbnailMaxSide);
  File(job.thumbPath).writeAsBytesSync(img.encodeJpg(thumbnail, quality: 75));
}

img.Image _fit(img.Image source, int maxSide) {
  if (source.width <= maxSide && source.height <= maxSide) return source;
  return source.width >= source.height
      ? img.copyResize(source, width: maxSide)
      : img.copyResize(source, height: maxSide);
}
