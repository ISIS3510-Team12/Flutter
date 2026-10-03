import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/location/location_repository.dart';
import 'package:team12_flutter_juggle/ui/core/network/dio_provider.dart';

final locationRepositoryProvider = Provider(
  (ref) => LocationRepository(ref.watch(dioProvider)),
);
