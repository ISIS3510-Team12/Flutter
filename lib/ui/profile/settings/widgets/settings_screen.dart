import 'package:flutter/material.dart';
import 'package:team12_flutter_juggle/domain/models/profile/app_settings.dart';
import 'package:team12_flutter_juggle/ui/profile/settings/view_models/settings_viewmodel.dart';
import 'package:team12_flutter_juggle/ui/profile/settings/widgets/settings_menu_tile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.viewModel});

  final SettingsViewModel viewModel;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  Future<void> _pickThemeMode(BuildContext context) async {
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
      widget.viewModel.updateThemeMode(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          final settings = widget.viewModel.settings;
          if (settings == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
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
                      onTap: () => _pickThemeMode(context),
                    ),
                    SettingsMenuTile(
                      title: 'Language',
                      subtitle: _languageName(settings.languageCode),
                      showChevron: false,
                    ),
                    SettingsMenuTile(
                      title: 'Sound & vibration',
                      subtitle: 'Control app sounds and haptics',
                      showChevron: false,
                      trailing: Switch(
                        value: settings.soundAndVibrationEnabled,
                        onChanged: widget.viewModel.updateSoundAndVibration,
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
                  onPressed: widget.viewModel.isSigningOut
                      ? null
                      : () => widget.viewModel.signOut(),
                  child: widget.viewModel.isSigningOut
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Sign out'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

String _capitalize(String value) =>
    value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';

String _languageName(String languageCode) {
  switch (languageCode) {
    case 'en':
      return 'English';
    default:
      return languageCode.toUpperCase();
  }
}
