import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/location/device_location_repository.dart';

final deviceLocationRepositoryProvider = Provider(
  (ref) => DeviceLocationRepository(),
);
