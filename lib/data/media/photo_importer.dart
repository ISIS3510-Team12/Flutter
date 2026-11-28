import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:team12_flutter_juggle/data/media/photo_processing_worker.dart';

const maxUploadBytes = 5 * 1024 * 1024;

typedef ImportedPhoto = ({String path, String? thumbnailPath});

class PhotoImporter {
  PhotoImporter(this._worker, {Future<Directory> Function()? supportDirectory})
    : _supportDirectory = supportDirectory ?? getApplicationSupportDirectory;

  final PhotoProcessingWorker _worker;
  final Future<Directory> Function() _supportDirectory;

  Future<ImportedPhoto> import(String source, String uploadId) async {
    final base = await _supportDirectory();
    final separator = Platform.pathSeparator;
    final directory = Directory('${base.path}${separator}outbox_photos');
    await directory.create(recursive: true);
    final target = '${directory.path}$separator$uploadId';
    final fullPath = '$target.jpg';
    final thumbPath = '${target}_thumb.jpg';

    try {
      await _worker.process(
        source: source,
        fullPath: fullPath,
        thumbPath: thumbPath,
      );
      await _checkSize(fullPath);
      return (path: fullPath, thumbnailPath: thumbPath);
    } on PhotoProcessingException {
      final extension = source.split('.').last.toLowerCase();
      if (extension != 'heic' && extension != 'heif') rethrow;
      await _checkSize(source);
      final copy = await File(source).copy('$target.$extension');
      return (path: copy.path, thumbnailPath: null);
    }
  }

  Future<void> _checkSize(String path) async {
    if (await File(path).length() > maxUploadBytes) {
      throw const PhotoProcessingException(
        'The photo is too large. The maximum size is 5 MB.',
      );
    }
  }
}
