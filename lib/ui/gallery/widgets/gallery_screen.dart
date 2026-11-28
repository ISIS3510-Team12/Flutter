import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:team12_flutter_juggle/data/local/pending_op.dart';
import 'package:team12_flutter_juggle/domain/models/gallery/project_photo.dart';
import 'package:team12_flutter_juggle/domain/models/gallery/saved_photo.dart';
import 'package:team12_flutter_juggle/ui/core/network/connectivity_provider.dart';
import 'package:team12_flutter_juggle/ui/core/routing/routes.dart';
import 'package:team12_flutter_juggle/ui/core/sync/sync_providers.dart';
import 'package:team12_flutter_juggle/ui/core/ui/custom_navigation_bar.dart';
import 'package:team12_flutter_juggle/ui/core/ui/load_error_view.dart';
import 'package:team12_flutter_juggle/ui/core/ui/offline_banner.dart';
import 'package:team12_flutter_juggle/ui/gallery/view_models/gallery_providers.dart';
import 'package:team12_flutter_juggle/ui/gallery/view_models/gallery_view_model.dart';
import 'package:team12_flutter_juggle/ui/gallery/widgets/add_photo_sheet.dart';
import 'package:team12_flutter_juggle/ui/gallery/widgets/gallery_filter.dart';
import 'package:team12_flutter_juggle/ui/gallery/widgets/gallery_image.dart';
import 'package:team12_flutter_juggle/ui/gallery/widgets/photo_tile.dart';
import 'package:team12_flutter_juggle/ui/telemetry/feature_names.dart';
import 'package:team12_flutter_juggle/ui/telemetry/feature_session_mixin.dart';
import 'package:team12_flutter_juggle/ui/telemetry/screen_load_tracker.dart';
import 'package:team12_flutter_juggle/ui/telemetry/screen_names.dart';

class GalleryScreen extends ConsumerStatefulWidget {
  const GalleryScreen({
    super.key,
    required this.projectId,
    this.picker = pickPhotos,
  });

  final int projectId;
  final PhotoPicker picker;

  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen>
    with FeatureSessionMixin<GalleryScreen> {
  @override
  String get featureName => FeatureNames.projectGallery;

  GalleryFilterMode _filter = GalleryFilterMode.all;

  Future<void> _addPhotos() async {
    final source = await showAddPhotoSheet(context);
    if (source == null) return;
    final List<String> paths;
    try {
      paths = await widget.picker(source);
    } catch (_) {
      _notify("We couldn't open your photos. Check the app permissions.");
      return;
    }
    if (paths.isEmpty || !mounted) return;
    markFeatureCompleted();
    final importer = ref.read(photoImportViewModelProvider.notifier);
    if (!ref.read(isOnlineProvider)) {
      _notify("Saved on this device. It will upload when you're back online.");
    }
    final failed = await importer.addPhotos(widget.projectId, paths);
    if (failed > 0) {
      _notify(
        failed == 1
            ? "A photo couldn't be prepared."
            : "$failed photos couldn't be prepared.",
      );
    }
  }

  void _notify(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _resolveFailed(PendingOp op) async {
    final sync = ref.read(outboxSyncServiceProvider);
    final retry = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Upload failed'),
        content: const Text('This photo could not be uploaded.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Discard'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
    if (retry == null) return;
    await (retry ? sync.retry(op.id) : sync.discard(op.id));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = galleryViewModelProvider(widget.projectId);
    final state = ref.watch(provider);

    return ScreenLoadTracker(
      screen: ScreenNames.projectGallery,
      state: state,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          titleSpacing: 0,
          title: Text('Gallery', style: theme.textTheme.titleMedium),
        ),
        bottomNavigationBar: const CustomNavigationBar(),
        floatingActionButton: _filter == GalleryFilterMode.all && state.hasValue
            ? FloatingActionButton.extended(
                backgroundColor: theme.colorScheme.primaryFixed,
                foregroundColor: theme.colorScheme.onPrimaryFixed,
                onPressed: _addPhotos,
                icon: const Icon(Symbols.add_a_photo),
                label: const Text('Add photo'),
              )
            : null,
        body: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: state.when(
                skipLoadingOnReload: true,
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => LoadErrorView(
                  error: error,
                  offlineMessage:
                      "You're offline. Reconnect to load these photos.",
                  genericMessage: "We couldn't load the project photos.",
                  onRetry: () => ref.invalidate(provider),
                ),
                data: _buildContent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(GalleryState gallery) {
    final theme = Theme.of(context);
    final count = gallery.photos.length;
    final subtitle = !gallery.listAvailable
        ? gallery.projectName
        : '${gallery.projectName} · $count ${count == 1 ? 'photo' : 'photos'}';

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          sliver: SliverList.list(
            children: [
              Text('Photo gallery', style: theme.textTheme.titleLarge),
              Text(
                subtitle,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: GalleryFilter(
                  selected: _filter,
                  onSelected: (filter) => setState(() => _filter = filter),
                ),
              ),
            ],
          ),
        ),
        if (_filter == GalleryFilterMode.all)
          ..._allPhotos(gallery)
        else
          ..._savedPhotos(),
        const SliverToBoxAdapter(child: SizedBox(height: 96)),
      ],
    );
  }

  List<Widget> _allPhotos(GalleryState gallery) {
    final online = ref.watch(isOnlineProvider);
    final pending = [
      for (final op
          in ref.watch(pendingOpsProvider).value ?? const <PendingOp>[])
        if (op.type == PendingOpType.uploadProjectPhoto &&
            op.projectId == widget.projectId)
          op,
    ].reversed.toList();
    final progress =
        ref.watch(uploadProgressProvider).value ?? const <String, double>{};
    final processing =
        ref.watch(photoImportViewModelProvider)[widget.projectId] ?? 0;
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final recent = [
      for (final photo in gallery.photos)
        if (photo.createdAt.isAfter(weekAgo)) photo,
    ];
    final earlier = [
      for (final photo in gallery.photos)
        if (!photo.createdAt.isAfter(weekAgo)) photo,
    ];
    final uploading = [
      for (var i = 0; i < processing; i++)
        const PhotoTile(
          label: 'Preparing photo',
          onTap: null,
          child: Center(child: Text('Preparing...')),
        ),
      for (final op in pending)
        PendingPhotoTile(
          op: op,
          progress: progress[op.id],
          isOnline: online,
          onFailedTap: () => _resolveFailed(op),
        ),
    ];

    return [
      if (!gallery.listAvailable) ...[
        _message(
          online ? "We couldn't load the photos right now." : "Photos not loaded yet. Reconnect to see this project's photos.",
        ),
        if (online)
          SliverToBoxAdapter(
            child: TextButton(
              onPressed: () =>
                  ref.invalidate(galleryViewModelProvider(widget.projectId)),
              child: const Text('Try again'),
            ),
          ),
      ] else if (gallery.fromCache)
        _message('Showing saved information. It may be outdated.'),
      if (uploading.isNotEmpty) ...[_label('Uploads'), _grid(uploading)],
      if (recent.isNotEmpty) ...[
        _label('This week'),
        _grid([for (final photo in recent) _remoteTile(photo)]),
      ],
      if (earlier.isNotEmpty) ...[
        _label('Earlier'),
        _grid([for (final photo in earlier) _remoteTile(photo)]),
      ],
      if (gallery.listAvailable && gallery.photos.isEmpty && uploading.isEmpty)
        SliverToBoxAdapter(child: _EmptyGallery(onAdd: _addPhotos)),
    ];
  }

  List<Widget> _savedPhotos() {
    final saved = ref.watch(savedPhotosProvider(widget.projectId));
    return saved.when(
      loading: () => [
        const SliverToBoxAdapter(
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
      error: (_, _) => [_message("We couldn't read your saved photos.")],
      data: (photos) => [
        if (photos.isEmpty)
          _message('No saved photos yet. Open a photo and tap Save to device.')
        else ...[
          _label('Saved on this device · available offline'),
          _grid([for (final photo in photos) _savedTile(photo)]),
        ],
      ],
    );
  }

  Widget _remoteTile(ProjectPhoto photo) {
    return PhotoTile(
      label: 'Photo added by ${photo.uploaderName}',
      onTap: () => context.push(
        Routes.projectPhotoViewerPath(widget.projectId, photo.id),
      ),
      child: GalleryImage(
        photo: photo,
        thumbnail: true,
        offlineMessage: 'Not available offline',
      ),
    );
  }

  Widget _savedTile(SavedPhoto saved) {
    return PhotoTile(
      label: 'Saved photo added by ${saved.photo.uploaderName}',
      onTap: () => context.push(
        Routes.projectPhotoViewerPath(
          widget.projectId,
          saved.photo.id,
          saved: true,
        ),
      ),
      child: Image.file(
        File(saved.filePath),
        fit: BoxFit.cover,
        cacheWidth: 400,
        errorBuilder: (_, _, _) =>
            const Center(child: Icon(Symbols.broken_image)),
      ),
    );
  }

  Widget _grid(List<Widget> tiles) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid.count(
        crossAxisCount: 3,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        children: tiles,
      ),
    );
  }

  Widget _label(String text) {
    final theme = Theme.of(context);
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      sliver: SliverToBoxAdapter(
        child: Text(
          text,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ),
    );
  }

  Widget _message(String text) {
    final theme = Theme.of(context);
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      sliver: SliverToBoxAdapter(
        child: Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _EmptyGallery extends StatelessWidget {
  const _EmptyGallery({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 48, 40, 0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 56,
            backgroundColor: theme.colorScheme.primaryFixed,
            child: Icon(
              Symbols.image,
              size: 52,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text('No photos yet', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            "Add photos to keep the team's progress, whiteboards and "
            'receipts in one place.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: onAdd, child: const Text('Add first photo')),
        ],
      ),
    );
  }
}
