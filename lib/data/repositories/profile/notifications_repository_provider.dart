import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/profile/notifications_repository.dart';

final notificationsRepositoryProvider = Provider(
  (ref) => NotificationsRepository(),
);
