import 'package:flutter/material.dart';

enum GalleryFilterMode { all, saved }

class GalleryFilter extends StatelessWidget {
  const GalleryFilter({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final GalleryFilterMode selected;
  final ValueChanged<GalleryFilterMode> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SegmentedButton<GalleryFilterMode>(
      showSelectedIcon: false,
      style: SegmentedButton.styleFrom(
        backgroundColor: colors.surfaceContainer,
        selectedBackgroundColor: colors.primary,
        selectedForegroundColor: colors.onPrimary,
        side: BorderSide.none,
      ),
      segments: const [
        ButtonSegment(value: GalleryFilterMode.all, label: Text('All')),
        ButtonSegment(value: GalleryFilterMode.saved, label: Text('Saved')),
      ],
      selected: {selected},
      onSelectionChanged: (selection) => onSelected(selection.first),
    );
  }
}
