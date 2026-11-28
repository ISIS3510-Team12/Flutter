import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:team12_flutter_juggle/domain/models/gallery/project_photo.dart';
import 'package:team12_flutter_juggle/domain/models/gallery/saved_photo.dart';
import 'package:team12_flutter_juggle/ui/core/network/connectivity_provider.dart';
import 'package:team12_flutter_juggle/ui/core/utils/network_exceptions.dart';
import 'package:team12_flutter_juggle/ui/gallery/view_models/gallery_providers.dart';
import 'package:team12_flutter_juggle/ui/gallery/widgets/gallery_image.dart';

class PhotoViewerScreen extends ConsumerStatefulWidget {
  const PhotoViewerScreen({
    super.key,
    required this.projectId,
    required this.photoId,
    this.savedOnly = false,
  });

  final int projectId;
  final int photoId;
  final bool savedOnly;

  @override
  ConsumerState<PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends ConsumerState<PhotoViewerScreen> {
  static const _background = Color(0xFF121212);

  PageController? _pages;
  late int _currentId = widget.photoId;
  bool _busy = false;

  @override
  void dispose() {
    _pages?.dispose();
    super.dispose();
  }

  void _notify(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _keepPage(PageController pages, int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !pages.hasClients) return;
      if (pages.position.isScrollingNotifier.value) return;
      if (pages.page?.round() != index) pages.jumpToPage(index);
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save(ProjectPhoto photo) => _run(() async {
    try {
      await ref
          .read(galleryViewModelProvider(widget.projectId).notifier)
          .saveToDevice(photo);
      _notify('Saved on this device.');
    } catch (_) {
      _notify(
        ref.read(isOnlineProvider)
            ? "We couldn't save this photo."
            : 'Reconnect to save this photo.',
      );
    }
  });

  Future<void> _remove(int photoId) => _run(() async {
    try {
      await ref
          .read(galleryViewModelProvider(widget.projectId).notifier)
          .removeFromDevice(photoId);
      _notify('Removed from this device.');
      if (widget.savedOnly && mounted) context.pop();
    } catch (_) {
      _notify("We couldn't remove this photo.");
    }
  });

  Future<void> _delete(int photoId) async {
    if (!ref.read(isOnlineProvider)) {
      _notify('Reconnect to delete this photo.');
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete photo'),
        content: const Text(
          'It will be removed from the project for everyone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _run(() async {
      try {
        await ref
            .read(galleryViewModelProvider(widget.projectId).notifier)
            .deletePhoto(photoId);
        if (mounted) context.pop();
      } catch (error) {
        _notify(
          writeFailureMessage(
            error,
            isOnline: ref.read(isOnlineProvider),
            fallback: "We couldn't delete this photo.",
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final gallery = ref.watch(galleryViewModelProvider(widget.projectId));
    final saved = ref.watch(savedPhotosProvider(widget.projectId));
    final savedById = {
      for (final item in saved.value ?? const <SavedPhoto>[])
        item.photo.id: item,
    };
    final photos = widget.savedOnly
        ? [for (final item in savedById.values) item.photo]
        : gallery.value?.photos ?? const <ProjectPhoto>[];
    final loading = widget.savedOnly ? saved.isLoading : gallery.isLoading;

    if (photos.isEmpty) {
      return Scaffold(
        backgroundColor: _background,
        appBar: AppBar(
          backgroundColor: _background,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: loading
              ? const CircularProgressIndicator()
              : const Text(
                  'This photo is no longer available.',
                  style: TextStyle(color: Colors.white),
                ),
        ),
      );
    }

    var index = photos.indexWhere((photo) => photo.id == _currentId);
    if (index < 0) {
      index = 0;
      _currentId = photos.first.id;
    }
    final pages = _pages ??= PageController(initialPage: index);
    _keepPage(pages, index);
    final photo = photos[index];
    final copy = savedById[photo.id];
    final isMine = gallery.value?.userId == photo.uploaderId;
    final projectName = copy?.projectName ?? gallery.value?.projectName ?? '';

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: Colors.white,
        leading: IconButton(
          tooltip: 'Close',
          icon: const Icon(Symbols.close),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Text(
          '${index + 1} of ${photos.length}',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: pages,
                itemCount: photos.length,
                onPageChanged: (page) =>
                    setState(() => _currentId = photos[page].id),
                itemBuilder: (context, page) {
                  final item = photos[page];
                  final local = savedById[item.id];
                  return InteractiveViewer(
                    maxScale: 5,
                    child: local != null
                        ? Image.file(File(local.filePath), fit: BoxFit.contain)
                        : GalleryImage(
                            photo: item,
                            fit: BoxFit.contain,
                            foreground: Colors.white,
                            offlineMessage:
                                'Reconnect to see this photo in full size.',
                          ),
                  );
                },
              ),
            ),
            _PhotoDetails(
              photo: photo,
              projectName: projectName,
              isSaved: copy != null,
              busy: _busy,
              onToggleSaved: () =>
                  copy == null ? _save(photo) : _remove(photo.id),
              onDelete: isMine && !widget.savedOnly
                  ? () => _delete(photo.id)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoDetails extends StatelessWidget {
  const _PhotoDetails({
    required this.photo,
    required this.projectName,
    required this.isSaved,
    required this.busy,
    required this.onToggleSaved,
    required this.onDelete,
  });

  final ProjectPhoto photo;
  final String projectName;
  final bool isSaved;
  final bool busy;
  final VoidCallback onToggleSaved;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: const Color(0xFFC4C7C7),
    );
    final date = DateFormat('MMMM d, y').format(photo.createdAt);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (photo.caption case final caption?)
            Text(
              caption,
              style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
            ),
          Text('Added by ${photo.uploaderName} · $date', style: muted),
          Text(projectName, style: muted),
          if (isSaved) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colors.secondaryFixed,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Saved on this device',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.onSecondaryFixed,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: colors.primaryFixed,
                  foregroundColor: colors.onPrimaryFixed,
                ),
                onPressed: busy ? null : onToggleSaved,
                child: Text(isSaved ? 'Remove from device' : 'Save to device'),
              ),
              if (onDelete != null)
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.errorContainer,
                    foregroundColor: colors.onErrorContainer,
                  ),
                  onPressed: busy ? null : onDelete,
                  child: const Text('Delete'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
