String deadlineText(DateTime deadline) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(deadline.year, deadline.month, deadline.day);
  final daysAway = day.difference(today).inDays;
  final hoursLeft = deadline.difference(now).inHours;

  String label;
  if (daysAway == 0) {
    label = 'Today';
  } else if (daysAway == 1) {
    label = 'Tomorrow';
  } else {
    label = deadlineDate(deadline);
  }

  return '$label - $hoursLeft hours left';
}

String deadlineDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$month/$day/${date.year}';
}
