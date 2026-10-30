import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:team12_flutter_juggle/data/local/pending_op.dart';
import 'package:team12_flutter_juggle/ui/core/utils/deadline_format.dart';

class PendingSyncCard extends StatelessWidget {
  const PendingSyncCard({
    super.key,
    required this.op,
    required this.isSyncing,
    required this.onRetry,
    required this.onDiscard,
  });

  final PendingOp op;
  final bool isSyncing;
  final VoidCallback onRetry;
  final VoidCallback onDiscard;

  String _status() {
    if (op.status == PendingOpStatus.failed) {
      return 'Could not be uploaded';
    }
    if (isSyncing) return 'Uploading...';
    if (op.attempts > 0) return 'Waiting to retry';
    return 'Waiting to upload';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final failed = op.status == PendingOpStatus.failed;
    final task = op.task;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: failed ? scheme.error : scheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Icon(
            failed ? Symbols.error : Symbols.cloud_upload,
            color: failed ? scheme.error : scheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: theme.textTheme.bodyLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  deadlineText(task.deadline),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  _status(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: failed ? scheme.error : scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (failed)
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          IconButton(
            tooltip: 'Discard',
            onPressed: onDiscard,
            icon: const Icon(Symbols.close),
          ),
        ],
      ),
    );
  }
}
