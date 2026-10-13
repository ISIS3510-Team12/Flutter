import 'package:team12_flutter_juggle/domain/models/auth/app_user.dart';
import 'package:team12_flutter_juggle/domain/models/profile/app_notification.dart';

class HomeState {
  const HomeState({
    required this.user,
    required this.numTasks,
    required this.numNotifications,
    required this.dueTodayTasks,
    required this.recentActivity,
  });

  final AppUser user;
  final int numTasks;
  final int numNotifications;
  final List<Map<String, dynamic>> dueTodayTasks;
  final List<AppNotification> recentActivity;

  HomeState copyWith({
    AppUser? user,
    int? numTasks,
    int? numNotifications,
    List<Map<String, dynamic>>? dueTodayTasks,
    List<AppNotification>? recentActivity,
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

