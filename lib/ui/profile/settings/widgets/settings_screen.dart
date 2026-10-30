import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:team12_flutter_juggle/ui/core/routing/routes.dart';
import 'package:team12_flutter_juggle/ui/auth/view_models/auth_viewmodel_provider.dart';
import 'package:team12_flutter_juggle/ui/core/sync/sync_providers.dart';
import 'package:team12_flutter_juggle/ui/profile/settings/view_models/settings_viewmodel_provider.dart';
import 'package:team12_flutter_juggle/ui/profile/settings/widgets/settings_menu_tile.dart';
import 'package:team12_flutter_juggle/ui/telemetry/screen_load_tracker.dart';
import 'package:team12_flutter_juggle/ui/telemetry/screen_names.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final pending = ref.read(pendingOpsProvider).value?.length ?? 0;
    if (pending > 0) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Sign out?'),
          content: Text(
            pending == 1
                ? '1 task is still waiting to upload and will be discarded if you sign out.'
                : '$pending tasks are still waiting to upload and will be discarded if you sign out.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Stay signed in'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Sign out'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    await ref.read(authViewModelProvider.notifier).signOut();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settingsState = ref.watch(settingsViewModelProvider);
    final authState = ref.watch(authViewModelProvider);
    return ScreenLoadTracker(
      screen: ScreenNames.settings,
      state: settingsState,
      child: Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: settingsState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Error: $error')),
          data: (settings) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Material(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
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
                      : () => _signOut(context, ref),
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
