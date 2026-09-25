import 'package:flutter/material.dart';
import 'package:team12_flutter_juggle/ui/profile/profile/widgets/profile_screen.dart';
import 'package:team12_flutter_juggle/data/repositories/profile/notifications_repository.dart';
import 'package:team12_flutter_juggle/data/repositories/profile/profile_repository.dart';
import 'package:team12_flutter_juggle/data/repositories/profile/settings_repository.dart';
import 'package:team12_flutter_juggle/data/services/profile/notifications_api_client.dart';
import 'package:team12_flutter_juggle/data/services/profile/profile_api_client.dart';
import 'package:team12_flutter_juggle/data/services/profile/settings_local_service.dart';
import 'package:team12_flutter_juggle/domain/models/profile/user_profile.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    void openProfile() {
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

    return AppBar(
      title: SvgPicture.asset('assets/juggle_logo.svg', height: 42),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: openProfile,
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
    );
  }
}
