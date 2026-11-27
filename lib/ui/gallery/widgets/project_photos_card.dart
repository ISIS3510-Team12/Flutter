import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:team12_flutter_juggle/ui/gallery/view_models/gallery_providers.dart';
import 'package:team12_flutter_juggle/ui/gallery/view_models/gallery_view_model.dart';
import 'package:team12_flutter_juggle/ui/gallery/widgets/gallery_image.dart';

class ProjectPhotosCard extends ConsumerWidget {
  const ProjectPhotosCard({
    super.key,
    required this.projectId,
    required this.onOpen,
  });

  final int projectId;
  final VoidCallback onOpen;

  static const _previews = 3;

  String _summary(AsyncValue<GalleryState> state) {
    final gallery = state.value;
    if (gallery == null) {
      return state.hasError ? "Couldn't load photos" : 'Loading photos...';
    }
    if (!gallery.listAvailable) return 'Photos not loaded yet';
    if (gallery.photos.isEmpty) return 'No photos yet';
    final count = gallery.photos.length;
    final noun = count == 1 ? 'photo' : 'photos';
    final last = DateFormat('MMM d').format(gallery.photos.first.createdAt);
    return '$count $noun · Last added $last';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(galleryViewModelProvider(projectId));
    final photos = state.value?.photos.take(_previews).toList() ?? const [];

    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Project photos', style: theme.textTheme.titleMedium),
                    Text(
                      _summary(state),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              for (final photo in photos)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox.square(
                      dimension: 40,
                      child: GalleryImage(
                        photo: photo,
                        thumbnail: true,
                        offlineMessage: '',
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: 4),
              const Icon(Symbols.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
