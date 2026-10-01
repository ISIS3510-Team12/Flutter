import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class HomeState {
  const HomeState({
    required this.user,
    required this.numTasks,
    required this.numNotifications,
    this.selectedTab = 0,
    this.upcomingTasks = const [
      {
        'title': 'Finish Flutter homework',
        'icon': Icons.task_alt,
        'description': 'Today - 12 hours left',
      },
      {
        'title': 'Submit architecture report',
        'icon': Icons.task_alt,
        'description': 'Tomorrow - 1 day left',
      },
    ],
    this.recentActivity = const [
      {
        'title': 'Victoria completed a task',
        'icon': Icons.check_circle_outline,
        'description': '10 minutes ago',
        'group': 'Group 1',
      },
      {
        'title': 'Diego created a new task',
        'icon': Icons.add_task,
        'description': '30 minutes ago',
        'group': 'Group 2',
      },
      {
        'title': 'Victoria commented on a task',
        'icon': Icons.comment,
        'description': '1 hour ago',
        'group': 'Group 1',
      },
    ],
  });

  final String user;
  final int selectedTab;
  final int numTasks;
  final int numNotifications;
  final List<Map<String, dynamic>> upcomingTasks;
  final List<Map<String, dynamic>> recentActivity;
  
  // TODO: Update with user
  HomeState copyWith({
    String? user,
    int? selectedTab,
    int? numTasks,
    int? numNotifications,
    List<Map<String, dynamic>>? upcomingTasks,
    List<Map<String, dynamic>>? recentActivity,
  }) {
    return HomeState(
      user: user ?? this.user,
      numTasks: numTasks ?? this.numTasks,
      numNotifications: numNotifications ?? this.numNotifications,
      selectedTab: selectedTab ?? this.selectedTab,
      upcomingTasks: upcomingTasks ?? this.upcomingTasks,
      recentActivity: recentActivity ?? this.recentActivity,
    );
  }
}

class HomeViewModel extends AsyncNotifier<HomeState> {
  // TODO: Update with repository
  HomeViewModel();

  @override
  Future<HomeState> build() async {
    return HomeState(user: 'Victoria', numTasks: 9, numNotifications: 5);
  }

  void changeTab(int index) {
    final currentState = state.value;
    if (currentState == null) return;
    state = AsyncValue.data(currentState.copyWith(selectedTab: index));
  }
}
