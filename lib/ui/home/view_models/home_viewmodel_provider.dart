import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/profile/notifications_repository_provider.dart';
import 'package:team12_flutter_juggle/ui/home/view_models/home_state.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/view_models/tasks_overview_provider.dart';
import 'package:team12_flutter_juggle/ui/auth/providers/auth_providers.dart';

final homeViewModelProvider = FutureProvider.autoDispose<HomeState>((
  ref,
) async {
  final user = await ref.watch(currentUserProvider.future);
  final tasks = await ref.watch(tasksOverviewProvider.future);
  final notifications = await ref
      .watch(notificationsRepositoryProvider)
      .getNotifications();

  if (user == null) {
    throw StateError('User is not logged in');
  }

  return HomeState(
    user: user,
    numTasks: tasks.dueTodayItems.length,
    numNotifications: notifications.length,
    dueTodayTasks: tasks.dueTodayItems,
    recentActivity: notifications
  );
});
