/// Password strength levels
enum PasswordStrength {
  weak,
  fair,
  good,
  strong,
  veryStrong,
}

/// Password strength result with detailed feedback
class PasswordStrengthResult {
  final PasswordStrength strength;
  final double score; // 0.0 to 1.0
  final String message;
  final List<String> suggestions;
  final Map<String, bool> requirements;

  const PasswordStrengthResult({
    required this.strength,
    required this.score,
    required this.message,
    required this.suggestions,
    required this.requirements,
  });

  bool get isValid => strength != PasswordStrength.weak;
  bool get isStrong => strength == PasswordStrength.strong || strength == PasswordStrength.veryStrong;
}

/// Comprehensive password strength validator
class PasswordStrengthValidator {
  /// Minimum required password length
  static const int minLength = 8;
  
  /// Recommended password length for strong security
  static const int recommendedLength = 12;

  /// List of common passwords to reject
  static final List<String> _commonPasswords = [
    'password', '12345678', 'qwerty', 'abc123', 'password1',
    'password123', '123456789', '1234567890', 'admin', 'letmein',
    'welcome', 'monkey', '111111', 'dragon', 'master', 'sunshine',
    'princess', 'iloveyou', 'rockyou', 'bailey', 'shadow',
  ];

  /// Validate password strength with detailed feedback
  static PasswordStrengthResult validate(String password) {
    final requirements = <String, bool>{
      'minLength': password.length >= minLength,
      'hasUppercase': RegExp(r'[A-Z]').hasMatch(password),
      'hasLowercase': RegExp(r'[a-z]').hasMatch(password),
      'hasNumber': RegExp(r'[0-9]').hasMatch(password),
      'hasSpecialChar': RegExp(r'[!@#$%^&*(),.?":{}|<>_+=\-\[\]\\;/`~]').hasMatch(password),
      'notCommon': !_commonPasswords.contains(password.toLowerCase()),
      'recommendedLength': password.length >= recommendedLength,
    };

    final suggestions = <String>[];
    int score = 0;

    // Calculate base score
    if (requirements['minLength']!) score += 10;
    if (requirements['hasUppercase']!) score += 15;
    if (requirements['hasLowercase']!) score += 15;
    if (requirements['hasNumber']!) score += 15;
    if (requirements['hasSpecialChar']!) score += 20;
    if (requirements['notCommon']!) score += 10;

    // Bonus points for length
    if (password.length >= 12) score += 5;
    if (password.length >= 16) score += 10;
    
    // Bonus for character variety
    final uniqueChars = password.split('').toSet().length;
    if (uniqueChars >= 8) score += 5;
    if (uniqueChars >= 12) score += 5;

    // Generate suggestions
    if (!requirements['minLength']!) {
      suggestions.add('Use at least $minLength characters');
    }
    if (!requirements['hasUppercase']!) {
      suggestions.add('Add uppercase letters (A-Z)');
    }
    if (!requirements['hasLowercase']!) {
      suggestions.add('Add lowercase letters (a-z)');
    }
    if (!requirements['hasNumber']!) {
      suggestions.add('Add numbers (0-9)');
    }
    if (!requirements['hasSpecialChar']!) {
      suggestions.add('Add special characters (!@#\$%^&*)');
    }
    if (!requirements['notCommon']!) {
      suggestions.add('Avoid common passwords');
    }
    if (!requirements['recommendedLength']!) {
      suggestions.add('Use at least $recommendedLength characters for better security');
    }

    // Check for sequential characters
    if (_hasSequentialChars(password)) {
      score -= 10;
      suggestions.add('Avoid sequential characters (abc, 123)');
    }

    // Check for repeated characters
    if (_hasRepeatedChars(password)) {
      score -= 10;
      suggestions.add('Avoid repeated characters (aaa, 111)');
    }

    // Normalize score to 0-100
    score = score.clamp(0, 100);
    final normalizedScore = score / 100.0;

    // Determine strength
    PasswordStrength strength;
    String message;

    if (score < 40) {
      strength = PasswordStrength.weak;
      message = 'Weak - Not recommended';
    } else if (score < 60) {
      strength = PasswordStrength.fair;
      message = 'Fair - Could be stronger';
    } else if (score < 75) {
      strength = PasswordStrength.good;
      message = 'Good - Acceptable security';
    } else if (score < 90) {
      strength = PasswordStrength.strong;
      message = 'Strong - Good security';
    } else {
      strength = PasswordStrength.veryStrong;
      message = 'Very Strong - Excellent security';
    }

    return PasswordStrengthResult(
      strength: strength,
      score: normalizedScore,
      message: message,
      suggestions: suggestions,
      requirements: requirements,
    );
  }

  /// Simple validation for form fields
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < minLength) {
      return 'Password must be at least $minLength characters long';
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

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_+=\-\[\]\\;/`~]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }

    if (_commonPasswords.contains(value.toLowerCase())) {
      return 'This password is too common. Please choose a different one';
    }

    return null; // Valid
  }

  /// Check if password contains sequential characters
  static bool _hasSequentialChars(String password) {
    final lower = password.toLowerCase();
    for (int i = 0; i < lower.length - 2; i++) {
      final char1 = lower.codeUnitAt(i);
      final char2 = lower.codeUnitAt(i + 1);
      final char3 = lower.codeUnitAt(i + 2);
      
      // Check for sequential ascending or descending
      if ((char2 == char1 + 1 && char3 == char2 + 1) ||
          (char2 == char1 - 1 && char3 == char2 - 1)) {
        return true;
      }
    }
    return false;
  }

  /// Check if password contains repeated characters
  static bool _hasRepeatedChars(String password) {
    for (int i = 0; i < password.length - 2; i++) {
      if (password[i] == password[i + 1] && password[i + 1] == password[i + 2]) {
        return true;
      }
    }
    return false;
  }

  /// Generate a strong random password
  static String generatePassword({
    int length = 16,
    bool includeUppercase = true,
    bool includeLowercase = true,
    bool includeNumbers = true,
    bool includeSpecialChars = true,
  }) {
    const uppercase = 'ABCDEFGHJKLMNPQRSTUVWXYZ'; // Removed I, O
    const lowercase = 'abcdefghjkmnpqrstuvwxyz'; // Removed i, l, o
    const numbers = '23456789'; // Removed 0, 1
    const specialChars = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

    String chars = '';
    if (includeUppercase) chars += uppercase;
    if (includeLowercase) chars += lowercase;
    if (includeNumbers) chars += numbers;
    if (includeSpecialChars) chars += specialChars;

    if (chars.isEmpty) {
      throw ArgumentError('At least one character type must be included');
    }

    final random = DateTime.now().millisecondsSinceEpoch;
    final password = StringBuffer();

    // Ensure at least one of each required type
    if (includeUppercase) {
      password.write(uppercase[(random % uppercase.length)]);
    }
    if (includeLowercase) {
      password.write(lowercase[(random % lowercase.length)]);
    }
    if (includeNumbers) {
      password.write(numbers[(random % numbers.length)]);
    }
    if (includeSpecialChars) {
      password.write(specialChars[(random % specialChars.length)]);
    }

    // Fill remaining length with random characters
    for (int i = password.length; i < length; i++) {
      password.write(chars[(random * i) % chars.length]);
    }

    // Shuffle the password
    final passwordList = password.toString().split('');
    passwordList.shuffle();
    
    return passwordList.join('');
  }
}
