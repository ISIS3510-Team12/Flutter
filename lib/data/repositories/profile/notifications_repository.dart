import 'package:dio/dio.dart';
import 'package:team12_flutter_juggle/domain/models/profile/app_notification.dart';
import 'package:team12_flutter_juggle/domain/models/shared/server_date.dart';

class NotificationsRepository {
  NotificationsRepository(this._dio);

  final Dio _dio;
  final Set<String> _dismissed = {};

  Future<List<AppNotification>> getNotifications() async {
    try {
      final response = await _dio.get<List<dynamic>>('/notifications');
      return [
        for (final json in response.data!)
          ?_toNotification(json as Map<String, dynamic>),
      ].where((notification) => !_dismissed.contains(notification.id)).toList();
    } catch (e) {
      throw Exception('Failed to load notifications: $e');
    }
  }

  Future<void> deleteNotification(String id) async {
    _dismissed.add(id);
  }

  AppNotification? _toNotification(Map<String, dynamic> json) {
    final type = switch (json['event_type'] as String) {
      'created' => NotificationType.taskCreated,
      'updated' => NotificationType.taskEdited,
      'completed' => NotificationType.taskFinished,
      _ => null,
    };
    if (type == null) return null;
    final taskTitle = json['task_title'] as String;
    final action = switch (type) {
      NotificationType.taskCreated => 'was created',
      NotificationType.taskEdited => 'was edited',
      NotificationType.taskFinished => 'was completed',
    };
    return AppNotification(
      id: '${json['id']}',
      groupName: json['group_name'] as String? ?? '',
      title: 'Task "$taskTitle" $action',
      timestamp: parseServerDate(json['occurred_at'] as String),
      type: type,
    );
  }
}
