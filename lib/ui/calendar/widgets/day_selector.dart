import 'package:flutter/material.dart';

class DaySelector extends StatelessWidget {
  const DaySelector({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final dates = List.generate(
      7,
      (index) => DateTime(2026, 9, 6 + index),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.chevron_left),
          ),

          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: dates.map((date) {
                final isSelected =
                    date.year == selectedDate.year &&
                    date.month == selectedDate.month &&
                    date.day == selectedDate.day;

                return GestureDetector(
                  onTap: () => onDateSelected(date),
                  child: Column(
                    children: [
                      Text(
                        _getWeekday(date),
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${date.day}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isSelected
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurface,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  String _getWeekday(DateTime date) {
    const weekdays = [
      'Mo',
      'Tu',
      'We',
      'Th',
      'Fr',
      'Sa',
      'Su',
    ];

    return weekdays[date.weekday - 1];
  }
}