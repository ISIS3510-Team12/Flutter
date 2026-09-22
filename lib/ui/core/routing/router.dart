import 'package:go_router/go_router.dart';
import 'package:team12_flutter_juggle/ui/auth/landing/widgets/landing_screen.dart';
import 'package:team12_flutter_juggle/ui/auth/signin/widgets/signin_screen.dart';
import 'package:team12_flutter_juggle/ui/auth/signup/widgets/signup_screen.dart';
import './routes.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: Routes.landing,
      builder: (context, state) => const LandingScreen()
    ),
    GoRoute(
      path: Routes.signin,
      builder: (context, state) => const SigninScreen()
    ),
    GoRoute(
      path: Routes.signup,
      builder: (context, state) => const SignupScreen()
    ),
  ]
);

