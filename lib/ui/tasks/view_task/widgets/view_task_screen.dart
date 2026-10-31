import 'package:flutter/material.dart';
import 'package:team12_flutter_juggle/ui/telemetry/feature_names.dart';
import 'package:team12_flutter_juggle/ui/telemetry/feature_session_mixin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:team12_flutter_juggle/ui/auth/providers/auth_providers.dart';
import 'package:team12_flutter_juggle/ui/core/routing/routes.dart';
import 'package:team12_flutter_juggle/ui/core/ui/custom_navigation_bar.dart';
import 'package:team12_flutter_juggle/ui/core/ui/load_error_view.dart';
import 'package:team12_flutter_juggle/ui/core/ui/offline_banner.dart';
import 'package:team12_flutter_juggle/ui/core/network/connectivity_provider.dart';
import 'package:team12_flutter_juggle/ui/core/utils/network_exceptions.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:team12_flutter_juggle/ui/tasks/view_task/view_models/view_task_viewmodel.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/widgets/task_card.dart';
import 'package:team12_flutter_juggle/ui/tasks/view_task/view_models/view_task_viewmodel_provider.dart';
import 'package:team12_flutter_juggle/ui/tasks/view_task/widgets/assigned_members_list.dart';
import 'package:team12_flutter_juggle/ui/tasks/view_task/widgets/scheduled_card.dart';
import 'package:team12_flutter_juggle/ui/tasks/view_task/widgets/task_actions_fab.dart';
import 'package:team12_flutter_juggle/ui/tasks/view_task/widgets/task_chip.dart';
import 'package:team12_flutter_juggle/ui/telemetry/screen_load_tracker.dart';
import 'package:team12_flutter_juggle/ui/telemetry/screen_names.dart';

class ViewTaskScreen extends ConsumerStatefulWidget {
  const ViewTaskScreen({super.key, required this.taskId});

  final String taskId;

  @override
  ConsumerState<ViewTaskScreen> createState() => _ViewTaskScreenState();
}

class _ViewTaskScreenState extends ConsumerState<ViewTaskScreen>
    with FeatureSessionMixin<ViewTaskScreen> {
  String get taskId => widget.taskId;

  @override
  String get featureName => FeatureNames.viewTask;

  void _openEditTask(BuildContext context) {
    markFeatureCompleted();
    context.push(Routes.editTaskPath(taskId));
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _report(BuildContext context, TaskActionResult result, String action) {
    if (!context.mounted) return;
    final message = switch (result) {
      TaskActionResult.offline => offlineActionMessage(action),
      TaskActionResult.failed =>
        "We couldn't update the task. It was left as it was.",
      TaskActionResult.done => null,
    };
    if (message != null) _showMessage(context, message);
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
    markFeatureCompleted();
    final result = await ref
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
    if (context.mounted) {
      _report(context, result, "change this task's deadline");
    }
  }

  void _openPhoto(BuildContext context) {
    markFeatureCompleted();
    context.push(Routes.taskPhotoPath(taskId));
  }

  Future<void> _deleteTask(BuildContext context, WidgetRef ref) async {
    markFeatureCompleted();
    final result = await ref
        .read(viewTaskViewModelProvider(taskId).notifier)
        .deleteTask();
    if (!context.mounted) return;
    switch (result) {
      case TaskActionResult.done:
        context.pop();
      case TaskActionResult.offline:
        _showMessage(context, offlineActionMessage('delete this task'));
      case TaskActionResult.failed:
        _showMessage(context, "We couldn't delete the task. Try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(viewTaskViewModelProvider(taskId));
    final me = ref.watch(currentUserProvider).value;
    final online = ref.watch(isOnlineProvider);
    ViewTaskViewModel notifier() =>
        ref.read(viewTaskViewModelProvider(taskId).notifier);
    void unavailable(String action) =>
        _showMessage(context, offlineActionMessage(action));
    Future<void> run(
      Future<TaskActionResult> Function() operation,
      String action,
    ) async {
      markFeatureCompleted();
      final result = await operation();
      if (context.mounted) _report(context, result, action);
    }

    return ScreenLoadTracker(
      screen: ScreenNames.viewTask,
      state: state,
      child: Scaffold(
        appBar: AppBar(title: const Text('View task')),
        bottomNavigationBar: const CustomNavigationBar(),
        floatingActionButtonAnimator: FloatingActionButtonAnimator.noAnimation,
        floatingActionButton: state.value == null
            ? null
            : TaskActionsFab(
                enabled: online,
                onUnavailable: unavailable,
                onMarkComplete: () =>
                    run(() => notifier().markComplete(), 'complete this task'),
                onEditTask: () => _openEditTask(context),
                onDeleteTask: () => _deleteTask(context, ref),
                onAskForHelp: () => run(
                  () => notifier().toggleNeedsHelp(),
                  'ask for help on this task',
                ),
                onMarkStarted: () =>
                    run(() => notifier().markStarted(), 'start this task'),
              ),
        body: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: state.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => LoadErrorView(
                  error: error,
                  offlineMessage:
                      "You're offline. Reconnect to open this task.",
                  genericMessage: "We couldn't load this task.",
                  onRetry: () =>
                      ref.invalidate(viewTaskViewModelProvider(taskId)),
                ),
                data: (data) {
                  final task = data.task;
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (!online) ...[
                        Text(
                          "You're offline. Reconnect to make changes.",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
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
                        enabled: online,
                        onUnavailable: unavailable,
                        onReminderChanged: (value) {
                          markFeatureCompleted();
                          _report(
                            context,
                            notifier().toggleReminder(value),
                            "change this task's reminder",
                          );
                        },
                        onEditDeadline: () =>
                            _editDeadline(context, ref, task.deadline),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            'ASSIGNED MEMBERS',
                            style: theme.textTheme.labelMedium,
                          ),
                          const Spacer(),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: online
                                ? null
                                : () => unavailable("edit this task's members"),
                            child: TextButton(
                              onPressed: online
                                  ? () => _openEditTask(context)
                                  : null,
                              child: const Text('EDIT'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      AssignedMembersList(task: task, me: me),
                      if (data.photo == null && data.photoUnavailable) ...[
                        const SizedBox(height: 24),
                        Text('EVIDENCES', style: theme.textTheme.labelMedium),
                        const SizedBox(height: 8),
                        Container(
                          height: 120,
                          width: double.infinity,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Symbols.image_not_supported,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                data.fromCache
                                    ? 'Photo not available offline'
                                    : 'The photo could not be loaded',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                          onTap: () {
                            markFeatureCompleted();
                            context.push(Routes.taskPath(related.id));
                          },
                        ),
                        const SizedBox(height: 12),
                      ],
                      const SizedBox(height: 96),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
