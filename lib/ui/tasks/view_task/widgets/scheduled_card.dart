import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';
import 'package:team12_flutter_juggle/ui/core/utils/deadline_format.dart';

class ScheduledCard extends StatelessWidget {
  const ScheduledCard({
    super.key,
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
