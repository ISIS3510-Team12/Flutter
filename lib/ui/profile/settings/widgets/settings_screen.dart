import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/domain/models/profile/app_settings.dart';
import 'package:team12_flutter_juggle/ui/auth/view_models/auth_viewmodel_provider.dart';
import 'package:team12_flutter_juggle/ui/profile/settings/view_models/settings_viewmodel_provider.dart';
import 'package:team12_flutter_juggle/ui/profile/settings/widgets/settings_menu_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _pickThemeMode(BuildContext context, WidgetRef ref) async {
    final selected = await showDialog<AppThemeMode>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Theme'),
        children: AppThemeMode.values
            .map(
              (mode) => SimpleDialogOption(
                onPressed: () => Navigator.of(context).pop(mode),
                child: Text(_capitalize(mode.name)),
              ),
            )
            .toList(),
      ),
    );
    if (selected != null) {
      ref.read(settingsViewModelProvider.notifier).updateThemeMode(selected);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settingsState = ref.watch(settingsViewModelProvider);
    final authState = ref.watch(authViewModelProvider);
    return Scaffold(
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
                    title: 'Theme',
                    subtitle: 'Use ${settings.themeMode.name} appearance',
                    onTap: () => _pickThemeMode(context, ref),
                  ),
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
    );
  }
}

String _capitalize(String value) =>
    value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';
