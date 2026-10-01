import 'package:flutter/material.dart';
import 'package:team12_flutter_juggle/domain/models/auth/app_user.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task_member.dart';

class AssignedMembersList extends StatelessWidget {
  const AssignedMembersList({super.key, required this.task, required this.me});

  final Task task;
  final AppUser? me;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final assignees = _assignedMembers(task, me);
    if (assignees.isEmpty) {
      return Text(
        'No assigned members',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final assignee in assignees)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Column(
                  children: [
                    CircleAvatar(
                      backgroundColor: theme.colorScheme.secondaryContainer,
                      child: Text(
                        assignee.initial,
                        style: TextStyle(
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(assignee.name, style: theme.textTheme.labelSmall),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

List<TaskMember> _assignedMembers(Task task, AppUser? me) {
  final members = <TaskMember>[];
  for (var i = 0; i < task.assignees.length; i++) {
    final name = task.assignees[i];
    final id = i < task.assigneeIds.length ? task.assigneeIds[i] : '';
    final isMe = me != null && id == me.userId;
    members.add(
      TaskMember(
        id: id,
        name: isMe ? 'You' : name,
        initial: isMe
            ? me.initial
            : (name.isEmpty ? '' : name[0].toUpperCase()),
      ),
    );
  }
  members.sort((a, b) => (b.name == 'You' ? 1 : 0) - (a.name == 'You' ? 1 : 0));
  return members;
}
