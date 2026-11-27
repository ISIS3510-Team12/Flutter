import 'package:flutter/material.dart';

class CalendarSyncNotice extends StatelessWidget {
  const CalendarSyncNotice({
    super.key,
    required this.isOnline,
    required this.fromCache,
    required this.isRefreshing,
    required this.refreshFailed,
    required this.onRetry,
  });

  final bool isOnline;
  final bool fromCache;
  final bool isRefreshing;
  final bool refreshFailed;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final message = switch ((isOnline, isRefreshing, refreshFailed)) {
      (false, _, _) when fromCache => 'Offline. Showing your saved schedule.',
      (true, true, _) => 'Updating your schedule...',
      (true, false, true) => "Couldn't update. Showing your saved schedule.",
      _ => null,
    };
    if (message == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 12, 0),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              liveRegion: true,
              child: Text(
                message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          if (isOnline && refreshFailed && !isRefreshing)
            TextButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}
