import 'package:team12_flutter_juggle/domain/models/tasks/task_member.dart';

class TaskGroup {
  const TaskGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.pendingCount,
    this.members = const [],
  });

  final int id;
  final String name;
  final String description;
  final int pendingCount;
  final List<TaskMember> members;

  factory TaskGroup.fromJson(Map<String, dynamic> json) {
    return TaskGroup(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      pendingCount: json['pending_task_count'] as int? ?? 0,
      members: [
        for (final user in json['users'] as List<dynamic>? ?? const [])
          TaskMember.fromJson(user as Map<String, dynamic>),
      ],
    );
  }
}
