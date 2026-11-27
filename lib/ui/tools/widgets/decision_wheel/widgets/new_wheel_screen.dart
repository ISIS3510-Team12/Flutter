import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  static const _background = Color(0xFFF5F5F7);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'New wheel',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Wheel name',
                  hintText: 'e.g. What should I do?',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Options',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Text(
                    '${_options.length} of $_maxOptions',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Expanded(
                child: _options.isEmpty
                    ? const Center(
                        child: Text(
                          'Add at least two options to your wheel',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
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
                            color: _background,
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
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              trailing: IconButton(
                                tooltip: 'Remove option',
                                icon: const Icon(Icons.close),
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
                    foregroundColor: _indigo,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed:
                      _saving || _remainingOptions <= 0
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
    return AlertDialog(
      title: const Text('Add option'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(
          hintText: 'Enter an option',
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