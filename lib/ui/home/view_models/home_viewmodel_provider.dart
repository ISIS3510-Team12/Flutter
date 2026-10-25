import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/ui/auth/providers/auth_providers.dart';
import 'package:team12_flutter_juggle/ui/home/view_models/home_state.dart';
import 'package:team12_flutter_juggle/ui/profile/notifications/view_models/today_notifications_provider.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/view_models/tasks_overview_provider.dart';

final homeViewModelProvider = FutureProvider.autoDispose<HomeState>((
  ref,
) async {
  final (user, overview, todayNotifications) = await (
    ref.watch(currentUserProvider.future),
    ref.watch(tasksOverviewProvider.future),
    ref.watch(todayNotificationsProvider.future),
  ).wait;

  if (user == null) {
    throw StateError('User is not logged in');
  }

  return HomeState(
    user: user,
    numUrgentTasks: overview.urgentCount,
    dueTodayTasks: overview.dueToday.map(HomeTaskItem.fromTask).toList(),
    recentActivity: todayNotifications,
  );
});
