import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputField extends StatelessWidget {
  const InputField({
    super.key,
    required this.labelText,
    this.icon,
    this.fieldKey,
    this.validator,
    this.obscureText,
    this.onSaved,
    this.onChanged,
    this.onTogglePasswordVisibility,
    this.keyboardType,
    this.inputFormatters,
    this.autovalidateMode,
    this.maxLength,
  });

  final Key? fieldKey;
  final String labelText;
  final IconData? icon;
  final FormFieldValidator<String>? validator;
  final FormFieldSetter<String>? onSaved;
  final ValueChanged<String>? onChanged;
  final bool? obscureText;
  final Function()? onTogglePasswordVisibility;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final AutovalidateMode? autovalidateMode;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      key: fieldKey,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: theme.textTheme.bodyMedium,
        border: OutlineInputBorder(),
        prefixIcon: icon != null ? Icon(icon) : null,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: onTogglePasswordVisibility != null
            ? IconButton(
                icon: Icon(
                  obscureText == true
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                color: theme.colorScheme.onSurfaceVariant,
                onPressed: onTogglePasswordVisibility,
              )
            : null,
      ),
      validator: validator,
      onSaved: onSaved,
      onChanged: onChanged,
      obscureText: obscureText ?? false,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.disabled,
      maxLength: maxLength,
    );
  }
}
