import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/profile/notifications_repository_provider.dart';
import 'package:team12_flutter_juggle/domain/models/profile/app_notification.dart';

class NotificationsViewModel extends AsyncNotifier<List<AppNotification>> {
  @override
  Future<List<AppNotification>> build() {
    return ref.watch(notificationsRepositoryProvider).getNotifications();
  }

  Future<void> deleteNotification(String id) async {
    final repository = ref.read(notificationsRepositoryProvider);
    final result = await AsyncValue.guard(
      () => repository.deleteNotification(id),
    );
    if (!ref.mounted) return;
    if (result.hasError) {
      state = AsyncError(result.error!, result.stackTrace!);
      return;
    }
    final current = state.value ?? const <AppNotification>[];
    state = AsyncData(current.where((n) => n.id != id).toList());
  }
}
