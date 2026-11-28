import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/gallery/gallery_repository.dart';
import 'package:team12_flutter_juggle/ui/core/network/dio_provider.dart';

final galleryRepositoryProvider = Provider<GalleryRepository>(
  (ref) => GalleryRepository(ref.watch(dioProvider)),
);
