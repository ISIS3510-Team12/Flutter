import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:team12_flutter_juggle/domain/models/auth/app_user.dart';
import 'package:team12_flutter_juggle/ui/auth/providers/auth_providers.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/view_models/tasks_overview_provider.dart';

class HomeState {
  const HomeState({
    required this.user,
    required this.numTasks,
    required this.numNotifications,
    required this.dueTodayTasks,
    this.recentActivity = const [
      {
        'title': 'Victoria completed a task',
        'icon': Icons.check_circle_outline,
        'description': '10 minutes ago',
        'group': 'Group 1',
      },
    ],
  });

  final AppUser user;
  final int numTasks;
  final int numNotifications;
  final List<Map<String, dynamic>> dueTodayTasks;
  final List<Map<String, dynamic>> recentActivity;

  HomeState copyWith({
    AppUser? user,
    int? numTasks,
    int? numNotifications,
    List<Map<String, dynamic>>? dueTodayTasks,
    List<Map<String, dynamic>>? recentActivity,
  }) {
    return HomeState(
      user: user ?? this.user,
      numTasks: numTasks ?? this.numTasks,
      numNotifications: numNotifications ?? this.numNotifications,
      dueTodayTasks: dueTodayTasks ?? this.dueTodayTasks,
      recentActivity: recentActivity ?? this.recentActivity,
    );
  }
}

class HomeViewModel extends AsyncNotifier<HomeState> {
  HomeViewModel();

  @override
  Future<HomeState> build() async {
    final user = await ref.watch(currentUserProvider.future);
    final tasks = await ref.watch(tasksOverviewProvider.future);

    if (user == null) {
      throw StateError('User is not logged in');
    }

    return HomeState(
      user: user,
      numTasks: tasks.dueTodayItems.length,
      numNotifications: 5,
      dueTodayTasks: tasks.dueTodayItems,
    );
  }
}
