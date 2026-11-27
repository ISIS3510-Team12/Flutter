import 'package:flutter/material.dart';

String deadlineText(DateTime deadline, {DateTime? now}) {
  now ??= DateTime.now();
  final remaining = deadline.difference(now);
  return '${deadlineDay(deadline, now: now)} - ${_remainingLabel(remaining)}';
}

String deadlineDay(DateTime deadline, {DateTime? now}) {
  now ??= DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(deadline.year, deadline.month, deadline.day);
  return switch (day.difference(today).inDays) {
    0 => 'Today',
    1 => 'Tomorrow',
    _ => deadlineDate(deadline),
  };
}

String updatedAgo(DateTime changedAt, {DateTime? now}) {
  final elapsed = (now ?? DateTime.now()).difference(changedAt);
  if (elapsed.inMinutes < 1) return 'Updated just now';
  if (elapsed.inHours < 1) {
    return 'Updated ${_plural(elapsed.inMinutes, 'minute')} ago';
  }
  if (elapsed.inDays < 1) {
    return 'Updated ${_plural(elapsed.inHours, 'hour')} ago';
  }
  return 'Updated ${_plural(elapsed.inDays, 'day')} ago';
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
