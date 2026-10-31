import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/db/daos/notifications/notifications_cache_dao_provider.dart';
import 'package:team12_flutter_juggle/data/repositories/profile/notifications_repository_provider.dart';
import 'package:team12_flutter_juggle/domain/models/profile/app_notification.dart';
import 'package:team12_flutter_juggle/ui/auth/providers/auth_providers.dart';
import 'package:team12_flutter_juggle/ui/core/network/connectivity_provider.dart';
import 'package:team12_flutter_juggle/ui/core/network/network_first.dart';

class NotificationsViewModel
    extends AsyncNotifier<CacheRead<List<AppNotification>>> {
  @override
  Future<CacheRead<List<AppNotification>>> build() async {
    final user = await ref.watch(currentUserProvider.future);
    if (user == null) throw StateError('User is not logged in');
    final cache = ref.read(notificationsCacheDaoProvider);
    return networkFirst(
      isOnline: ref.watch(isOnlineProvider),
      fetch: ref.watch(notificationsRepositoryProvider).getNotifications,
      save: (items) => cache.replaceForUser(user.userId, items),
      fallback: () => cache.findForUser(user.userId),
    );
  }

  Future<void> deleteNotification(String id) async {
    final current = state.value;
    if (current == null || current.fromCache) return;
    final repository = ref.read(notificationsRepositoryProvider);
    final result = await AsyncValue.guard(
      () => repository.deleteNotification(id),
    );
    if (!ref.mounted) return;
    if (result.hasError) {
      state = AsyncError(result.error!, result.stackTrace!);
      return;
    }
    state = AsyncData((
      value: current.value.where((n) => n.id != id).toList(),
      fromCache: false,
    ));
  }
}
