class DeadlinePrediction {
  const DeadlinePrediction({
    required this.projectId,
    required this.projectName,
    required this.deadline,
    required this.daysLeft,
    required this.totalTasks,
    required this.completedTasks,
    required this.remainingTasks,
    required this.paceTasksPerDay,
    required this.predictedCompletionDate,
    required this.willMeetDeadline,
  });

  final int projectId;
  final String projectName;
  final DateTime deadline;
  final double daysLeft;
  final int totalTasks;
  final int completedTasks;
  final int remainingTasks;
  final double paceTasksPerDay;
  final DateTime? predictedCompletionDate;
  final bool willMeetDeadline;

  factory DeadlinePrediction.fromJson(Map<String, dynamic> json) {
    return DeadlinePrediction(
      projectId: json['project_id'] as int,
      projectName: json['project_name'] as String,
      deadline: DateTime.parse(json['deadline'] as String),
      daysLeft: (json['days_left'] as num).toDouble(),
      totalTasks: json['total_tasks'] as int,
      completedTasks: json['completed_tasks'] as int,
      remainingTasks: json['remaining_tasks'] as int,
      paceTasksPerDay:
          (json['pace_tasks_per_day'] as num).toDouble(),
      predictedCompletionDate:
          json['predicted_completion_date'] == null
              ? null
              : DateTime.parse(
                  json['predicted_completion_date'] as String,
                ),
      willMeetDeadline: json['will_meet_deadline'] as bool,
    );
  }
}
