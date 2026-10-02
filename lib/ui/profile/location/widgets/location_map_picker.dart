import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

const defaultMapCenter = LatLng(4.6014, -74.0661);
const mapTilesUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
const mapUserAgent = 'com.example.team12_flutter_juggle';

class LocationMapPicker extends StatefulWidget {
  const LocationMapPicker({super.key, this.initial});

  final LatLng? initial;

  @override
  State<LocationMapPicker> createState() => _LocationMapPickerState();
}

class _LocationMapPickerState extends State<LocationMapPicker> {
  late LatLng? _selected = widget.initial;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Choose a place')),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: widget.initial ?? defaultMapCenter,
              initialZoom: 15,
              onTap: (_, point) => setState(() => _selected = point),
            ),
            children: [
              TileLayer(
                urlTemplate: mapTilesUrl,
                userAgentPackageName: mapUserAgent,
              ),
              if (_selected case final point?)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: point,
                      width: 48,
                      height: 48,
                      alignment: Alignment.topCenter,
                      child: Icon(
                        Symbols.location_on,
                        fill: 1,
                        size: 48,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              const SimpleAttributionWidget(
                source: Text('OpenStreetMap contributors'),
              ),
            ],
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: Center(
              child: FilledButton(
                onPressed: _selected == null
                    ? null
                    : () => context.pop(_selected),
                child: const Text('Use this place'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
