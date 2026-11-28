import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:team12_flutter_juggle/data/db/app_database.dart';
import 'package:team12_flutter_juggle/data/sync/sync_status.dart';
import 'package:team12_flutter_juggle/ui/core/network/connectivity_provider.dart';
import 'package:team12_flutter_juggle/ui/core/ui/custom_navigation_bar.dart';
import 'package:team12_flutter_juggle/ui/core/sync/sync_providers.dart';
import 'package:team12_flutter_juggle/ui/core/ui/offline_banner.dart';
import 'package:team12_flutter_juggle/ui/tools/widgets/decision_wheel/view_models/decision_wheel_view_model_provider.dart';

import 'decision_wheel_painter.dart';

class WheelEditorScreen extends ConsumerStatefulWidget {
  final WheelRow wheel;

  const WheelEditorScreen({
    required this.wheel,
    super.key,
  });

  @override
  ConsumerState<WheelEditorScreen> createState() =>
      _WheelEditorScreenState();
}

class _WheelEditorScreenState extends ConsumerState<WheelEditorScreen>
    with SingleTickerProviderStateMixin {
  static const Color _indigo = Color(0xFF5455A9);
  static const int _maxOptions = 12;

  late String wheelName;

  ProviderSubscription<bool>? _connectivitySubscription;
  ProviderSubscription<AsyncValue<SyncStatus>>? _syncStatusSubscription;

  bool _wasSyncing = false;

  late Future<List<WheelOptionRow>> optionsFuture;
  late final AnimationController _spinController;

  double _wheelRotation = 0;
  bool _isSpinning = false;

  @override
  void initState() {
    super.initState();

    wheelName = widget.wheel.name;
    optionsFuture = _loadOptions();

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    );

    _listenToConnectivity();
    _listenToSyncStatus();
  }

  @override
  void dispose() {
    _connectivitySubscription?.close();
    _syncStatusSubscription?.close();
    _spinController.dispose();
    super.dispose();
  }

  void _listenToConnectivity() {
    _connectivitySubscription = ref.listenManual<bool>(
      isOnlineProvider,
      (previous, next) {
        if (previous == false && next == true) {
          _refreshOptions();
        }
      },
    );
  }

  void _listenToSyncStatus() {
    _syncStatusSubscription = ref.listenManual<AsyncValue<SyncStatus>>(
      syncStatusProvider,
      (previous, next) {
        final status = next.asData?.value;

        if (status == null) return;

        final isSyncing = status.isSyncing;

        if (_wasSyncing && !isSyncing && ref.read(isOnlineProvider)) {
          _refreshOptions();
        }

        _wasSyncing = isSyncing;
      },
    );
  }

  Future<List<WheelOptionRow>> _loadOptions() {
    return ref
        .read(decisionWheelViewModelProvider.notifier)
        .getOptions(widget.wheel.id);
  }

  Future<void> _refreshOptions() async {
    if (!mounted) return;

    setState(() {
      optionsFuture = _loadOptions();
    });
  }

  void _handleError(String message, Object error) {
    debugPrint('$message: $error');

    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$message: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _showResultSheet({
    required String title,
    required Future<void> Function() onSpinAgain,
    required Future<void> Function() onRemove,
  }) async {
    final colorScheme = Theme.of(context).colorScheme;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      builder: (sheetContext) {
        final sheetColors = Theme.of(sheetContext).colorScheme;

        return Container(
          decoration: BoxDecoration(
            color: sheetColors.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: sheetColors.onSurfaceVariant.withValues(
                        alpha: 0.3,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'The wheel chose',
                  style: TextStyle(
                    color: sheetColors.onSurfaceVariant,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: _indigo,
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: _indigo,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      onSpinAgain();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Spin again'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 50,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _indigo,
                      side: const BorderSide(color: _indigo),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(sheetContext);

                      try {
                        await onRemove();
                      } catch (error) {
                        _handleError(
                          'Could not remove the option',
                          error,
                        );
                      }
                    },
                    child: const Text('Remove from the wheel'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _animateWheelToOption({
    required List<String> options,
    required int selectedIndex,
  }) async {
    if (options.isEmpty) {
      throw StateError('The wheel has no options.');
    }

    if (selectedIndex < 0 || selectedIndex >= options.length) {
      throw StateError('The selected segment does not exist.');
    }

    final fullTurn = 2 * math.pi;
    final segmentAngle = fullTurn / options.length;

    final targetAngle =
        -(selectedIndex * segmentAngle + segmentAngle / 2);

    final currentAngle = _wheelRotation % fullTurn;
    final remainingAngle = (targetAngle - currentAngle) % fullTurn;

    final finalRotation =
        _wheelRotation + (5 * fullTurn) + remainingAngle;

    final curvedAnimation = CurvedAnimation(
      parent: _spinController,
      curve: Curves.easeOutCubic,
    );

    final animation = Tween<double>(
      begin: _wheelRotation,
      end: finalRotation,
    ).animate(curvedAnimation);

    void updateRotation() {
      if (!mounted) return;

      setState(() {
        _wheelRotation = animation.value;
      });
    }

    animation.addListener(updateRotation);

    try {
      await _spinController.forward(from: 0);
    } finally {
      animation.removeListener(updateRotation);
      curvedAnimation.dispose();
    }
  }

  Future<void> _spinWheel() async {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
    });

    try {
      final viewModel =
          ref.read(decisionWheelViewModelProvider.notifier);

      final options = await optionsFuture;

      if (!mounted) return;

      if (options.length < 2) {
        throw StateError(
          'Add at least two options before spinning.',
        );
      }

      final selectedOption = await viewModel.spinWheel(
        widget.wheel.id,
        options: options,
      );

      if (!mounted) return;

      final selectedIndex = options.indexWhere(
        (option) => option.id == selectedOption.id,
      );

      if (selectedIndex == -1) {
        throw StateError(
          'The selected option was not found in the wheel.',
        );
      }

      final optionTexts = options
          .map((option) => option.optionText)
          .toList();

      await _animateWheelToOption(
        options: optionTexts,
        selectedIndex: selectedIndex,
      );

      if (!mounted) return;

      setState(() {
        _isSpinning = false;
      });

      await _showResultSheet(
        title: selectedOption.optionText,
        onSpinAgain: _spinWheel,
        onRemove: () async {
          await viewModel.deleteOption(selectedOption.id);

          if (!mounted) return;

          await _refreshOptions();
        },
      );
    } catch (error) {
      _handleError('Could not spin the wheel', error);
    } finally {
      if (mounted && _isSpinning) {
        setState(() {
          _isSpinning = false;
        });
      }
    }
  }

  Future<void> _showOptionDialog({
    WheelOptionRow? option,
  }) async {
    if (_isSpinning) return;

    final currentOptions = await optionsFuture;

    if (!mounted) return;

    if (option == null && currentOptions.length >= _maxOptions) {
      _handleError(
        'Maximum number of options reached',
        StateError('A wheel can have up to $_maxOptions options.'),
      );
      return;
    }

    final text = await showDialog<String>(
      context: context,
      builder: (_) => _WheelOptionDialog(
        initialText: option?.optionText ?? '',
        isEditing: option != null,
      ),
    );

    if (!mounted || text == null || text.trim().isEmpty) return;

    final viewModel =
        ref.read(decisionWheelViewModelProvider.notifier);

    try {
      if (option == null) {
        await viewModel.addOption(
          widget.wheel.id,
          text.trim(),
        );
      } else {
        await viewModel.editOption(
          option.id,
          text.trim(),
        );
      }

      if (!mounted) return;

      await _refreshOptions();
    } catch (error) {
      _handleError('Could not save option', error);
    }
  }

  Future<void> _deleteOption(WheelOptionRow option) async {
    if (_isSpinning) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Remove option'),
          content: Text(
            'Remove "${option.optionText}" from this wheel?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) return;

    try {
      await ref
          .read(decisionWheelViewModelProvider.notifier)
          .deleteOption(option.id);

      if (!mounted) return;

      await _refreshOptions();
    } catch (error) {
      _handleError('Could not remove option', error);
    }
  }

  Future<void> _renameWheel() async {
    if (_isSpinning) return;

    final name = await showDialog<String>(
      context: context,
      builder: (_) => _RenameWheelDialog(
        initialName: wheelName,
      ),
    );

    if (!mounted || name == null || name.trim().isEmpty) return;

    try {
      await ref
          .read(decisionWheelViewModelProvider.notifier)
          .renameWheel(widget.wheel.id, name.trim());

      if (!mounted) return;

      setState(() {
        wheelName = name.trim();
      });
    } catch (error) {
      _handleError('Could not rename wheel', error);
    }
  }

  Future<void> _showWheelActions() async {
    if (_isSpinning) return;

    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.edit_outlined,
                  color: _indigo,
                ),
                title: const Text('Rename wheel'),
                onTap: () => Navigator.pop(sheetContext, 'rename'),
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
                title: const Text(
                  'Delete wheel',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () => Navigator.pop(sheetContext, 'delete'),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted || action == null) return;

    if (action == 'rename') {
      await _renameWheel();
    } else if (action == 'delete') {
      await _deleteWheel();
    }
  }

  Future<void> _deleteWheel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete wheel'),
          content: Text(
            'Are you sure you want to delete "$wheelName"? '
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) return;

    try {
      await ref
          .read(decisionWheelViewModelProvider.notifier)
          .deleteWheel(widget.wheel.id);

      if (!mounted) return;

      Navigator.of(context).pop();
    } catch (error) {
      _handleError('Could not delete wheel', error);
    }
  }

  Widget _buildWheel({
    required List<String> options,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: SizedBox(
        width: 320,
        height: 340,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              top: 18,
              left: 10,
              right: 10,
              bottom: 0,
              child: CustomPaint(
                painter: DecisionWheelPainter(
                  options: options,
                  rotation: _wheelRotation,
                  centerColor: colorScheme.surface,
                  borderColor: colorScheme.outline,
                  separatorColor: colorScheme.surface,
                ),
              ),
            ),
            const Positioned(
              top: 0,
              child: Icon(
                Icons.arrow_drop_down,
                color: _indigo,
                size: 48,
              ),
            ),
            Positioned(
              top: 18 + 160 - 19,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _indigo.withValues(alpha: 0.15),
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionChip(WheelOptionRow option) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: _isSpinning
          ? null
          : () => _showOptionDialog(option: option),
      onLongPress: _isSpinning
          ? null
          : () => _deleteOption(option),
      child: Container(
        margin: const EdgeInsets.only(right: 8, bottom: 8),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          border: Border.all(
            color: colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF2E9D50),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Color(0xFF2E9D50),
                size: 15,
              ),
            ),
            const SizedBox(width: 9),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 220),
              child: Text(
                option.optionText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWheelContent() {
    return FutureBuilder<List<WheelOptionRow>>(
      future: optionsFuture,
      builder: (context, snapshot) {
        final colorScheme = Theme.of(context).colorScheme;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Could not load wheel options: ${snapshot.error}',
                style: TextStyle(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          );
        }

        final options = snapshot.data ?? [];

        return Stack(
          children: [
            // Contenido desplazable. El padding inferior evita
            // que los últimos chips queden detrás del botón flotante.
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 4),
                  child: Text(
                    '${options.length} of $_maxOptions options',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                _buildWheel(
                  options: options
                      .map((option) => option.optionText)
                      .toList(),
                ),
                const SizedBox(height: 8),
                _buildSpinButton(
                  enabled: options.length >= 2,
                  onPressed: _spinWheel,
                ),
                const SizedBox(height: 20),

                if (options.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final option in options)
                        _buildOptionChip(option),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],

                if (options.isEmpty) ...[
                  const Icon(
                    Icons.casino_outlined,
                    size: 48,
                    color: _indigo,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your wheel is empty',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Add some options to get started.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ],
            ),

            // Botón flotante: conserva su posición y diseño.
            Positioned(
              right: 16,
              bottom: 16,
              child: ElevatedButton.icon(
                onPressed: _isSpinning
                ? null
                : () async {
                    if (options.length >= _maxOptions) {
                      _handleError(
                        'Maximum number of options reached',
                        StateError(
                          'A wheel can have up to $_maxOptions options.',
                        ),
                      );
                      return;
                    }

                    await _showOptionDialog();
                  },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text(
                  'Add Option',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSpinButton({
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: _indigo,
            foregroundColor: Colors.white,
            disabledBackgroundColor: _indigo.withValues(alpha: 0.35),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          onPressed: enabled && !_isSpinning ? onPressed : null,
          icon: const Icon(Icons.refresh),
          label: Text(
            _isSpinning ? 'Spinning...' : 'Spin the wheel',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final backgroundColor = theme.scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          wheelName,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 27,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Wheel options',
            onPressed: _isSpinning ? null : _showWheelActions,
            icon: const Icon(
              Icons.edit_outlined,
              color: _indigo,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: _buildWheelContent(),
          ),
        ],
      ),
      bottomNavigationBar: const CustomNavigationBar(),
    );
  }
}

class _WheelOptionDialog extends StatefulWidget {
  final String initialText;
  final bool isEditing;

  const _WheelOptionDialog({
    required this.initialText,
    required this.isEditing,
  });

  @override
  State<_WheelOptionDialog> createState() =>
      _WheelOptionDialogState();
}

class _WheelOptionDialogState extends State<_WheelOptionDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialText,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.pop(context, _controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.isEditing ? 'Edit option' : 'Add option',
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 60,
        decoration: const InputDecoration(
          labelText: 'Option',
          hintText: 'Enter an option',
        ),
        textCapitalization: TextCapitalization.sentences,
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(widget.isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}

class _RenameWheelDialog extends StatefulWidget {
  final String initialName;

  const _RenameWheelDialog({
    required this.initialName,
  });

  @override
  State<_RenameWheelDialog> createState() =>
      _RenameWheelDialogState();
}

class _RenameWheelDialogState extends State<_RenameWheelDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialName,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rename wheel'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 40,
        decoration: const InputDecoration(
          labelText: 'Wheel name',
        ),
        onSubmitted: (_) {
          Navigator.pop(context, _controller.text);
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context, _controller.text);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
