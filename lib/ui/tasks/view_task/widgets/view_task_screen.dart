import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';
import 'package:team12_flutter_juggle/ui/core/ui/custom_navigation_bar.dart';
import 'package:team12_flutter_juggle/ui/core/utils/deadline_format.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/widgets/task_card.dart';
import 'package:team12_flutter_juggle/ui/tasks/view_task/view_models/view_task_viewmodel_provider.dart';

class ViewTaskScreen extends ConsumerWidget {
  const ViewTaskScreen({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(viewTaskViewModelProvider(taskId));
    return Scaffold(
      appBar: AppBar(title: const Text('View task')),
      bottomNavigationBar: const CustomNavigationBar(),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
        data: (data) {
          final task = data.task;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(task.title, style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                task.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _TaskChip(label: _statusLabel(task.status)),
                  if (task.isPriority) ...[
                    const SizedBox(width: 8),
                    _TaskChip(
                      label: 'High priority',
                      color: theme.colorScheme.error,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              _ScheduledCard(
                task: task,
                reminderEnabled: data.reminderEnabled,
                onReminderChanged: (value) => ref
                    .read(viewTaskViewModelProvider(taskId).notifier)
                    .toggleReminder(value),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('ASSIGNED MEMBERS', style: theme.textTheme.labelMedium),
                  const Spacer(),
                  TextButton(onPressed: () {}, child: const Text('EDIT')),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (final assignee in task.assignees)
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Column(
                        children: [
                          CircleAvatar(
                            backgroundColor:
                                theme.colorScheme.secondaryContainer,
                            child: Text(
                              assignee.isEmpty ? '' : assignee[0].toUpperCase(),
                              style: TextStyle(
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(assignee, style: theme.textTheme.labelSmall),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Related tasks / subtasks',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 12),
              for (final related in data.relatedTasks) ...[
                TaskCard(task: related, onTap: () {}),
                const SizedBox(height: 12),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _TaskChip extends StatelessWidget {
  const _TaskChip({required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipColor = color ?? theme.colorScheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: chipColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Symbols.info, size: 16, color: chipColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(color: chipColor),
          ),
        ],
      ),
    );
  }
}

class _ScheduledCard extends StatelessWidget {
  const _ScheduledCard({
    required this.task,
    required this.reminderEnabled,
    required this.onReminderChanged,
  });

  final Task task;
  final bool reminderEnabled;
  final ValueChanged<bool> onReminderChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Symbols.calendar_today),
              const SizedBox(width: 8),
              Text('Scheduled', style: theme.textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Deadline', style: theme.textTheme.bodySmall),
                    Text(deadlineDate(task.deadline)),
                  ],
                ),
              ),
              TextButton(onPressed: () {}, child: const Text('EDIT')),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reminder', style: theme.textTheme.bodySmall),
                    const Text('1 day before'),
                  ],
                ),
              ),
              Switch(value: reminderEnabled, onChanged: onReminderChanged),
            ],
          ),
        ],
      ),
    );
  }
}

String _statusLabel(TaskStatus status) {
  switch (status) {
    case TaskStatus.pending:
      return 'Pending';
    case TaskStatus.inProgress:
      return 'In progress';
    case TaskStatus.done:
      return 'Done';
  }
}
