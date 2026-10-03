class TodaySummary {
  const TodaySummary({
    required this.pendingCount,
    required this.todayCount,
    required this.overdueCount,
    required this.titles,
  });

  final int pendingCount;
  final int todayCount;
  final int overdueCount;
  final List<String> titles;

  factory TodaySummary.fromJson(Map<String, dynamic> json) {
    return TodaySummary(
      pendingCount: json['pending_count'] as int,
      todayCount: json['today_count'] as int,
      overdueCount: json['overdue_count'] as int,
      titles: [
        for (final title in json['titles'] as List<dynamic>? ?? const [])
          title as String,
      ],
    );
  }
}
