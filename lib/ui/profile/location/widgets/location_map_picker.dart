import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  late GoogleMapController mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final hsv = HSVColor.fromColor(primaryColor);
    return Scaffold(
      appBar: AppBar(title: const Text('Choose a place')),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: widget.initial ?? defaultMapCenter,
              zoom: 15,
            ),
            onTap: (point) => setState(() => _selected = point),
            markers: {
              if (_selected case final point?)
                Marker(
                  markerId: const MarkerId('selected'),
                  position: point,
                  icon: BitmapDescriptor.defaultMarkerWithHue(hsv.hue),
                ),
            },
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
