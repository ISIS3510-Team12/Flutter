import 'package:go_router/go_router.dart';
import 'package:team12_flutter_juggle/ui/core/app/app.dart';
import 'package:team12_flutter_juggle/ui/landing/widgets/landing_screen.dart';
import 'package:team12_flutter_juggle/ui/auth/signin/widgets/signin_screen.dart';
import 'package:team12_flutter_juggle/ui/auth/signup/widgets/signup_screen.dart';
import 'package:team12_flutter_juggle/ui/profile/information/widgets/information_screen.dart';
import 'package:team12_flutter_juggle/ui/profile/notifications/widgets/notifications_screen.dart';
import 'package:team12_flutter_juggle/ui/profile/profile/widgets/profile_screen.dart';
import 'package:team12_flutter_juggle/ui/profile/settings/widgets/settings_screen.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/widgets/tasks_screen.dart';

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
  GoRoute(path: Routes.home, builder: (context, state) => const MainScreen()),
  GoRoute(path: Routes.tasks, builder: (context, state) => const TasksScreen()),
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
];
