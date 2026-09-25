import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/ui/profile/notifications/view_models/notifications_viewmodel_provider.dart';
import 'package:team12_flutter_juggle/ui/profile/notifications/widgets/notification_card.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsViewModelProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
        data: (notifications) {
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
                onDelete: () => ref
                    .read(notificationsViewModelProvider.notifier)
                    .deleteNotification(notifications[index].id),
              );
            },
          );
        },
      ),
    );
  }
}
