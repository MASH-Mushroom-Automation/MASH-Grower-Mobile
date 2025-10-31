class Validators {
  // Email validation with normalization
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final normalizedEmail = value.toLowerCase().trim();

    // Simple but effective email regex
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    if (!emailRegex.hasMatch(normalizedEmail)) {
      return 'Please enter a valid email address';
    }

    return null; // Valid
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }

    return null; // Valid
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != originalPassword) {
      return 'Passwords do not match';
    }

    return null; // Valid
  }

  // Name validation
  static String? validateName(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    final trimmed = value.trim();

    if (trimmed.length < 2) {
      return '$fieldName must be at least 2 characters long';
    }

    if (trimmed.length > 50) {
      return '$fieldName must not exceed 50 characters';
    }

    if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(trimmed)) {
      return '$fieldName can only contain letters, spaces, hyphens, and apostrophes';
    }

    return null; // Valid
  }

  // Phone validation (Philippine format)
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }

    final cleanNumber = value.replaceAll(RegExp(r'[^\d]'), '');

    // Check for Philippine mobile numbers
    if (cleanNumber.length == 11 && cleanNumber.startsWith('09')) {
      return null; // Valid Philippine mobile
    }

    if (cleanNumber.length == 12 && cleanNumber.startsWith('639')) {
      return null; // Valid international format
    }

    return 'Please enter a valid Philippine phone number';
  }

  // Email normalization
  static String normalizeEmail(String email) {
    return email.toLowerCase().trim();
  }

  // Format phone number for display
  static String formatPhoneNumber(String phone) {
    final cleanNumber = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanNumber.length == 11 && cleanNumber.startsWith('09')) {
      // Format as +63 XXX XXX XXXX
      return '+63 ${cleanNumber.substring(1, 4)} ${cleanNumber.substring(4, 7)} ${cleanNumber.substring(7)}';
    }

    if (cleanNumber.length == 12 && cleanNumber.startsWith('639')) {
      // Format as +63 XXX XXX XXXX
      return '+63 ${cleanNumber.substring(2, 5)} ${cleanNumber.substring(5, 8)} ${cleanNumber.substring(8)}';
    }

    return phone; // Return original if can't format
  }
}