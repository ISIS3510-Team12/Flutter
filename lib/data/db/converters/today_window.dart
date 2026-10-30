({int startMs, int endMs}) todayWindow(DateTime now) {
  final start = DateTime(now.year, now.month, now.day);
  final end = DateTime(now.year, now.month, now.day + 1);
  return (
    startMs: start.toUtc().millisecondsSinceEpoch,
    endMs: end.toUtc().millisecondsSinceEpoch,
  );
}
