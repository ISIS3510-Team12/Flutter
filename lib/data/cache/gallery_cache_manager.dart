import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/cache/dio_file_service.dart';
import 'package:team12_flutter_juggle/ui/core/network/dio_provider.dart';

const galleryCacheKey = 'juggle_gallery';
const galleryCacheStalePeriod = Duration(days: 7);
const galleryCacheMaxObjects = 200;

String galleryImageCacheKey(int photoId, {bool thumbnail = false}) {
  return 'photo-$photoId-${thumbnail ? 'thumb' : 'full'}';
}

final galleryCacheManagerProvider = Provider<BaseCacheManager>(
  (ref) => CacheManager(
    Config(
      galleryCacheKey,
      stalePeriod: galleryCacheStalePeriod,
      maxNrOfCacheObjects: galleryCacheMaxObjects,
      fileService: DioFileService(
        ref.watch(dioProvider),
        validity: galleryCacheStalePeriod,
      ),
    ),
  ),
);
