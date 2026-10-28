import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:team12_flutter_juggle/ui/core/utils/validators.dart';
import 'package:team12_flutter_juggle/ui/tasks/widgets/task_form_widgets.dart';

class GroupNameDialog extends StatefulWidget {
  const GroupNameDialog({super.key});

  @override
  State<GroupNameDialog> createState() => _GroupNameDialogState();
}

class _GroupNameDialogState extends State<GroupNameDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Group'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          validator: Validators.name,
          inputFormatters: Validators.titleTextInputFormatters,
          decoration: InputDecoration(
            hintText: 'Group name',
            hintStyle: taskHintStyle(Theme.of(context)),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              context.pop(_controller.text.trim());
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
