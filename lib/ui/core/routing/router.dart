import 'package:go_router/go_router.dart';
import 'package:team12_flutter_juggle/ui/calendar/widgets/calendar_screen.dart';
import 'package:team12_flutter_juggle/ui/groups/widgets/edit_group_screen.dart';
import 'package:team12_flutter_juggle/ui/groups/widgets/groups_screen.dart';
import 'package:team12_flutter_juggle/ui/home/widgets/home_screen.dart';
import 'package:team12_flutter_juggle/ui/landing/widgets/landing_screen.dart';
import 'package:team12_flutter_juggle/ui/auth/signin/widgets/signin_screen.dart';
import 'package:team12_flutter_juggle/ui/auth/signup/widgets/signup_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:team12_flutter_juggle/ui/profile/information/widgets/information_screen.dart';
import 'package:team12_flutter_juggle/ui/profile/location/widgets/location_map_picker.dart';
import 'package:team12_flutter_juggle/ui/profile/location/widgets/location_screen.dart';
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

import 'package:team12_flutter_juggle/ui/groups/widgets/group_detail_screen.dart';
import 'package:team12_flutter_juggle/ui/groups/widgets/new_group_screen.dart';
import './route_transitions.dart';
import './routes.dart';

final routes = <RouteBase>[
  GoRoute(
    path: Routes.landing,
    pageBuilder: (context, state) =>
        sharedAxisPage(state: state, child: const LandingScreen()),
  ),
  GoRoute(
    path: Routes.signin,
    pageBuilder: (context, state) =>
        sharedAxisPage(state: state, child: const SigninScreen()),
  ),
  GoRoute(
    path: Routes.signup,
    pageBuilder: (context, state) =>
        sharedAxisPage(state: state, child: const SignupScreen()),
  ),
  GoRoute(
    path: Routes.home,
    builder: (context, state) => const HomeScreen(),
  ),
  GoRoute(
    path: Routes.tasks,
    builder: (context, state) => const TasksScreen(),
  ),
  GoRoute(
    path: Routes.createTask,
    pageBuilder: (context, state) =>
        sharedAxisPage(state: state, child: const CreateTaskScreen()),
  ),
  GoRoute(
    path: Routes.allTasks,
    pageBuilder: (context, state) =>
        sharedAxisPage(state: state, child: const AllTasksScreen()),
  ),
  GoRoute(
    path: Routes.task,
    pageBuilder: (context, state) => sharedAxisPage(
      state: state,
      child: ViewTaskScreen(taskId: state.pathParameters['taskId']!),
    ),
  ),
  GoRoute(
    path: Routes.editTask,
    pageBuilder: (context, state) => sharedAxisPage(
      state: state,
      child: EditTaskScreen(taskId: state.pathParameters['taskId']!),
    ),
  ),
  GoRoute(
    path: Routes.taskPhoto,
    pageBuilder: (context, state) => sharedAxisPage(
      state: state,
      child: TaskPhotoViewer(taskId: state.pathParameters['taskId']!),
    ),
  ),
  GoRoute(
    path: Routes.profile,
    pageBuilder: (context, state) =>
        sharedAxisPage(state: state, child: const ProfileScreen()),
  ),
  GoRoute(
    path: Routes.profileInformation,
    pageBuilder: (context, state) =>
        sharedAxisPage(state: state, child: const InformationScreen()),
  ),
  GoRoute(
    path: Routes.profileNotifications,
    pageBuilder: (context, state) =>
        sharedAxisPage(state: state, child: const NotificationsScreen()),
  ),
  GoRoute(
    path: Routes.profileSettings,
    pageBuilder: (context, state) =>
        sharedAxisPage(state: state, child: const SettingsScreen()),
  ),
  GoRoute(
    path: Routes.profileLocation,
    pageBuilder: (context, state) =>
        sharedAxisPage(state: state, child: const LocationScreen()),
  ),
  GoRoute(
    path: Routes.profileLocationMap,
    pageBuilder: (context, state) => sharedAxisPage(
      state: state,
      child: LocationMapPicker(initial: state.extra as LatLng?),
    ),
  ),
  GoRoute(
    path: Routes.calendar,
    builder: (context, state) => const CalendarScreen(),
  ),
  GoRoute(
    path: Routes.createProject,
    pageBuilder: (context, state) {
      final groupId = int.parse(state.pathParameters['groupId']!);
      return sharedAxisPage(
        state: state,
        child: CreateProjectScreen(groupId: groupId),
      );
    },
  ),
  GoRoute(
    path: Routes.projectDetail,
    pageBuilder: (context, state) {
      final projectId = int.parse(state.pathParameters['projectId']!);
      return sharedAxisPage(
        state: state,
        child: ProjectDetailScreen(projectId: projectId),
      );
    },
  ),
  GoRoute(
    path: Routes.groups,
    builder: (context, state) => const GroupsScreen(),
  ),
  GoRoute(
    path: Routes.createGroup,
    pageBuilder: (context, state) =>
        sharedAxisPage(state: state, child: const NewGroupScreen()),
  ),
  GoRoute(
    path: Routes.groupDetail,
    pageBuilder: (context, state) {
      final groupId = int.parse(state.pathParameters['groupId']!);
      return sharedAxisPage(
        state: state,
        child: GroupDetailScreen(groupId: groupId),
      );
    },
  ),
  GoRoute(
    path: Routes.editGroup,
    pageBuilder: (context, state) {
      final groupId = int.parse(state.pathParameters['groupId']!);
      return sharedAxisPage(
        state: state,
        child: GroupEditScreen(groupId: groupId),
      );
    },
  ),
];
