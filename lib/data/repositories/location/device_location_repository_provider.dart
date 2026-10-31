import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/location/place_name_cache_provider.dart';
import 'package:team12_flutter_juggle/data/repositories/location/device_location_repository.dart';

final deviceLocationRepositoryProvider = Provider(
  (ref) => DeviceLocationRepository(
    placeNameCache: ref.watch(placeNameCacheProvider),
  ),
);
