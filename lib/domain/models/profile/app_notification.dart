enum NotificationType { taskFinished, taskEdited, taskCreated }

class AppNotification {
  const AppNotification({
    required this.id,
    required this.groupName,
    required this.title,
    required this.timestamp,
    required this.type,
  });

  final String id;
  final String groupName;
  final String title;
  final DateTime timestamp;
  final NotificationType type;
}
