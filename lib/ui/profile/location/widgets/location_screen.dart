import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:team12_flutter_juggle/data/local/pending_op.dart';
import 'package:team12_flutter_juggle/data/repositories/location/device_location_repository_provider.dart';
import 'package:team12_flutter_juggle/ui/core/network/connectivity_provider.dart';
import 'package:team12_flutter_juggle/ui/core/routing/routes.dart';
import 'package:team12_flutter_juggle/ui/core/sync/sync_providers.dart';
import 'package:team12_flutter_juggle/ui/core/themes/map_style.dart';
import 'package:team12_flutter_juggle/ui/core/ui/offline_banner.dart';
import 'package:team12_flutter_juggle/ui/profile/location/view_models/location_viewmodel.dart';
import 'package:team12_flutter_juggle/ui/profile/location/view_models/location_viewmodel_provider.dart';
import 'package:team12_flutter_juggle/ui/profile/location/widgets/location_map_picker.dart';
import 'package:team12_flutter_juggle/ui/profile/location/widgets/offline_map_notice.dart';
import 'package:team12_flutter_juggle/ui/profile/settings/widgets/settings_menu_tile.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:team12_flutter_juggle/ui/telemetry/screen_load_tracker.dart';
import 'package:team12_flutter_juggle/ui/telemetry/screen_names.dart';

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
      SaveOutcome.savedOffline => (
        'Saved on this device. It will sync when you’re back online.',
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
      screen: ScreenNames.locationReminders,
      state: state,
      child: Scaffold(
        appBar: AppBar(title: const Text('Location reminders')),
        body: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: state.when(
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
                          onPressed: () =>
                              ref.invalidate(locationViewModelProvider),
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
                    const _PendingSyncStatus(),
                    const SizedBox(height: 16),
                    Material(
                      color: theme.colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                      clipBehavior: Clip.antiAlias,
                      child: SettingsMenuTile(
                        title: 'Notify within',
                        subtitle: '${location.notifyWithin} m',
                        onTap: () =>
                            _pickRadius(context, ref, location.notifyWithin),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: FilledButton(
                        onPressed: location.canSave
                            ? () => _save(context, ref)
                            : null,
                        child: const Text('Save location'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingSyncStatus extends ConsumerWidget {
  const _PendingSyncStatus();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final op = (ref.watch(pendingOpsProvider).value ?? const <PendingOp>[])
        .where((op) => op.type == PendingOpType.saveLocation)
        .lastOrNull;
    if (op == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final failed = op.status == PendingOpStatus.failed;
    final color = failed ? scheme.error : scheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(
            failed ? Symbols.error : Symbols.cloud_upload,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              failed ? 'Couldn’t sync this place' : 'Waiting to sync',
              style: theme.textTheme.labelMedium?.copyWith(color: color),
            ),
          ),
          if (failed) ...[
            TextButton(
              onPressed: () => ref.read(outboxSyncServiceProvider).retry(op.id),
              child: const Text('Retry'),
            ),
            TextButton(
              onPressed: () => ref
                  .read(locationViewModelProvider.notifier)
                  .discardPendingSync(op.id),
              child: const Text('Discard'),
            ),
          ],
        ],
      ),
    );
  }
}

class _MapPreview extends ConsumerWidget {
  const _MapPreview({required this.point, required this.onTap});

  final LatLng? point;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selected = point;
    final offline = !ref.watch(isOnlineProvider);
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
            if (offline)
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: IgnorePointer(
                  child: OfflineMapNotice(
                    detail: selected == null
                        ? null
                        : formatCoordinates(selected),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
