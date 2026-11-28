import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/gallery/saved_photos_repository_provider.dart';
import 'package:team12_flutter_juggle/domain/models/gallery/saved_photo.dart';
import 'package:team12_flutter_juggle/ui/auth/providers/auth_providers.dart';
import 'package:team12_flutter_juggle/ui/gallery/view_models/gallery_view_model.dart';
import 'package:team12_flutter_juggle/ui/gallery/view_models/photo_import_view_model.dart';

final galleryViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<GalleryViewModel, GalleryState, int>(GalleryViewModel.new);

final savedPhotosProvider = StreamProvider.autoDispose
    .family<List<SavedPhoto>, int>((ref, projectId) {
      final userId = ref.watch(authStateProvider).value?.userId;
      if (userId == null) return Stream.value(const []);
      return ref
          .watch(savedPhotosRepositoryProvider)
          .watchForProject(userId, projectId);
    });

final photoImportViewModelProvider =
    NotifierProvider<PhotoImportViewModel, Map<int, int>>(
      PhotoImportViewModel.new,
    );
