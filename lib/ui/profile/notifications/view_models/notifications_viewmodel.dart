import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/profile/notifications_repository_provider.dart';
import 'package:team12_flutter_juggle/domain/models/profile/app_notification.dart';

class NotificationsViewModel extends AsyncNotifier<List<AppNotification>> {
  @override
  Future<List<AppNotification>> build() {
    return ref.read(notificationsRepositoryProvider).getNotifications();
  }

  Future<void> deleteNotification(String id) async {
    await ref.read(notificationsRepositoryProvider).deleteNotification(id);
    final current = state.value ?? const [];
    state = AsyncData(current.where((n) => n.id != id).toList());
  }
}
