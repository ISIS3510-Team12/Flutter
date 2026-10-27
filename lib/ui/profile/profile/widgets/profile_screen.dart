import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:team12_flutter_juggle/ui/auth/providers/auth_providers.dart';
import 'package:team12_flutter_juggle/ui/core/routing/routes.dart';
import 'package:team12_flutter_juggle/ui/profile/profile/widgets/profile_menu_tile.dart';
import 'package:team12_flutter_juggle/ui/telemetry/screen_load_tracker.dart';
import 'package:team12_flutter_juggle/ui/telemetry/screen_names.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    return ScreenLoadTracker(
      screen: ScreenNames.profile,
      state: user,
      child: Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          children: [
            ProfileMenuTile(
              icon: Symbols.account_circle,
              label: 'Profile Information',
              onTap: () => context.push(Routes.profileInformation),
            ),
            ProfileMenuTile(
              icon: Symbols.notifications,
              label: 'Notifications',
              onTap: () => context.push(Routes.profileNotifications),
            ),
            ProfileMenuTile(
              icon: Symbols.settings,
              label: 'Settings',
              onTap: () => context.push(Routes.profileSettings),
            ),
          ],
        ),
      ),
    );
  }
}
