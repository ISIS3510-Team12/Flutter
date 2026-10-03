import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:team12_flutter_juggle/ui/core/routing/routes.dart';
import 'package:team12_flutter_juggle/ui/auth/view_models/auth_viewmodel_provider.dart';
import 'package:team12_flutter_juggle/ui/profile/settings/view_models/settings_viewmodel_provider.dart';
import 'package:team12_flutter_juggle/ui/profile/settings/widgets/settings_menu_tile.dart';
import 'package:team12_flutter_juggle/ui/telemetry/screen_load_tracker.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settingsState = ref.watch(settingsViewModelProvider);
    final authState = ref.watch(authViewModelProvider);
    return ScreenLoadTracker(
      screen:'setting_screen',
      isLoading: settingsState.isLoading,
      child:  Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: settingsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
        data: (settings) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  SettingsMenuTile(
                    title: 'Sound & vibration',
                    subtitle: 'Control app sounds and haptics',
                    showChevron: false,
                    trailing: Switch(
                      value: settings.soundAndVibrationEnabled,
                      onChanged: (value) => ref
                          .read(settingsViewModelProvider.notifier)
                          .updateSoundAndVibration(value),
                    ),
                  ),
                  SettingsMenuTile(
                    title: 'Location reminders',
                    subtitle: 'Get notified near a saved place',
                    onTap: () => context.push(Routes.profileLocation),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                ),
                onPressed: authState.isLoading
                    ? null
                    : () => ref.read(authViewModelProvider.notifier).signOut(),
                child: authState.isLoading
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Sign out'),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
