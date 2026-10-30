import 'package:flutter/material.dart';
import 'package:team12_flutter_juggle/domain/models/project/deadline_prediction.dart';

class PaceWarningCard extends StatelessWidget {
  const PaceWarningCard({
    super.key,
    required this.prediction,
  });

  final DeadlinePrediction prediction;

  @override
  Widget build(BuildContext context) {
    final shouldWarn =
        prediction.totalTasks > 0 &&
        prediction.remainingTasks > 0 &&
        !prediction.willMeetDeadline;

    if (!shouldWarn) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final isOverdue = prediction.daysLeft < 0;

    final message = isOverdue
        ? '${prediction.remainingTasks} tasks are still incomplete '
            'and the project deadline has passed.'
        : "Your current pace won't complete all planned tasks "
            'before the deadline.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pace too slow',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: colorScheme.onErrorContainer,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onErrorContainer,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
