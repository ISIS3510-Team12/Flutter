import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputField extends StatelessWidget {
  const InputField({
    super.key,
    required this.labelText,
    required this.icon,
    this.validator,
    this.obscureText,
    this.onSaved,
    this.onTogglePasswordVisibility,
    this.keyboardType,
    this.inputFormatters,
  });

  final String labelText;
  final IconData icon;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final bool? obscureText;
  final Function()? onTogglePasswordVisibility;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

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
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
    );
  }
}
