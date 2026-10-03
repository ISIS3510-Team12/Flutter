import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/profile/notifications_repository.dart';
import 'package:team12_flutter_juggle/ui/core/network/dio_provider.dart';

final notificationsRepositoryProvider = Provider(
  (ref) => NotificationsRepository(ref.watch(dioProvider)),
);
