import 'package:flutter/material.dart';

class PaceWarningCard extends StatelessWidget {
  const PaceWarningCard({
    super.key,
    required this.completedTasks,
    required this.totalTasks,
    required this.deadline,
  });

  final int completedTasks;
  final int totalTasks;
  final DateTime deadline;

  @override
  Widget build(BuildContext context) {
    final remainingTasks = totalTasks - completedTasks;

    final now = DateTime.now();
    final daysRemaining = deadline.difference(now).inDays;

    final paceTooSlow =
        totalTasks > 0 &&
        remainingTasks > 0 &&
        daysRemaining >= 0 &&
        remainingTasks > daysRemaining;

    if (!paceTooSlow) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(top: 1),
            decoration: BoxDecoration(
              color: colorScheme.error,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '!',
                style: TextStyle(
                  color: colorScheme.onError,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  height: 1,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pace too slow',
                  style: TextStyle(
                    color: colorScheme.onErrorContainer,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  totalTasks == 0
                      ? 'There are no tasks in this project yet.'
                      : daysRemaining < 0
                          ? '$remainingTasks tasks are still incomplete.'
                          : "Your current pace won't complete all planned "
                            'tasks before the deadline.',
                  style: TextStyle(
                    color: colorScheme.onErrorContainer,
                    fontSize: 13,
                    height: 1.35,
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