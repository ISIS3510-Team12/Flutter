import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/ui/core/ui/offline_banner.dart';
import 'package:team12_flutter_juggle/ui/tools/widgets/decision_wheel/view_models/decision_wheel_view_model_provider.dart';

class NewWheelScreen extends ConsumerStatefulWidget {
  const NewWheelScreen({super.key});

  @override
  ConsumerState<NewWheelScreen> createState() => _NewWheelScreenState();
}

class _NewWheelScreenState extends ConsumerState<NewWheelScreen> {
  final _nameController = TextEditingController();
  final _options = <String>[];

  bool _saving = false;

  static const _indigo = Color(0xFF5455A9);
  static const int _maxOptions = 12;

  int get _remainingOptions => _maxOptions - _options.length;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _addOption() async {
    if (_remainingOptions <= 0) {
      _showMessage('Maximum of 12 options allowed');
      return;
    }

    final text = await showDialog<String>(
      context: context,
      builder: (_) => const _OptionDialog(),
    );

    if (!mounted || text == null || text.trim().isEmpty) return;

    if (_remainingOptions <= 0) {
      _showMessage('Maximum of 12 options allowed');
      return;
    }

    setState(() {
      _options.add(text.trim());
    });
  }

  Future<void> _saveWheel() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      _showMessage('Enter a wheel name');
      return;
    }

    if (_options.length < 2) {
      _showMessage('Add at least two options');
      return;
    }

    setState(() => _saving = true);

    try {
      final viewModel =
          ref.read(decisionWheelViewModelProvider.notifier);

      final wheelId = await viewModel.createWheel(name);

      for (final option in _options) {
        await viewModel.addOption(wheelId, option);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        _showMessage('Could not save wheel: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _removeOption(int index) {
    setState(() {
      _options.removeAt(index);
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        title: const Text(
          'New wheel',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.sentences,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Wheel name',
                        hintText: 'e.g. What should I do?',
                        labelStyle: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        hintStyle: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        border: const OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: colorScheme.outlineVariant,
                          ),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: _indigo,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Options',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.normal,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          '${_options.length} of $_maxOptions',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Expanded(
                      child: _options.isEmpty
                          ? Center(
                              child: Text(
                                'Add at least two options to your wheel',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            )
                          : ReorderableListView.builder(
                              itemCount: _options.length,
                              onReorderItem: (oldIndex, newIndex) {
                                setState(() {
                                  if (newIndex > oldIndex) {
                                    newIndex--;
                                  }

                                  final option = _options.removeAt(oldIndex);
                                  _options.insert(newIndex, option);
                                });
                              },
                              itemBuilder: (context, index) {
                                final option = _options[index];

                                return Card(
                                  key: ValueKey('option_$index'),
                                  elevation: 0,
                                  color: colorScheme.surfaceContainerHighest,
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: Container(
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
                                    title: Text(
                                      option,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      tooltip: 'Remove option',
                                      icon: Icon(
                                        Icons.close,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                      onPressed: () => _removeOption(index),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.primary,
                          side: BorderSide(
                            color: colorScheme.primary,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: _saving || _remainingOptions <= 0
                            ? null
                            : _addOption,
                        icon: const Icon(Icons.add),
                        label: const Text('Add option'),
                      ),
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: _indigo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: _saving ? null : _saveWheel,
                        child: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Save wheel'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionDialog extends StatefulWidget {
  const _OptionDialog();

  @override
  State<_OptionDialog> createState() => _OptionDialogState();
}

class _OptionDialogState extends State<_OptionDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addOption() {
    final text = _controller.text.trim();

    if (text.isEmpty) return;

    Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      backgroundColor: colorScheme.surface,
      title: Text(
        'Add option',
        style: TextStyle(color: colorScheme.onSurface),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        style: TextStyle(color: colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: 'Enter an option',
          hintStyle: TextStyle(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        onSubmitted: (_) => _addOption(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _addOption,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
