import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:team12_flutter_juggle/domain/models/auth/app_user.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task_member.dart';
import 'package:team12_flutter_juggle/ui/auth/providers/auth_providers.dart';
import 'package:team12_flutter_juggle/ui/core/ui/custom_navigation_bar.dart';
import 'package:team12_flutter_juggle/ui/core/utils/deadline_format.dart';
import 'package:team12_flutter_juggle/ui/tasks/edit_task/widgets/edit_task_screen.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/widgets/task_card.dart';
import 'package:team12_flutter_juggle/ui/tasks/view_task/view_models/view_task_viewmodel_provider.dart';
import 'package:team12_flutter_juggle/ui/tasks/widgets/task_photo_viewer.dart';

class ViewTaskScreen extends ConsumerWidget {
  const ViewTaskScreen({super.key, required this.taskId});

  final String taskId;

  void _openEditTask(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => EditTaskScreen(taskId: taskId)));
  }

  Future<void> _editDeadline(
    BuildContext context,
    WidgetRef ref,
    DateTime current,
  ) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: current.isBefore(now) ? current : now,
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (picked == null || !context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (time == null) return;
    await ref
        .read(viewTaskViewModelProvider(taskId).notifier)
        .updateDeadline(
          DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          ),
        );
  }

  void _openPhoto(BuildContext context, Uint8List photo) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => TaskPhotoViewer(photo: photo)));
  }

  Future<void> _deleteTask(BuildContext context, WidgetRef ref) async {
    await ref.read(viewTaskViewModelProvider(taskId).notifier).deleteTask();
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(viewTaskViewModelProvider(taskId));
    final me = ref.watch(currentUserProvider).value;
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
            ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
        data: (data) {
          final task = data.task;
          final assignees = _assignedMembers(task, me);
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
                onEditDeadline: () =>
                    _editDeadline(context, ref, task.deadline),
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
              if (assignees.isEmpty)
                Text(
                  'No assigned members',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                )
              else
                ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context)
                      .copyWith(scrollbars: false),
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
                                  backgroundColor:
                                      theme.colorScheme.secondaryContainer,
                                  child: Text(
                                    assignee.initial,
                                    style: TextStyle(
                                      color: theme
                                          .colorScheme
                                          .onSecondaryContainer,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  assignee.name,
                                  style: theme.textTheme.labelSmall,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              if (data.photo != null) ...[
                const SizedBox(height: 24),
                Text('EVIDENCES', style: theme.textTheme.labelMedium),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _openPhoto(context, data.photo!),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      data.photo!,
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Text(
                'Related tasks / subtasks',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 12),
              if (data.relatedTasks.isEmpty)
                Text(
                  'No related tasks',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              for (final related in data.relatedTasks) ...[
                TaskCard(
                  task: related,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ViewTaskScreen(taskId: related.id),
                    ),
                  ),
                ),
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
    required this.onEditDeadline,
  });

  final Task task;
  final bool reminderEnabled;
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
                    Text(
                      '${deadlineDate(task.deadline)} · ${timeOfDayLabel(TimeOfDay.fromDateTime(task.deadline))}',
                    ),
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
  });

  final VoidCallback onMarkComplete;
  final VoidCallback onEditTask;
  final VoidCallback onDeleteTask;
  final VoidCallback onAskForHelp;
  final VoidCallback onMarkStarted;

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
    final scheme = theme.colorScheme;

    if (!_expanded) {
      return FloatingActionButton.extended(
        backgroundColor: scheme.onPrimaryContainer,
        foregroundColor: scheme.primaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () => setState(() => _expanded = true),
        icon: const Icon(Symbols.stars, fill: 1),
        label: Text('Task Actions', style: _fabLabelStyle(context)),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _ActionPill(
          icon: Symbols.check,
          label: 'Mark as complete',
          onPressed: () => _run(widget.onMarkComplete),
        ),
        const SizedBox(height: 4),
        _ActionPill(
          icon: Symbols.edit,
          label: 'Edit Task',
          onPressed: () => _run(widget.onEditTask),
        ),
        const SizedBox(height: 4),
        _ActionPill(
          icon: Symbols.delete,
          label: 'Delete Task',
          onPressed: () => _run(widget.onDeleteTask),
        ),
        const SizedBox(height: 4),
        _ActionPill(
          icon: Symbols.chat,
          label: 'Ask for help',
          onPressed: () => _run(widget.onAskForHelp),
        ),
        const SizedBox(height: 4),
        _ActionPill(
          icon: Symbols.star,
          label: 'Mark as started',
          onPressed: () => _run(widget.onMarkStarted),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          backgroundColor: scheme.primaryContainer,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          onPressed: () => setState(() => _expanded = false),
          child: const Icon(Symbols.close, size: 20),
        ),
      ],
    );
  }
}

TextStyle _fabLabelStyle(BuildContext context) {
  return Theme.of(context).textTheme.labelLarge!
      .copyWith(fontSize: 16, height: 24 / 16, letterSpacing: 0.15);
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
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(28);
    return Material(
      color: scheme.onPrimaryContainer,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24, color: scheme.primaryContainer),
              const SizedBox(width: 8),
              Text(
                label,
                style: _fabLabelStyle(context)
                    .copyWith(color: scheme.primaryContainer),
              ),
            ],
          ),
        ),
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
