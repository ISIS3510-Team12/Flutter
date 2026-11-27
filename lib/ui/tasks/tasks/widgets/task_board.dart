import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:team12_flutter_juggle/data/local/pending_op.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';
import 'package:team12_flutter_juggle/ui/core/network/connectivity_provider.dart';
import 'package:team12_flutter_juggle/ui/core/routing/routes.dart';
import 'package:team12_flutter_juggle/ui/core/sync/sync_providers.dart';
import 'package:team12_flutter_juggle/ui/core/themes/app_typography.dart';
import 'package:team12_flutter_juggle/ui/core/ui/pending_sync_card.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/view_models/task_list_entry.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/view_models/tasks_viewmodel.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/view_models/tasks_viewmodel_provider.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/widgets/board_column.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/widgets/board_status.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/widgets/board_task_card.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/widgets/move_task_sheet.dart';

class TaskBoard extends ConsumerStatefulWidget {
  const TaskBoard({super.key, required this.data});

  final TasksState data;

  @override
  ConsumerState<TaskBoard> createState() => _TaskBoardState();
}

class _TaskBoardState extends ConsumerState<TaskBoard> {
  static const _edgeWidth = 48.0;
  static const _offlineMessage = 'No connection. Reconnect to move this task.';

  final _pages = PageController(viewportFraction: 0.82);
  int _page = 0;
  bool _autoScrolling = false;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  Future<void> _move(Task task, TaskStatus status) async {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final result = await ref
        .read(tasksViewModelProvider.notifier)
        .moveTask(task, status);
    if (!mounted) return;
    messenger.clearSnackBars();
    switch (result) {
      case MoveTaskResult.moved:
        messenger.showSnackBar(
          SnackBar(
            content: Text('Moved to ${status.boardLabel}'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () =>
                  unawaited(_move(task.copyWith(status: status), task.status)),
            ),
          ),
        );
      case MoveTaskResult.offline:
        _showOffline();
      case MoveTaskResult.failed:
        messenger.showSnackBar(
          const SnackBar(
            content: Text("We couldn't move the task. Try again."),
          ),
        );
    }
  }

  void _showOffline() {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(const SnackBar(content: Text(_offlineMessage)));
  }

  Future<void> _openMoveSheet(Task task) async {
    if (!ref.read(isOnlineProvider)) {
      _showOffline();
      return;
    }
    final status = await showMoveTaskSheet(context, task);
    if (status == null || status == task.status) return;
    await _move(task, status);
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_autoScrolling) return;
    final width = MediaQuery.sizeOf(context).width;
    final x = details.globalPosition.dx;
    final step = x > width - _edgeWidth ? 1 : (x < _edgeWidth ? -1 : 0);
    final target = _page + step;
    if (step == 0 || target < 0 || target >= TaskStatus.values.length) return;
    _autoScrolling = true;
    unawaited(
      _pages
          .animateToPage(
            target,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          )
          .whenComplete(() => _autoScrolling = false),
    );
  }

  Widget _card(
    TaskListEntry entry, {
    required bool online,
    required bool isSyncing,
  }) {
    return switch (entry) {
      SyncedTaskEntry(:final task) => DraggableBoardTaskCard(
        task: task,
        locked: !online,
        onTap: () => context.push(Routes.taskPath(task.id)),
        onMenu: () => unawaited(_openMoveSheet(task)),
        onLockedLongPress: _showOffline,
        onDragUpdate: _onDragUpdate,
      ),
      PendingTaskEntry(:final op) => PendingSyncCard(
        op: op,
        isSyncing: isSyncing,
        onRetry: () => ref.read(outboxSyncServiceProvider).retry(op.id),
        onDiscard: () => ref.read(outboxSyncServiceProvider).discard(op.id),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final online = ref.watch(isOnlineProvider);
    final pending = ref.watch(pendingOpsProvider).value ?? const <PendingOp>[];
    final isSyncing = ref.watch(syncStatusProvider).value?.isSyncing ?? false;
    const statuses = TaskStatus.values;
    return Column(
      children: [
        if (!online) const _ReadOnlyBanner(),
        Expanded(
          child: PageView.builder(
            controller: _pages,
            padEnds: false,
            itemCount: statuses.length,
            onPageChanged: (page) => setState(() => _page = page),
            itemBuilder: (context, index) {
              final status = statuses[index];
              return Padding(
                padding: const EdgeInsetsDirectional.only(start: 16),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: BoardColumn(
                    status: status,
                    entries: widget.data.boardEntries(status, pending),
                    unavailable:
                        status == TaskStatus.done &&
                        widget.data.completedUnavailable,
                    onMove: (task, target) => unawaited(_move(task, target)),
                    cardBuilder: (entry) =>
                        _card(entry, online: online, isSyncing: isSyncing),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        _PageDots(count: statuses.length, current: _page),
        const SizedBox(height: 72),
      ],
    );
  }
}

class _ReadOnlyBanner extends StatelessWidget {
  const _ReadOnlyBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      liveRegion: true,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(Symbols.cloud_off, size: 18, color: scheme.onSurfaceVariant),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No internet connection',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: AppFontWeight.bold,
                    ),
                  ),
                  Text(
                    'The board is read only until you reconnect',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Column ${current + 1} of $count',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var index = 0; index < count; index++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index == current
                    ? scheme.primaryContainer
                    : scheme.outlineVariant,
              ),
            ),
        ],
      ),
    );
  }
}
