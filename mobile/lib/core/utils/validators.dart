class Validators {
  /// Required field validator
  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Email validator
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email';
    }
    return null;
  }

  /// Indian phone number validator
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    // Remove spaces, +91, and other formatting
    final cleaned = value.replaceAll(RegExp(r'[\s\-\+]'), '');
    final phoneRegex = RegExp(r'^(91)?[6-9]\d{9}$');
    if (!phoneRegex.hasMatch(cleaned)) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }

  /// Password validator - min 8 chars, at least 1 number
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'\d').hasMatch(value)) {
      return 'Password must contain at least 1 number';
    }
    return null;
  }

  /// Confirm password validator
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Minimum length validator
  static String? minLength(String? value, int min, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (value.trim().length < min) {
      return '$fieldName must be at least $min characters';
    }
    return null;
  }

  /// Instagram handle validator (optional, but must start with @ if provided)
  static String? instagramHandle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    if (!value.trim().startsWith('@')) {
      return 'Instagram handle must start with @';
    }
    if (value.trim().length < 2) {
      return 'Enter a valid Instagram handle';
    }
    return null;
  }
}
