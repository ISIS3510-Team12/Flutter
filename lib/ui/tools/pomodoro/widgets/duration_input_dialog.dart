import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DurationInputDialog extends StatefulWidget {
  const DurationInputDialog({
    super.key,
    required this.label,
    required this.minutes,
    required this.min,
    required this.max,
  });

  final String label;
  final int minutes;
  final int min;
  final int max;

  @override
  State<DurationInputDialog> createState() => _DurationInputDialogState();
}

class _DurationInputDialogState extends State<DurationInputDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _controller = TextEditingController(text: '${widget.minutes}')
    ..selection = TextSelection(
      baseOffset: 0,
      extentOffset: '${widget.minutes}'.length,
    );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(int.parse(_controller.text));
  }

  String? _validate(String? value) {
    final minutes = int.tryParse(value ?? '');
    if (minutes == null || minutes < widget.min || minutes > widget.max) {
      return 'Enter ${widget.min} to ${widget.max} minutes';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: Text('${widget.label} duration'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(suffixText: 'min'),
          validator: _validate,
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }
}
