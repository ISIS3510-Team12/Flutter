import 'package:team12_flutter_juggle/domain/models/profile/app_notification.dart';

class NotificationsRepository {
  final List<AppNotification> _notifications = [
    AppNotification(
      id: 'n-1',
      groupName: 'Group dev',
      title: 'Diego finished task "Update Wiki MS6"',
      timestamp: DateTime(2026, 9, 10, 8),
      type: NotificationType.taskFinished,
    ),
    AppNotification(
      id: 'n-2',
      groupName: 'Group dev',
      title: 'Shaiel edited task "App Report"',
      timestamp: DateTime(2026, 9, 9, 19),
      type: NotificationType.taskEdited,
    ),
    AppNotification(
      id: 'n-3',
      groupName: 'Group dev',
      title: 'Manuela created task "Figma Prototype"',
      timestamp: DateTime(2026, 9, 7, 19),
      type: NotificationType.taskCreated,
    ),
  ];

  Future<List<AppNotification>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_notifications);
  }

  Future<void> deleteNotification(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _notifications.removeWhere((n) => n.id == id);
  }
}
