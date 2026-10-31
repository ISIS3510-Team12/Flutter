import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/ui/core/utils/lru_cache.dart';

final placeNameCacheProvider = Provider<LruCache<String, String>>(
  (ref) =>
      LruCache<String, String>(maxEntries: 64, ttl: const Duration(days: 7)),
);
