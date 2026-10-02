import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:team12_flutter_juggle/ui/auth/providers/auth_providers.dart';
import 'package:team12_flutter_juggle/ui/core/routing/routes.dart';
import 'package:team12_flutter_juggle/ui/profile/profile/widgets/profile_menu_tile.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);
    return Scaffold(
      appBar: AppBar(),
      body: user.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
        data: (user) {
          if (user == null) {
            return const SizedBox.shrink();
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
                      user.initial,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.fullName, style: theme.textTheme.titleLarge),
                      Text(
                        'Student',
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
          );
        },
      ),
    );
  }
}
