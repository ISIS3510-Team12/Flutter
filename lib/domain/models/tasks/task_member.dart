import 'package:team12_flutter_juggle/domain/models/auth/app_user.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task_group.dart';

class TaskMember {
  const TaskMember({
    required this.id,
    required this.name,
    required this.initial,
  });

  final String id;
  final String name;
  final String initial;

  factory TaskMember.fromJson(Map<String, dynamic> json) {
    final firstName = json['first_name'] as String? ?? '';
    return TaskMember(
      id: json['user_id'] as String,
      name: firstName,
      initial: firstName.isEmpty ? '' : firstName[0].toUpperCase(),
    );
  }
}

List<TaskMember> membersWithYou(TaskGroup? group, AppUser me) {
  return [
    TaskMember(id: me.userId, name: 'You', initial: me.initial),
    ...?group?.members.where((member) => member.id != me.userId),
  ];
}
