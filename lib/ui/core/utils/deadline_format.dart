import 'package:flutter/material.dart';

String deadlineText(DateTime deadline) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(deadline.year, deadline.month, deadline.day);
  final daysAway = day.difference(today).inDays;
  final remaining = deadline.difference(now);

  String label;
  if (daysAway == 0) {
    label = 'Today';
  } else if (daysAway == 1) {
    label = 'Tomorrow';
  } else {
    label = deadlineDate(deadline);
  }

  return '$label - ${_remainingLabel(remaining)}';
}

String _remainingLabel(Duration remaining) {
  final overdue = remaining.isNegative;
  final span = overdue ? -remaining : remaining;
  final suffix = overdue ? 'overdue' : 'left';
  final hours = span.inHours;
  final days = span.inDays;
  if (hours < 1) return overdue ? 'just overdue' : 'less than 1 hour left';
  if (hours <= 48) return '${_plural(hours, 'hour')} $suffix';
  if (days <= 7) return '${_plural(days, 'day')} $suffix';
  if (days <= 30) return '${_plural(days ~/ 7, 'week')} $suffix';
  if (days <= 365) return '${_plural(days ~/ 30, 'month')} $suffix';
  return '${_plural(days ~/ 365, 'year')} $suffix';
}

String _plural(int value, String unit) =>
    '$value $unit${value == 1 ? '' : 's'}';

String deadlineDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$month/$day/${date.year}';
}

String timeOfDayLabel(TimeOfDay time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
