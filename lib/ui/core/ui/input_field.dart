import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  const InputField({super.key, required this.labelText, required this.icon, this.validator, this.onSaved});

  final String labelText;
  final IconData icon;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
        prefixIcon: Icon(icon),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: validator,
      onSaved: onSaved,
    );
  }
}
