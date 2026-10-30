import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';
import 'package:team12_flutter_juggle/data/db/converters/today_window.dart';
import 'package:team12_flutter_juggle/data/db/daos/notifications/notifications_cache_dao_provider.dart';
import 'package:team12_flutter_juggle/data/db/daos/tasks/tasks_cache_dao_provider.dart';
import 'package:team12_flutter_juggle/data/repositories/profile/notifications_repository_provider.dart';
import 'package:team12_flutter_juggle/data/repositories/tasks/task_repository_provider.dart';
import 'package:team12_flutter_juggle/ui/auth/providers/auth_providers.dart';
import 'package:team12_flutter_juggle/ui/core/app/service_locator.dart';
import 'package:team12_flutter_juggle/ui/core/network/connectivity_provider.dart';
import 'package:team12_flutter_juggle/ui/home/view_models/home_state.dart';

final homeViewModelProvider = StreamProvider.autoDispose<HomeState>((ref) async* {
  final isOnline = ref.watch(isOnlineProvider);
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) {
    throw StateError('User is not logged in');
  }

  final localTask = ref.read(tasksCacheDaoProvider);
  final localNotification = ref.read(notificationsCacheDaoProvider);
  final taskApi = ref.read(taskRepositoryProvider);
  final notificationApi = ref.read(notificationsRepositoryProvider);
  final now = ref.read(clockProvider).now;

  if (isOnline) {
    try {
      await Future.wait([
        localTask.refresh(user.userId, () => taskApi.getAllTasks(mine: true)),
        localNotification.refresh(
          user.userId,
          notificationApi.getNotifications,
        ),
      ]).timeout(const Duration(seconds: 10));
    } catch (error, stack) {
      debugPrint('Home refresh failed, showing cache: $error\n$stack');
    }
  }

  final nowValue = now();
  final (:startMs, :endMs) = todayWindow(nowValue);

  yield* Rx.combineLatest3(
    localTask.watchUrgentCount(user.userId),
    localTask.watchPendingDueBetween(
      user.userId,
      startMs: nowValue.toUtc().millisecondsSinceEpoch,
      endMs: endMs,
    ),
    localNotification.watchBetween(
      user.userId,
      startMs: startMs,
      endMs: endMs,
    ),
    (urgentCount, dueToday, todayNotifications) => HomeState(
      user: user,
      numUrgentTasks: urgentCount,
      dueTodayTasks: dueToday.map(HomeTaskItem.fromTask).toList(),
      recentActivity: todayNotifications,
    ),
  );
});
