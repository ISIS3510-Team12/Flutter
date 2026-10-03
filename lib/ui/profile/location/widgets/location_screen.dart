import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:team12_flutter_juggle/data/repositories/location/device_location_repository_provider.dart';
import 'package:team12_flutter_juggle/ui/core/routing/routes.dart';
import 'package:team12_flutter_juggle/ui/core/themes/map_style.dart';
import 'package:team12_flutter_juggle/ui/profile/location/view_models/location_viewmodel.dart';
import 'package:team12_flutter_juggle/ui/profile/location/view_models/location_viewmodel_provider.dart';
import 'package:team12_flutter_juggle/ui/profile/settings/widgets/settings_menu_tile.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:team12_flutter_juggle/ui/telemetry/screen_load_tracker.dart';

class LocationScreen extends ConsumerWidget {
  const LocationScreen({super.key});

  Future<void> _pickPlace(
    BuildContext context,
    WidgetRef ref,
    LatLng? current,
  ) async {
    final picked = await context.push<LatLng>(
      Routes.profileLocationMap,
      extra: current,
    );
    if (picked != null) {
      ref.read(locationViewModelProvider.notifier).selectPoint(picked);
    }
  }

  Future<void> _pickRadius(
    BuildContext context,
    WidgetRef ref,
    int current,
  ) async {
    final options = {...notifyWithinOptions, current}.toList()..sort();
    final selected = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Notify within'),
        children: [
          for (final meters in options)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(meters),
              child: Text('$meters m'),
            ),
        ],
      ),
    );
    if (selected != null) {
      ref.read(locationViewModelProvider.notifier).updateNotifyWithin(selected);
    }
  }

  Future<void> _save(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final outcome = await ref.read(locationViewModelProvider.notifier).save();
    final (message, openSettings) = switch (outcome) {
      SaveOutcome.saved => (
        'Location saved. We’ll remind you when you’re nearby.',
        false,
      ),
      SaveOutcome.savedWithoutLocationPermission => (
        'Location saved, but reminders need location access.',
        true,
      ),
      SaveOutcome.savedWithoutBackgroundPermission => (
        'Location saved. Allow location “all the time” to get '
            'reminders when the app is closed.',
        true,
      ),
      SaveOutcome.savedWithoutNotificationPermission => (
        'Location saved, but turn on notifications to receive reminders.',
        true,
      ),
      SaveOutcome.savedWithoutReminders => (
        'Location saved, but reminders couldn’t be turned on.',
        false,
      ),
      SaveOutcome.failed => (
        'We couldn’t save your location. Check your connection and try again.',
        false,
      ),
    };
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        action: openSettings
            ? SnackBarAction(
                label: 'Settings',
                onPressed: () =>
                    ref.read(deviceLocationRepositoryProvider).openSettings(),
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(locationViewModelProvider);
    return ScreenLoadTracker(
      screen:'location_screen',
      isLoading: state.isLoading,
      child:  Scaffold(
      appBar: AppBar(title: const Text('Location reminders')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'We couldn’t load your location. Check your connection and try again.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => ref.invalidate(locationViewModelProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (location) => ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Pick a place where you want to be reminded about your pending '
              'tasks. We\u2019ll notify you when you\u2019re nearby.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            _MapPreview(
              point: location.point,
              onTap: () => _pickPlace(context, ref, location.point),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SettingsMenuTile(
                title: 'Notify within',
                subtitle: '${location.notifyWithin} m',
                onTap: () => _pickRadius(context, ref, location.notifyWithin),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: FilledButton(
                onPressed: location.canSave ? () => _save(context, ref) : null,
                child: const Text('Save location'),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}

class _MapPreview extends StatelessWidget {
  const _MapPreview({required this.point, required this.onTap});

  final LatLng? point;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = point;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 180,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (selected == null)
              ColoredBox(color: theme.colorScheme.surfaceContainerHighest)
            else
              IgnorePointer(
                child: GoogleMap(
                  key: ValueKey(selected),
                  style: AppMapStyle.of(theme.colorScheme),
                  initialCameraPosition: CameraPosition(
                    target: selected,
                    zoom: 15,
                  ),
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  myLocationButtonEnabled: false,
                ),
              ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Symbols.location_on,
                        fill: 1,
                        size: 36,
                        color: theme.colorScheme.primary,
                      ),
                      if (selected == null)
                        Text(
                          'Tap to choose on map',
                          style: theme.textTheme.labelMedium,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
