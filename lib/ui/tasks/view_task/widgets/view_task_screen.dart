import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';
import 'package:team12_flutter_juggle/ui/core/ui/custom_navigation_bar.dart';
import 'package:team12_flutter_juggle/ui/core/utils/deadline_format.dart';
import 'package:team12_flutter_juggle/ui/tasks/edit_task/widgets/edit_task_screen.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/widgets/task_card.dart';
import 'package:team12_flutter_juggle/ui/tasks/view_task/view_models/view_task_viewmodel_provider.dart';

class ViewTaskScreen extends ConsumerWidget {
  const ViewTaskScreen({super.key, required this.taskId});

  final String taskId;

  void _openEditTask(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => EditTaskScreen(taskId: taskId)));
  }

  Future<void> _assignTimeSlot(BuildContext context, WidgetRef ref) async {
    final label = await _pickTimeSlot(context);
    if (label != null) {
      ref.read(viewTaskViewModelProvider(taskId).notifier).setTimeSlot(label);
    }
  }

  Future<void> _deleteTask(BuildContext context, WidgetRef ref) async {
    await ref.read(viewTaskViewModelProvider(taskId).notifier).deleteTask();
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(viewTaskViewModelProvider(taskId));
    return Scaffold(
      appBar: AppBar(title: const Text('View task')),
      bottomNavigationBar: const CustomNavigationBar(),
      floatingActionButton: state.value == null
          ? null
          : _TaskActionsFab(
              onMarkComplete: () => ref
                  .read(viewTaskViewModelProvider(taskId).notifier)
                  .markComplete(),
              onEditTask: () => _openEditTask(context),
              onDeleteTask: () => _deleteTask(context, ref),
              onAskForHelp: () => ref
                  .read(viewTaskViewModelProvider(taskId).notifier)
                  .toggleNeedsHelp(),
              onMarkStarted: () => ref
                  .read(viewTaskViewModelProvider(taskId).notifier)
                  .markStarted(),
              onAssignTimeSlot: () => _assignTimeSlot(context, ref),
            ),
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
                timeSlotLabel: data.timeSlotLabel,
                onReminderChanged: (value) => ref
                    .read(viewTaskViewModelProvider(taskId).notifier)
                    .toggleReminder(value),
                onEditDeadline: () => _openEditTask(context),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('ASSIGNED MEMBERS', style: theme.textTheme.labelMedium),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _openEditTask(context),
                    child: const Text('EDIT'),
                  ),
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
              const SizedBox(height: 96),
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
    required this.timeSlotLabel,
    required this.onReminderChanged,
    required this.onEditDeadline,
  });

  final Task task;
  final bool reminderEnabled;
  final String? timeSlotLabel;
  final ValueChanged<bool> onReminderChanged;
  final VoidCallback onEditDeadline;

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
              TextButton(onPressed: onEditDeadline, child: const Text('EDIT')),
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
          if (timeSlotLabel != null) ...[
            const Divider(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Time slot', style: theme.textTheme.bodySmall),
                Text(timeSlotLabel!),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TaskActionsFab extends StatefulWidget {
  const _TaskActionsFab({
    required this.onMarkComplete,
    required this.onEditTask,
    required this.onDeleteTask,
    required this.onAskForHelp,
    required this.onMarkStarted,
    required this.onAssignTimeSlot,
  });

  final VoidCallback onMarkComplete;
  final VoidCallback onEditTask;
  final VoidCallback onDeleteTask;
  final VoidCallback onAskForHelp;
  final VoidCallback onMarkStarted;
  final VoidCallback onAssignTimeSlot;

  @override
  State<_TaskActionsFab> createState() => _TaskActionsFabState();
}

class _TaskActionsFabState extends State<_TaskActionsFab> {
  bool _expanded = false;

  void _run(VoidCallback action) {
    setState(() => _expanded = false);
    action();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_expanded) ...[
          _ActionPill(
            icon: Symbols.check,
            label: 'Mark as complete',
            onPressed: () => _run(widget.onMarkComplete),
          ),
          const SizedBox(height: 8),
          _ActionPill(
            icon: Symbols.edit,
            label: 'Edit Task',
            onPressed: () => _run(widget.onEditTask),
          ),
          const SizedBox(height: 8),
          _ActionPill(
            icon: Symbols.delete,
            label: 'Delete Task',
            onPressed: () => _run(widget.onDeleteTask),
          ),
          const SizedBox(height: 8),
          _ActionPill(
            icon: Symbols.chat,
            label: 'Ask for help',
            onPressed: () => _run(widget.onAskForHelp),
          ),
          const SizedBox(height: 8),
          _ActionPill(
            icon: Symbols.star,
            label: 'Mark as started',
            onPressed: () => _run(widget.onMarkStarted),
          ),
          const SizedBox(height: 8),
          _ActionPill(
            icon: Symbols.schedule,
            label: 'Assign a time slot',
            onPressed: () => _run(widget.onAssignTimeSlot),
          ),
          const SizedBox(height: 12),
        ],
        FloatingActionButton(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          onPressed: () => setState(() => _expanded = !_expanded),
          child: Icon(_expanded ? Symbols.close : Symbols.star),
        ),
      ],
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FilledButton.tonalIcon(
      style: FilledButton.styleFrom(
        backgroundColor: theme.colorScheme.primaryFixed,
        foregroundColor: theme.colorScheme.onPrimaryFixed,
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

Future<String?> _pickTimeSlot(BuildContext context) async {
  final date = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime.now().add(const Duration(days: 365)),
  );
  if (date == null || !context.mounted) return null;

  final start = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
  );
  if (start == null || !context.mounted) return null;

  final end = await showTimePicker(
    context: context,
    initialTime: start.replacing(hour: (start.hour + 1) % 24),
  );
  if (end == null) return null;

  return '${deadlineDate(date)} ${timeOfDayLabel(start)} - ${timeOfDayLabel(end)}';
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
