import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/cache/gallery_cache_manager.dart';
import 'package:team12_flutter_juggle/data/db/daos/gallery/project_photos_cache_dao_provider.dart';
import 'package:team12_flutter_juggle/data/db/daos/projects/projects_cache_dao_provider.dart';
import 'package:team12_flutter_juggle/data/repositories/gallery/gallery_repository.dart';
import 'package:team12_flutter_juggle/data/repositories/gallery/gallery_repository_provider.dart';
import 'package:team12_flutter_juggle/data/repositories/gallery/saved_photos_repository_provider.dart';
import 'package:team12_flutter_juggle/domain/models/gallery/project_photo.dart';
import 'package:team12_flutter_juggle/ui/auth/providers/auth_providers.dart';
import 'package:team12_flutter_juggle/ui/core/network/connectivity_provider.dart';
import 'package:team12_flutter_juggle/ui/core/network/network_first.dart';
import 'package:team12_flutter_juggle/ui/core/utils/network_exceptions.dart';

class GalleryState {
  const GalleryState({
    required this.userId,
    required this.projectName,
    required this.photos,
    this.fromCache = false,
    this.listAvailable = true,
  });

  final String userId;
  final String projectName;
  final List<ProjectPhoto> photos;
  final bool fromCache;
  final bool listAvailable;

  GalleryState without(int photoId) => GalleryState(
    userId: userId,
    projectName: projectName,
    photos: [
      for (final photo in photos)
        if (photo.id != photoId) photo,
    ],
    fromCache: fromCache,
    listAvailable: listAvailable,
  );
}

class GalleryViewModel extends AsyncNotifier<GalleryState> {
  GalleryViewModel(this.projectId);

  final int projectId;

  @override
  Future<GalleryState> build() async {
    final user = (await ref.watch(currentUserProvider.future))!;
    final isOnline = ref.watch(isOnlineProvider);
    final repository = ref.watch(galleryRepositoryProvider);
    final cache = ref.watch(projectPhotosCacheDaoProvider);
    final project = await ref
        .watch(projectsCacheDaoProvider)
        .findProject(user.userId, projectId);
    final projectName = project?.name ?? 'Project';

    try {
      final read = await networkFirst<List<ProjectPhoto>>(
        isOnline: isOnline,
        fetch: () => repository.getPhotos(projectId),
        save: (photos) =>
            cache.replaceForProject(user.userId, projectId, photos),
        fallback: () => cache.findForProject(user.userId, projectId),
      );
      return GalleryState(
        userId: user.userId,
        projectName: projectName,
        photos: read.value,
        fromCache: read.fromCache,
      );
    } catch (error) {
      if (!isOfflineFailure(error)) rethrow;
      return GalleryState(
        userId: user.userId,
        projectName: projectName,
        photos: const [],
        listAvailable: false,
      );
    }
  }

  Future<void> saveToDevice(ProjectPhoto photo) async {
    final current = state.value;
    if (current == null) return;
    final saved = ref.read(savedPhotosRepositoryProvider);
    final file = await ref
        .read(galleryCacheManagerProvider)
        .getSingleFile(
          projectPhotoPath(projectId, photo.id),
          key: galleryImageCacheKey(photo.id),
        );
    await saved.save(
      userId: current.userId,
      projectName: current.projectName,
      photo: photo,
      source: file,
    );
  }

  Future<void> removeFromDevice(int photoId) async {
    final current = state.value;
    if (current == null) return;
    await ref
        .read(savedPhotosRepositoryProvider)
        .remove(current.userId, photoId);
  }

  Future<void> deletePhoto(int photoId) async {
    final current = state.value;
    if (current == null) return;
    if (!ref.read(isOnlineProvider)) throw const NetworkUnavailableException();

    final repository = ref.read(galleryRepositoryProvider);
    final cache = ref.read(projectPhotosCacheDaoProvider);
    final images = ref.read(galleryCacheManagerProvider);
    await repository.deletePhoto(projectId, photoId);
    await saveQuietly(() => cache.remove(current.userId, photoId));
    await saveQuietly(() async {
      await images.removeFile(galleryImageCacheKey(photoId));
      await images.removeFile(galleryImageCacheKey(photoId, thumbnail: true));
    });
    if (!ref.mounted) return;
    state = AsyncData((state.value ?? current).without(photoId));
  }
}
