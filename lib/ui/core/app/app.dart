import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:team12_flutter_juggle/data/repositories/profile/notifications_repository.dart';
import 'package:team12_flutter_juggle/data/repositories/profile/profile_repository.dart';
import 'package:team12_flutter_juggle/data/repositories/profile/settings_repository.dart';
import 'package:team12_flutter_juggle/data/services/profile/notifications_api_client.dart';
import 'package:team12_flutter_juggle/data/services/profile/profile_api_client.dart';
import 'package:team12_flutter_juggle/data/services/profile/settings_local_service.dart';
import 'package:team12_flutter_juggle/domain/models/profile/user_profile.dart';
import 'package:team12_flutter_juggle/ui/core/ui/custom_navigation_bar.dart';
import 'package:team12_flutter_juggle/ui/core/themes/app_theme.dart';
import 'package:team12_flutter_juggle/ui/profile/profile/widgets/profile_screen.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Juggle',
      home: MainScreen(),
      theme: AppTheme.light,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // TODO: these are wired to mock services (in-memory sample data)
  final _profileRepository = ProfileRepository(ProfileApiClient());
  final _notificationsRepository = NotificationsRepository(
    NotificationsApiClient(),
  );
  final _settingsRepository = SettingsRepository(SettingsLocalService());

  UserProfile? _profile;

  @override
  void initState() {
    super.initState();
    _profileRepository.getProfile().then((profile) {
      if (mounted) setState(() => _profile = profile);
    });
  }

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProfileScreen(
          profileRepository: _profileRepository,
          notificationsRepository: _notificationsRepository,
          settingsRepository: _settingsRepository,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: SvgPicture.asset('assets/juggle_logo.svg', height: 42),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: _openProfile,
              child: CircleAvatar(
                backgroundColor: theme.colorScheme.primary,
                child: Text(
                  _profile?.initial ?? '',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Hello, World!',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(),
      resizeToAvoidBottomInset: false,
    );
  }
}
