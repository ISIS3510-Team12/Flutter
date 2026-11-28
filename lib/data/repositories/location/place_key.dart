import 'package:google_maps_flutter/google_maps_flutter.dart';

String placeKey(LatLng point) =>
    '${point.latitude.toStringAsFixed(4)},${point.longitude.toStringAsFixed(4)}';
