import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:team12_flutter_juggle/ui/auth/providers/auth_providers.dart';
import 'package:team12_flutter_juggle/ui/core/routing/routes.dart';
import 'package:team12_flutter_juggle/ui/core/ui/custom_navigation_bar.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/widgets/task_card.dart';
import 'package:team12_flutter_juggle/ui/tasks/view_task/view_models/view_task_viewmodel_provider.dart';
import 'package:team12_flutter_juggle/ui/tasks/view_task/widgets/assigned_members_list.dart';
import 'package:team12_flutter_juggle/ui/tasks/view_task/widgets/scheduled_card.dart';
import 'package:team12_flutter_juggle/ui/tasks/view_task/widgets/task_actions_fab.dart';
import 'package:team12_flutter_juggle/ui/tasks/view_task/widgets/task_chip.dart';
import 'package:team12_flutter_juggle/ui/telemetry/screen_load_tracker.dart';
import 'package:team12_flutter_juggle/ui/telemetry/screen_names.dart';

class ViewTaskScreen extends ConsumerWidget {
  const ViewTaskScreen({super.key, required this.taskId});

  final String taskId;

  void _openEditTask(BuildContext context) {
    context.push(Routes.editTaskPath(taskId));
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

  void _openPhoto(BuildContext context) {
    context.push(Routes.taskPhotoPath(taskId));
  }

  Future<void> _deleteTask(BuildContext context, WidgetRef ref) async {
    await ref.read(viewTaskViewModelProvider(taskId).notifier).deleteTask();
    if (context.mounted) context.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(viewTaskViewModelProvider(taskId));
    final me = ref.watch(currentUserProvider).value;
    return ScreenLoadTracker(
      screen: ScreenNames.viewTask,
      state: state,
      child: Scaffold(
      appBar: AppBar(title: const Text('View task')),
      bottomNavigationBar: const CustomNavigationBar(),
      floatingActionButton: state.value == null
          ? null
          : TaskActionsFab(
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
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  TaskChip(label: taskStatusLabel(task.status)),
                  if (task.isPriority)
                    TaskChip(
                      label: 'High priority',
                      color: theme.colorScheme.error,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              ScheduledCard(
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
              AssignedMembersList(task: task, me: me),
              if (data.photo != null) ...[
                const SizedBox(height: 24),
                Text('EVIDENCES', style: theme.textTheme.labelMedium),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _openPhoto(context),
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
                  onTap: () => context.push(Routes.taskPath(related.id)),
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 96),
            ],
          );
        },
      ),
    ),
    );
  }
}
