import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:team12_flutter_juggle/ui/core/network/connectivity_provider.dart';
import 'package:team12_flutter_juggle/ui/core/routing/routes.dart';
import 'package:team12_flutter_juggle/ui/core/themes/app_typography.dart';
import 'package:team12_flutter_juggle/ui/core/ui/custom_app_bar.dart';
import 'package:team12_flutter_juggle/data/local/pending_op.dart';
import 'package:team12_flutter_juggle/ui/core/sync/sync_providers.dart';
import 'package:team12_flutter_juggle/ui/core/ui/custom_navigation_bar.dart';
import 'package:team12_flutter_juggle/ui/core/ui/load_error_view.dart';
import 'package:team12_flutter_juggle/ui/core/ui/offline_banner.dart';
import 'package:team12_flutter_juggle/ui/core/ui/pending_sync_card.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/view_models/task_list_entry.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/view_models/tasks_view_mode_provider.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/view_models/tasks_viewmodel.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/view_models/tasks_viewmodel_provider.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/widgets/group_drawer.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/widgets/task_board.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/widgets/task_card.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/widgets/tasks_view_toggle.dart';
import 'package:team12_flutter_juggle/ui/tasks/widgets/task_form_widgets.dart';
import 'package:team12_flutter_juggle/ui/telemetry/screen_load_tracker.dart';
import 'package:team12_flutter_juggle/ui/telemetry/screen_names.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  void _openCreateTask(BuildContext context) {
    context.push(Routes.createTask);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(tasksViewModelProvider);
    final mode = ref.watch(tasksViewModeProvider);
    final showBoard = mode == TasksViewMode.board;
    return ScreenLoadTracker(
      screen: ScreenNames.tasks,
      state: state,
      child: Scaffold(
        appBar: const CustomAppBar(),
        drawer: const GroupDrawer(),
        bottomNavigationBar: const CustomNavigationBar(),
        floatingActionButton: (state.value?.groups.isNotEmpty ?? false)
            ? FloatingActionButton.extended(
                backgroundColor: theme.colorScheme.primaryFixed,
                foregroundColor: theme.colorScheme.onPrimaryFixed,
                onPressed: () => _openCreateTask(context),
                icon: const Icon(Symbols.add),
                label: const Text('Create task'),
              )
            : null,
        body: Column(
          children: [
            if (!showBoard || !state.hasValue) const OfflineBanner(),
            Expanded(
              child: state.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => LoadErrorView(
                  error: error,
                  offlineMessage:
                      "You're offline. Reconnect to load your tasks.",
                  genericMessage: "We couldn't load your tasks right now.",
                  onRetry: () => ref.invalidate(tasksViewModelProvider),
                ),
                data: (data) {
                  if (data.groups.isEmpty) return const _NoGroupsMessage();
                  final header = _TasksHeader(data: data, mode: mode);
                  return showBoard
                      ? _BoardBody(data: data, header: header)
                      : _ListBody(data: data, header: header);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TasksHeader extends ConsumerWidget {
  const _TasksHeader({required this.data, required this.mode});

  final TasksState data;
  final TasksViewMode mode;

  Future<void> _openEditGroup(
    BuildContext context,
    WidgetRef ref,
    int groupId,
  ) async {
    final updated = await context.push<bool>(Routes.editGroupPath(groupId));
    if (updated == true) ref.invalidate(tasksViewModelProvider);
  }

  void _changeMode(WidgetRef ref, TasksViewMode mode) {
    final notifier = ref.read(tasksViewModelProvider.notifier);
    switch (mode) {
      case TasksViewMode.list:
        notifier.showList();
      case TasksViewMode.board:
        unawaited(notifier.showBoard());
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final online = ref.watch(isOnlineProvider);
    final group = data.group;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text('Current group', style: theme.textTheme.titleSmall),
            const Spacer(),
            TextButton.icon(
              onPressed: group == null || !online
                  ? null
                  : () => _openEditGroup(context, ref, group.id),
              icon: const Icon(Symbols.edit, size: 18),
              label: const Text('Edit Group'),
            ),
          ],
        ),
        Text(data.groupName, style: theme.textTheme.bodyLarge),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: data.query,
          onChanged: (value) =>
              ref.read(tasksViewModelProvider.notifier).updateQuery(value),
          decoration: InputDecoration(
            hintText: 'Search for a task...',
            hintStyle: taskHintStyle(theme),
            suffixIcon: const Icon(Symbols.search),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHigh,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
        TasksViewToggle(
          mode: mode,
          onChanged: (mode) => _changeMode(ref, mode),
        ),
      ],
    );
  }
}

class _BoardBody extends ConsumerWidget {
  const _BoardBody({required this.data, required this.header});

  final TasksState data;
  final Widget header;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: header,
        ),
        Expanded(
          child: data.groupLoaded
              ? TaskBoard(key: ValueKey(data.group?.id), data: data)
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _GroupNotLoadedMessage(
                    groupName: data.groupName,
                    onRetry: () => ref.invalidate(tasksViewModelProvider),
                  ),
                ),
        ),
      ],
    );
  }
}

class _ListBody extends ConsumerWidget {
  const _ListBody({required this.data, required this.header});

  final TasksState data;
  final Widget header;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final pending = ref.watch(pendingOpsProvider).value ?? const <PendingOp>[];
    final sectionStyle = theme.textTheme.titleSmall?.copyWith(
      fontWeight: AppFontWeight.bold,
    );
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        header,
        const SizedBox(height: 24),
        if (!data.groupLoaded) ...[
          _GroupNotLoadedMessage(
            groupName: data.groupName,
            onRetry: () => ref.invalidate(tasksViewModelProvider),
          ),
          const SizedBox(height: 96),
        ] else ...[
          Text('Your pending tasks', style: sectionStyle),
          const SizedBox(height: 12),
          for (final entry in data.myEntries(pending)) ...[
            _ListEntryCard(entry: entry),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 12),
          Text('Pending group tasks', style: sectionStyle),
          const SizedBox(height: 12),
          for (final entry in data.groupEntries(pending)) ...[
            _ListEntryCard(entry: entry),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 96),
        ],
      ],
    );
  }
}

class _ListEntryCard extends ConsumerWidget {
  const _ListEntryCard({required this.entry});

  final TaskListEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (entry) {
      SyncedTaskEntry(:final task) => TaskCard(
        task: task,
        onTap: () => context.push(Routes.taskPath(task.id)),
      ),
      PendingTaskEntry(:final op) => PendingSyncCard(
        op: op,
        isSyncing: ref.watch(syncStatusProvider).value?.isSyncing ?? false,
        onRetry: () => ref.read(outboxSyncServiceProvider).retry(op.id),
        onDiscard: () => ref.read(outboxSyncServiceProvider).discard(op.id),
      ),
    };
  }
}

class _GroupNotLoadedMessage extends StatelessWidget {
  const _GroupNotLoadedMessage({
    required this.groupName,
    required this.onRetry,
  });

  final String groupName;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Symbols.cloud_off,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  groupNotLoadedMessage(groupName),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoGroupsMessage extends StatelessWidget {
  const _NoGroupsMessage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You don’t have any groups yet',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Create a group to start adding tasks.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Builder(
              builder: (context) => FilledButton.icon(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const Icon(Symbols.add_circle),
                label: const Text('New group'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
