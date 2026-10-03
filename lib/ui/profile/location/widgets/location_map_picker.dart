import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:team12_flutter_juggle/data/repositories/location/device_location_repository.dart';
import 'package:team12_flutter_juggle/data/repositories/location/device_location_repository_provider.dart';
import 'package:team12_flutter_juggle/ui/profile/location/view_models/location_viewmodel_provider.dart';
import 'package:team12_flutter_juggle/ui/profile/location/view_models/place_name_provider.dart';

const defaultMapCenter = LatLng(4.6014, -74.0661);
const _panelHeight = 190.0;
const _markerSize = 44.0;

Future<BitmapDescriptor> _buildMarker(Color color, double pixelRatio) async {
  final painter = TextPainter(
    text: TextSpan(
      text: String.fromCharCode(Symbols.location_on.codePoint),
      style: TextStyle(
        fontFamily: Symbols.location_on.fontFamily,
        package: Symbols.location_on.fontPackage,
        fontSize: _markerSize * pixelRatio,
        color: color,
        fontVariations: const [FontVariation('FILL', 1)],
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  final recorder = ui.PictureRecorder();
  painter.paint(Canvas(recorder), Offset.zero);
  final image = await recorder.endRecording().toImage(
    painter.width.ceil(),
    painter.height.ceil(),
  );
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  return BitmapDescriptor.bytes(
    bytes!.buffer.asUint8List(),
    imagePixelRatio: pixelRatio,
  );
}

String formatCoordinates(LatLng point) =>
    '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}';

class LocationMapPicker extends ConsumerStatefulWidget {
  const LocationMapPicker({super.key, this.initial});

  final LatLng? initial;

  @override
  ConsumerState<LocationMapPicker> createState() => _LocationMapPickerState();
}

class _LocationMapPickerState extends ConsumerState<LocationMapPicker> {
  late LatLng? _selected = widget.initial;
  GoogleMapController? _controller;
  BitmapDescriptor? _marker;
  bool _locating = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final color = Theme.of(context).colorScheme.primary;
    final ratio = MediaQuery.devicePixelRatioOf(context);
    _buildMarker(color, ratio).then((marker) {
      if (mounted) setState(() => _marker = marker);
    });
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _locating = true);
    final messenger = ScaffoldMessenger.of(context);
    final result = await ref
        .read(locationViewModelProvider.notifier)
        .locateMe();
    if (!mounted) return;
    setState(() => _locating = false);
    final point = result.point;
    if (point != null) {
      setState(() => _selected = point);
      await _controller?.animateCamera(CameraUpdate.newLatLngZoom(point, 16));
      return;
    }
    final device = ref.read(deviceLocationRepositoryProvider);
    final (message, label, action) = switch (result.access) {
      LocationAccess.denied => (
        'Allow location access to use your current position.',
        null,
        null,
      ),
      LocationAccess.permanentlyDenied => (
        'Location access is blocked. Enable it in Settings to use your '
            'current position.',
        'Settings',
        device.openSettings,
      ),
      LocationAccess.serviceDisabled => (
        'Turn on your device location to use your current position.',
        'Turn on',
        device.openLocationSettings,
      ),
      LocationAccess.granted => (
        'We couldn’t find your position. Try again in an open area.',
        null,
        null,
      ),
    };
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        action: label == null
            ? null
            : SnackBarAction(label: label, onPressed: () => action?.call()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return Scaffold(
      appBar: AppBar(title: const Text('Choose a place')),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) => _controller = controller,
            initialCameraPosition: CameraPosition(
              target: widget.initial ?? defaultMapCenter,
              zoom: 15,
            ),
            padding: const EdgeInsets.only(bottom: _panelHeight),
            myLocationButtonEnabled: false,
            mapToolbarEnabled: false,
            onTap: (point) => setState(() => _selected = point),
            markers: {
              if (selected != null && _marker != null)
                Marker(
                  markerId: const MarkerId('selected'),
                  position: selected,
                  icon: _marker!,
                  anchor: const Offset(0.5, 0.9),
                ),
            },
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SafeArea(
              child: _SelectionPanel(
                point: selected,
                locating: _locating,
                onUseCurrent: _locating ? null : _useCurrentLocation,
                onConfirm: selected == null
                    ? null
                    : () => context.pop(selected),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectionPanel extends ConsumerWidget {
  const _SelectionPanel({
    required this.point,
    required this.locating,
    required this.onUseCurrent,
    required this.onConfirm,
  });

  final LatLng? point;
  final bool locating;
  final VoidCallback? onUseCurrent;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selected = point;
    final name = selected == null
        ? null
        : ref.watch(placeNameProvider(selected)).value;
    return Material(
      color: theme.colorScheme.surface,
      elevation: 3,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (selected == null)
              Text(
                'Tap the map to choose a place',
                style: theme.textTheme.titleSmall,
              )
            else ...[
              Text(
                name ?? 'Selected place',
                style: theme.textTheme.titleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                formatCoordinates(selected),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onUseCurrent,
                    icon: locating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Symbols.my_location),
                    label: const Text('My location'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: onConfirm,
                    child: const Text('Use this place'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
