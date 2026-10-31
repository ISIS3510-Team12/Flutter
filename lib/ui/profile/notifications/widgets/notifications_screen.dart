import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/ui/core/ui/load_error_view.dart';
import 'package:team12_flutter_juggle/ui/core/ui/offline_banner.dart';
import 'package:team12_flutter_juggle/ui/profile/notifications/view_models/notifications_viewmodel_provider.dart';
import 'package:team12_flutter_juggle/ui/profile/notifications/widgets/notification_card.dart';
import 'package:team12_flutter_juggle/ui/telemetry/screen_load_tracker.dart';
import 'package:team12_flutter_juggle/ui/telemetry/screen_names.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsViewModelProvider);
    return ScreenLoadTracker(
      screen: ScreenNames.notifications,
      state: state,
      child: Scaffold(
        appBar: AppBar(title: const Text('Notifications')),
        body: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: state.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => LoadErrorView(
                error: error,
                offlineMessage:
                    "You're offline. Reconnect to load your notifications.",
                genericMessage: "We couldn't load your notifications.",
                onRetry: () => ref.invalidate(notificationsViewModelProvider),
              ),
              data: (read) {
                final notifications = read.value;
                if (notifications.isEmpty) {
                  return const Center(child: Text('No notifications yet'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifications.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return NotificationCard(
                      notification: notifications[index],
                      onDelete: read.fromCache
                          ? null
                          : () => ref
                                .read(notificationsViewModelProvider.notifier)
                                .deleteNotification(notifications[index].id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    ),
    );
  }
}
