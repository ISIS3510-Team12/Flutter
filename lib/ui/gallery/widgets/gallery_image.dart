import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:team12_flutter_juggle/data/cache/gallery_cache_manager.dart';
import 'package:team12_flutter_juggle/data/repositories/gallery/gallery_repository.dart';
import 'package:team12_flutter_juggle/domain/models/gallery/project_photo.dart';
import 'package:team12_flutter_juggle/ui/core/network/connectivity_provider.dart';

class GalleryImage extends ConsumerWidget {
  const GalleryImage({
    super.key,
    required this.photo,
    required this.offlineMessage,
    this.thumbnail = false,
    this.fit = BoxFit.cover,
    this.foreground,
  });

  final ProjectPhoto photo;
  final String offlineMessage;
  final bool thumbnail;
  final BoxFit fit;
  final Color? foreground;

  static const _compactSize = 72.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final online = ref.watch(isOnlineProvider);
    final color = foreground ?? theme.colorScheme.onSurfaceVariant;

    return CachedNetworkImage(
      key: ValueKey('${photo.id}-$thumbnail-$online'),
      imageUrl: projectPhotoPath(
        photo.projectId,
        photo.id,
        thumbnail: thumbnail,
      ),
      cacheKey: galleryImageCacheKey(photo.id, thumbnail: thumbnail),
      cacheManager: ref.watch(galleryCacheManagerProvider),
      fit: fit,
      placeholder: (context, url) =>
          const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      errorWidget: (context, url, error) => LayoutBuilder(
        builder: (context, constraints) {
          final icon = Icon(
            online ? Symbols.broken_image : Symbols.cloud_off,
            color: color,
            size: constraints.maxHeight < _compactSize ? 18 : 24,
          );
          if (constraints.maxHeight < _compactSize) return Center(child: icon);
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  icon,
                  const SizedBox(height: 4),
                  Text(
                    online ? "Couldn't load" : offlineMessage,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall?.copyWith(color: color),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
