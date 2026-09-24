class Validators {
  static String? required(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  static String? email(String? value) {
    final requiredError = required(value);
    if (requiredError != null) {
      return requiredError;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
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
    if (value!.length < 6) {
      return 'Name must be at least 6 characters long';
    }
    return null;
  }
}
