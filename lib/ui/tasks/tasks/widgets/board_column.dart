import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';
import 'package:team12_flutter_juggle/ui/core/themes/app_typography.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/view_models/task_list_entry.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/widgets/board_status.dart';

class BoardColumn extends StatefulWidget {
  const BoardColumn({
    super.key,
    required this.status,
    required this.entries,
    required this.unavailable,
    required this.onMove,
    required this.cardBuilder,
  });

  final TaskStatus status;
  final List<TaskListEntry> entries;
  final bool unavailable;
  final void Function(Task task, TaskStatus status) onMove;
  final Widget Function(TaskListEntry entry) cardBuilder;

  @override
  State<BoardColumn> createState() => _BoardColumnState();
}

class _BoardColumnState extends State<BoardColumn> {
  final _scrollController = ScrollController();

  @override
  void didUpdateWidget(BoardColumn oldWidget) {
    super.didUpdateWidget(oldWidget);
    final firstId = widget.entries.firstOrNull?.task.id;
    if (firstId == null) return;
    if (oldWidget.entries.any((entry) => entry.task.id == firstId)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToTop());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (!mounted || !_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = widget.status;
    final entries = widget.entries;
    return DragTarget<Task>(
      onWillAcceptWithDetails: (details) => details.data.status != status,
      onAcceptWithDetails: (details) => widget.onMove(details.data, status),
      builder: (context, candidates, _) => AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: candidates.isEmpty ? Colors.transparent : scheme.primary,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ColumnHeader(status: status, count: entries.length),
            const SizedBox(height: 8),
            Flexible(
              child: entries.isEmpty
                  ? SingleChildScrollView(
                      child: _EmptyColumn(
                        status: status,
                        unavailable: widget.unavailable,
                      ),
                    )
                  : ListView.separated(
                      controller: _scrollController,
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: entries.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (_, index) =>
                          widget.cardBuilder(entries[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColumnHeader extends StatelessWidget {
  const _ColumnHeader({required this.status, required this.count});

  final TaskStatus status;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: status.boardColor(scheme),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              status.boardLabel,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: AppFontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              semanticsLabel: '$count tasks',
              style: theme.textTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyColumn extends StatelessWidget {
  const _EmptyColumn({required this.status, required this.unavailable});

  final TaskStatus status;
  final bool unavailable;

  (String, String) get _message {
    if (unavailable) {
      return (
        "Couldn't load completed tasks",
        'Check your connection and open the board again.',
      );
    }
    return switch (status) {
      TaskStatus.pending => (
        'No tasks to start',
        'Drag a task here, or use Move to, to move it back.',
      ),
      TaskStatus.inProgress => (
        'Nothing in progress',
        'Drag a task here, or use Move to, to start it.',
      ),
      TaskStatus.done => (
        'No completed tasks yet',
        'Drag a task here, or use Move to, to mark it as done.',
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (title, hint) = _message;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            unavailable ? Symbols.cloud_off : Symbols.check_circle,
            fill: 1,
            color: scheme.outline,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: AppFontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hint,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
