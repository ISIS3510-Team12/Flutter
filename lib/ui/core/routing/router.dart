import 'package:go_router/go_router.dart';
import 'package:team12_flutter_juggle/ui/calendar/widgets/calendar_screen.dart';
import 'package:team12_flutter_juggle/ui/home/widgets/home_screen.dart';
import 'package:team12_flutter_juggle/ui/landing/widgets/landing_screen.dart';
import 'package:team12_flutter_juggle/ui/auth/signin/widgets/signin_screen.dart';
import 'package:team12_flutter_juggle/ui/auth/signup/widgets/signup_screen.dart';
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
  GoRoute(
    path: Routes.calendar,
    builder: (context, state) => const CalendarScreen(),
  ),
];
