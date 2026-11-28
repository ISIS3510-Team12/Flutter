import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/local/gallery/gallery_database.dart';
import 'package:team12_flutter_juggle/data/repositories/gallery/saved_photos_repository.dart';

final galleryDatabaseProvider = Provider<GalleryDatabase>((ref) {
  final database = GalleryDatabase();
  ref.onDispose(database.close);
  return database;
});

final savedPhotosRepositoryProvider = Provider<SavedPhotosRepository>(
  (ref) => SavedPhotosRepository(ref.watch(galleryDatabaseProvider)),
);
