import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:team12_flutter_juggle/ui/core/utils/lru_cache.dart';

final recentPlacesCacheProvider = Provider<LruCache<String, LatLng>>(
  (ref) =>
      LruCache<String, LatLng>(maxEntries: 5, ttl: const Duration(days: 7)),
);
