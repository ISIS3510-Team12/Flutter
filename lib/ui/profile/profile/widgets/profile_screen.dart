import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:team12_flutter_juggle/data/repositories/profile/notifications_repository.dart';
import 'package:team12_flutter_juggle/data/repositories/profile/profile_repository.dart';
import 'package:team12_flutter_juggle/data/repositories/profile/settings_repository.dart';
import 'package:team12_flutter_juggle/ui/profile/information/view_models/information_viewmodel.dart';
import 'package:team12_flutter_juggle/ui/profile/information/widgets/information_screen.dart';
import 'package:team12_flutter_juggle/ui/profile/notifications/view_models/notifications_viewmodel.dart';
import 'package:team12_flutter_juggle/ui/profile/notifications/widgets/notifications_screen.dart';
import 'package:team12_flutter_juggle/ui/profile/profile/view_models/profile_viewmodel.dart';
import 'package:team12_flutter_juggle/ui/profile/profile/widgets/profile_menu_tile.dart';
import 'package:team12_flutter_juggle/ui/profile/settings/view_models/settings_viewmodel.dart';
import 'package:team12_flutter_juggle/ui/profile/settings/widgets/settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.profileRepository,
    required this.notificationsRepository,
    required this.settingsRepository,
    this.onSignedOut,
  });

  final ProfileRepository profileRepository;
  final NotificationsRepository notificationsRepository;
  final SettingsRepository settingsRepository;
  final VoidCallback? onSignedOut;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileViewModel _viewModel = ProfileViewModel(
    profileRepository: widget.profileRepository,
  );

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          final profile = _viewModel.profile;
          if (profile == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      profile.initial,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile.fullName, style: theme.textTheme.titleLarge),
                      Text(
                        profile.role,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ProfileMenuTile(
                icon: Symbols.account_circle,
                label: 'Profile Information',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => InformationScreen(
                      viewModel: InformationViewModel(
                        profileRepository: widget.profileRepository,
                      ),
                    ),
                  ),
                ),
              ),
              ProfileMenuTile(
                icon: Symbols.notifications,
                label: 'Notifications',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => NotificationsScreen(
                      viewModel: NotificationsViewModel(
                        notificationsRepository: widget.notificationsRepository,
                      ),
                    ),
                  ),
                ),
              ),
              ProfileMenuTile(
                icon: Symbols.settings,
                label: 'Settings',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SettingsScreen(
                      viewModel: SettingsViewModel(
                        settingsRepository: widget.settingsRepository,
                        // TODO: once there's a login flow, wire a default
                        onSignedOut: widget.onSignedOut ?? () {},
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
