import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

const offlineMapMessage =
    'Map unavailable offline. You can still pick a spot and save it.';

class OfflineMapNotice extends StatelessWidget {
  const OfflineMapNotice({super.key, this.detail});

  final String? detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final detail = this.detail;
    return Semantics(
      liveRegion: true,
      child: Material(
        color: scheme.surface.withValues(alpha: 0.9),
        elevation: 1,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(Symbols.wifi_off, size: 20, color: scheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(offlineMapMessage, style: theme.textTheme.bodySmall),
                    if (detail != null)
                      Text(
                        detail,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
