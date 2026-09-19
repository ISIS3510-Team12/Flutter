import 'package:flutter/material.dart';
import 'package:team12_flutter_juggle/ui/profile/notifications/view_models/notifications_viewmodel.dart';
import 'package:team12_flutter_juggle/ui/profile/notifications/widgets/notification_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key, required this.viewModel});

  final NotificationsViewModel viewModel;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          if (widget.viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final notifications = widget.viewModel.notifications;
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
                onDelete: () => widget.viewModel.deleteNotification(
                  notifications[index].id,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
