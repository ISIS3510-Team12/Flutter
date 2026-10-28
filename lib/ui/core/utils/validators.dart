import 'package:flutter/services.dart';

class Validators {
  static const int maxNameLength = 50;
  static const int maxDescriptionLength = 200;
  static const int maxPersonNameLength = 20;

  static TextInputFormatter get emailTextInputFormatter =>
      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@._-]'));

  static TextInputFormatter get nameTextInputFormatter =>
      LengthLimitingTextInputFormatter(maxNameLength);

  static TextInputFormatter get personNameTextInputFormatter =>
      LengthLimitingTextInputFormatter(maxPersonNameLength);


  static TextInputFormatter get noEmojiTextInputFormatter =>
      FilteringTextInputFormatter.deny(
        RegExp(
          r'[\u{1F000}-\u{1FAFF}\u{2300}-\u{23FF}\u{2600}-\u{27BF}\u{2B00}-\u{2BFF}\u{FE0F}\u{200D}]',
          unicode: true,
        ),
      );

  static TextInputFormatter get noLeadingWhitespaceTextInputFormatter =>
      FilteringTextInputFormatter.deny(RegExp(r'^\s'));

  static List<TextInputFormatter> get descriptionTextInputFormatters => [
    LengthLimitingTextInputFormatter(maxDescriptionLength),
    noLeadingWhitespaceTextInputFormatter,
  ];

  static List<TextInputFormatter> get titleTextInputFormatters => [
    nameTextInputFormatter,
    noLeadingWhitespaceTextInputFormatter,
    noEmojiTextInputFormatter,
  ];

  static List<TextInputFormatter> get taskTitleTextInputFormatters => [
    noLeadingWhitespaceTextInputFormatter,
    noEmojiTextInputFormatter,
  ];

  static TextInputFormatter get passwordTextInputFormatter =>
      FilteringTextInputFormatter.deny(RegExp(r'\s'));


  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  static String? email(String? value) {
    final requiredError = required(value);
    if (requiredError != null) {
      return requiredError;
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value!.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? password(String? value) {
    final requiredError = required(value);
    if (requiredError != null) {
      return requiredError;
    }
    if (value!.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    return null;
  }

  static String? confirmPassword(String? value, String? originalPassword) {
    final requiredError = required(value);
    if (requiredError != null) {
      return requiredError;
    }
    if (value != originalPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? name(String? value) {
    final requiredError = required(value);
    if (requiredError != null) {
      return requiredError;
    }
    if (value!.trim().length > maxNameLength) {
      return 'Name must be at most $maxNameLength characters long';
    }
    return null;
  }

  static String? personName(String? value) {
    final requiredError = required(value);
    if (requiredError != null) {
      return requiredError;
    }
    if (value!.trim().length > maxPersonNameLength) {
      return 'Name must be at most $maxPersonNameLength characters long';
    }
    return null;
  }
}
