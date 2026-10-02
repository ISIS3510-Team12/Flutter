import 'package:go_router/go_router.dart';
import 'package:team12_flutter_juggle/ui/calendar/widgets/calendar_screen.dart';
import 'package:team12_flutter_juggle/ui/home/widgets/home_screen.dart';
import 'package:team12_flutter_juggle/ui/landing/widgets/landing_screen.dart';
import 'package:team12_flutter_juggle/ui/auth/signin/widgets/signin_screen.dart';
import 'package:team12_flutter_juggle/ui/auth/signup/widgets/signup_screen.dart';
import 'package:team12_flutter_juggle/ui/profile/information/widgets/information_screen.dart';
import 'package:team12_flutter_juggle/ui/profile/notifications/widgets/notifications_screen.dart';
import 'package:team12_flutter_juggle/ui/profile/profile/widgets/profile_screen.dart';
import 'package:team12_flutter_juggle/ui/profile/settings/widgets/settings_screen.dart';
import 'package:team12_flutter_juggle/ui/projects/widgets/create_project_screen.dart';
import 'package:team12_flutter_juggle/ui/projects/widgets/project_detail_screen.dart';
import 'package:team12_flutter_juggle/ui/tasks/all_tasks/widgets/all_tasks_screen.dart';
import 'package:team12_flutter_juggle/ui/tasks/create_task/widgets/create_task_screen.dart';
import 'package:team12_flutter_juggle/ui/tasks/edit_task/widgets/edit_task_screen.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/widgets/tasks_screen.dart';
import 'package:team12_flutter_juggle/ui/tasks/view_task/widgets/view_task_screen.dart';
import 'package:team12_flutter_juggle/ui/tasks/widgets/task_photo_viewer.dart';

import './routes.dart';

final routes = <RouteBase>[
  GoRoute(
    path: Routes.landing,
    builder: (context, state) => const LandingScreen(),
  ),
  GoRoute(
    path: Routes.signin,
    builder: (context, state) => const SigninScreen(),
  ),
  GoRoute(
    path: Routes.signup,
    builder: (context, state) => const SignupScreen(),
  ),
  GoRoute(path: Routes.home, builder: (context, state) => const HomeScreen()),
  GoRoute(path: Routes.tasks, builder: (context, state) => const TasksScreen()),
  GoRoute(
    path: Routes.createTask,
    builder: (context, state) => const CreateTaskScreen(),
  ),
  GoRoute(
    path: Routes.allTasks,
    builder: (context, state) => const AllTasksScreen(),
  ),
  GoRoute(
    path: Routes.task,
    builder: (context, state) =>
        ViewTaskScreen(taskId: state.pathParameters['taskId']!),
  ),
  GoRoute(
    path: Routes.editTask,
    builder: (context, state) =>
        EditTaskScreen(taskId: state.pathParameters['taskId']!),
  ),
  GoRoute(
    path: Routes.taskPhoto,
    builder: (context, state) =>
        TaskPhotoViewer(taskId: state.pathParameters['taskId']!),
  ),
  GoRoute(
    path: Routes.profile,
    builder: (context, state) => const ProfileScreen(),
  ),
  GoRoute(
    path: Routes.profileInformation,
    builder: (context, state) => const InformationScreen(),
  ),
  GoRoute(
    path: Routes.profileNotifications,
    builder: (context, state) => const NotificationsScreen(),
  ),
  GoRoute(
    path: Routes.profileSettings,
    builder: (context, state) => const SettingsScreen(),
  ),
  GoRoute(
    path: Routes.calendar,
    builder: (context, state) => const CalendarScreen(),
  ),
  GoRoute(
    path: Routes.createProject,
    builder: (context, state) {
      final groupId = int.parse(state.pathParameters['groupId']!);
      return CreateProjectScreen(groupId: groupId);
    },
  ),
  GoRoute(
    path: Routes.projectDetail,
    builder: (context, state) {
      final projectId = int.parse(state.pathParameters['projectId']!);
      return ProjectDetailScreen(projectId: projectId);
    },
  ),
];
