import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  const InputField({
    super.key,
    required this.labelText,
    required this.icon,
    this.validator,
    this.obscureText,
    this.onSaved,
    this.onTogglePasswordVisibility,
  });

  final String labelText;
  final IconData icon;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final bool? obscureText;
  final Function()? onTogglePasswordVisibility;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: theme.textTheme.bodyMedium,
        border: OutlineInputBorder(),
        prefixIcon: Icon(icon),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: onTogglePasswordVisibility != null
            ? IconButton(
                icon: Icon(
                  obscureText == true ? Icons.visibility_off : Icons.visibility,
                ),
                color: obscureText == true ? Colors.grey : theme.colorScheme.primary,
                onPressed: onTogglePasswordVisibility,
              )
            : null,
      ),
      validator: validator,
      onSaved: onSaved,
      obscureText: obscureText ?? false,
    );
  }
}
