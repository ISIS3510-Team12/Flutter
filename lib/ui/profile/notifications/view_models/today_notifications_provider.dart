import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/profile/notifications_repository_provider.dart';
import 'package:team12_flutter_juggle/domain/models/profile/app_notification.dart';

final todayNotificationsProvider =
    FutureProvider.autoDispose<List<AppNotification>>((ref) async {
      final notifications = await ref
          .watch(notificationsRepositoryProvider)
          .getNotifications();
      final now = DateTime.now();
      return notifications.where((notification) {
        return notification.timestamp.year == now.year &&
            notification.timestamp.month == now.month &&
            notification.timestamp.day == now.day;
      }).toList();
    });
