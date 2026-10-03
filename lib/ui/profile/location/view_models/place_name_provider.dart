import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:team12_flutter_juggle/data/repositories/location/device_location_repository_provider.dart';

final placeNameProvider = FutureProvider.autoDispose.family<String?, LatLng>(
  (ref, point) => ref.watch(deviceLocationRepositoryProvider).placeName(point),
);
