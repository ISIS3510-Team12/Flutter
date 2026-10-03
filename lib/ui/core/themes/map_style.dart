import 'dart:convert';

import 'package:flutter/material.dart';

abstract final class AppMapStyle {
  static String of(ColorScheme scheme) {
    final dark = scheme.brightness == Brightness.dark;
    final water = dark ? scheme.onSecondaryFixedVariant : scheme.secondaryFixed;
    final park = dark ? scheme.onSecondaryFixed : scheme.secondaryFixedDim;
    final highway = dark ? scheme.onPrimaryFixedVariant : scheme.primaryFixed;

    return jsonEncode([
      _rule(null, 'geometry', scheme.surfaceContainerLow),
      _rule(null, 'labels.text.fill', scheme.onSurfaceVariant),
      _rule(null, 'labels.text.stroke', scheme.surface),
      _rule(
        'administrative',
        'geometry.stroke',
        scheme.surfaceContainerHighest,
      ),
      _rule('landscape', 'geometry', scheme.surfaceContainer),
      _rule('poi', 'geometry', scheme.surfaceContainerHigh),
      _rule('poi.park', 'geometry', park),
      _rule('road', 'geometry', scheme.surfaceContainerHighest),
      _rule('road', 'geometry.stroke', scheme.surface),
      _rule('road.arterial', 'geometry', scheme.surfaceContainerHighest),
      _rule('road.highway', 'geometry', highway),
      _rule('road', 'labels.text.fill', scheme.onSurface),
      _rule('transit', 'geometry', scheme.surfaceContainerHigh),
      _rule('water', 'geometry', water),
      _rule('water', 'labels.text.fill', scheme.onSecondaryContainer),
      {
        'featureType': 'poi.business',
        'stylers': [
          {'visibility': 'off'},
        ],
      },
    ]);
  }

  static Map<String, dynamic> _rule(
    String? feature,
    String element,
    Color color,
  ) {
    return {
      'featureType': ?feature,
      'elementType': element,
      'stylers': [
        {'color': _hex(color)},
      ],
    };
  }

  static String _hex(Color color) {
    final rgb = color.toARGB32() & 0xFFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0')}';
  }
}
