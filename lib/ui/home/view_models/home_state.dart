import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:team12_flutter_juggle/domain/models/auth/app_user.dart';
import 'package:team12_flutter_juggle/domain/models/profile/app_notification.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';
import 'package:team12_flutter_juggle/ui/core/utils/deadline_format.dart';

part 'home_state.freezed.dart';

@freezed
abstract class HomeTaskItem with _$HomeTaskItem {
  const factory HomeTaskItem({
    required String title,
    required bool isPriority,
    required String description,
    String? group,
    String? assignee,
  }) = _HomeTaskItem;

  factory HomeTaskItem.fromTask(Task task) {
    return HomeTaskItem(
      title: task.title,
      isPriority: task.isPriority,
      description: deadlineText(task.deadline),
      group: task.groupName.isEmpty ? null : task.groupName,
      assignee: task.assigneeName.isEmpty ? null : task.assigneeName,
    );
  }
}

@freezed
abstract class HomeState with _$HomeState {
  const HomeState._();

  const factory HomeState({
    required AppUser user,

    required int numUrgentTasks,
    required List<HomeTaskItem> dueTodayTasks,
    required List<AppNotification> recentActivity,
  }) = _HomeState;

  int get numNotifications => recentActivity.length;
}
