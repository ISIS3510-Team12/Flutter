import 'package:team12_flutter_juggle/domain/models/shared/server_date.dart';

enum NextTaskReason {
  overdue,
  dueToday,
  dueSoon,
  priority,
  needsHelp,
  nextDeadline;

  static NextTaskReason fromCode(String? code) => switch (code) {
    'overdue' => overdue,
    'due_today' => dueToday,
    'due_soon' => dueSoon,
    'priority' => priority,
    'needs_help' => needsHelp,
    _ => nextDeadline,
  };
}

class NextTask {
  const NextTask({
    required this.taskId,
    required this.title,
    required this.groupId,
    required this.groupName,
    required this.dueAt,
    required this.reason,
    required this.reasonText,
  });

  final int taskId;
  final String title;
  final int groupId;
  final String groupName;
  final DateTime? dueAt;
  final NextTaskReason reason;
  final String? reasonText;

  factory NextTask.fromJson(Map<String, dynamic> json) {
    final dueAt = json['due_at'] as String?;
    final reasonText = (json['reason_text'] as String?)?.trim();
    return NextTask(
      taskId: json['task_id'] as int,
      title: json['title'] as String,
      groupId: json['group_id'] as int,
      groupName: (json['group_name'] as String?) ?? '',
      dueAt: dueAt == null ? null : parseServerDate(dueAt),
      reason: NextTaskReason.fromCode(json['reason_code'] as String?),
      reasonText: reasonText == null || reasonText.isEmpty ? null : reasonText,
    );
  }
}

class NextTaskResult {
  const NextTaskResult({this.task, this.message});

  final NextTask? task;
  final String? message;

  factory NextTaskResult.fromJson(Map<String, dynamic> json) {
    final task = json['task'] as Map<String, dynamic>?;
    return NextTaskResult(
      task: task == null ? null : NextTask.fromJson(task),
      message: json['message'] as String?,
    );
  }
}
