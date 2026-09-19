import 'package:team12_flutter_juggle/domain/models/profile/app_notification.dart';

// TODO: replace with real HTTP calls to the backend
class NotificationsApiClient {
  final List<AppNotification> _remoteNotifications = [
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

  Future<List<AppNotification>> fetchNotifications() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_remoteNotifications);
  }

  Future<void> deleteNotification(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _remoteNotifications.removeWhere((n) => n.id == id);
  }
}
