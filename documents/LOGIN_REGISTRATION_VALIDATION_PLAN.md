# Login and Registration Form Enhancement Plan

## Overview
This document outlines the implementation plan for enhancing the login and registration forms in the MASH Grower Mobile app with comprehensive input validation and email normalization features.

## Current State Analysis

### Existing Implementation
- **Authentication Provider**: `AuthProvider` handles login/registration logic
- **UI Screens**: Login and registration screens exist in `presentation/screens/auth/`
- **Firebase Integration**: Uses Firebase Auth for authentication
- **Backend Integration**: JWT token exchange with backend API

### Current Validation Status
- Basic email format validation may exist
- Password requirements not clearly defined
- No email case normalization
- Limited error handling for validation failures

## Requirements

### 1. Input Validation

#### Registration Form Validation
- **Email Validation**:
  - Required field
  - Valid email format (RFC 5322 compliant)
  - Unique email check (not already registered)
  - Automatic lowercase conversion

- **Password Validation**:
  - Minimum 8 characters
  - At least one uppercase letter
  - At least one lowercase letter
  - At least one number
  - At least one special character
  - Password confirmation matching

- **Name Validation**:
  - First name: Required, 2-50 characters, letters and spaces only
  - Last name: Required, 2-50 characters, letters and spaces only

- **Phone Number Validation** (if applicable):
  - Optional field
  - Valid Philippine phone number format
  - Automatic formatting (+63XXXXXXXXXX)

#### Login Form Validation
- **Email Validation**:
  - Required field
  - Valid email format
  - Automatic lowercase conversion

- **Password Validation**:
  - Required field
  - Non-empty password

### 2. Email Normalization
- **Case Insensitivity**: All emails stored in lowercase
- **Automatic Conversion**: Convert input email to lowercase before validation/API calls
- **Database Consistency**: Ensure backend stores emails in lowercase only
- **Display Preservation**: Show original case in UI but store/process in lowercase

### 3. User Experience Enhancements
- **Real-time Validation**: Validate fields as user types
- **Clear Error Messages**: Specific, actionable error messages
- **Loading States**: Show loading indicators during validation/API calls
- **Success Feedback**: Clear success messages for registration/login
- **Form Reset**: Clear form after successful registration

## Implementation Plan

### Phase 1: Core Validation Logic

#### 1.1 Create Validation Utilities
**File**: `lib/core/utils/validators.dart`

```dart
class Validators {
  // Email validation with normalization
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final normalizedEmail = value.toLowerCase().trim();

    // RFC 5322 compliant email regex
    final emailRegex = RegExp(r'^[a-zA-Z0-9.!#$%&\'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$');

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

    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(trimmed)) {
      return '$fieldName can only contain letters and spaces';
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
}
```

#### 1.2 Update AuthProvider
**File**: `lib/presentation/providers/auth_provider.dart`

Add email normalization to login and registration methods:

```dart
Future<void> login(String email, String password) async {
  final normalizedEmail = Validators.normalizeEmail(email);
  // Use normalizedEmail for authentication
}

Future<void> register(String email, String password, String firstName, String lastName) async {
  final normalizedEmail = Validators.normalizeEmail(email);
  // Use normalizedEmail for registration
}
```

### Phase 2: UI Implementation

#### 2.1 Update Registration Screen
**File**: `lib/presentation/screens/auth/registration_screen.dart`

- Add form validation using `TextFormField` validators
- Implement real-time validation feedback
- Add email normalization display logic
- Show validation errors clearly

#### 2.2 Update Login Screen
**File**: `lib/presentation/screens/auth/login_screen.dart`

- Add form validation
- Implement email normalization
- Add loading states and error handling

#### 2.3 Create Custom Form Widgets
**File**: `lib/presentation/widgets/common/validated_text_field.dart`

Create reusable validated text field widget:

```dart
class ValidatedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?) validator;
  final bool obscureText;
  final TextInputType keyboardType;
  final void Function(String)? onChanged;

  const ValidatedTextField({
    required this.controller,
    required this.label,
    required this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}
```

### Phase 3: Backend Integration

#### 3.1 Update API Calls
Ensure backend API endpoints handle email normalization:

- Registration endpoint should accept and store lowercase emails
- Login endpoint should be case-insensitive for email lookup
- Update user profile endpoints to handle email changes properly

#### 3.2 Database Schema Updates
- Ensure email fields in database are case-insensitive or stored in lowercase
- Add database constraints for email uniqueness (case-insensitive)

### Phase 4: Testing & Quality Assurance

#### 4.1 Unit Tests
**File**: `test/unit/validators_test.dart`

```dart
void main() {
  group('Validators', () {
    test('validateEmail normalizes case', () {
      expect(Validators.normalizeEmail('PP.NAMIAS@GMAIL.COM'), 'pp.namias@gmail.com');
    });

    test('validateEmail accepts valid emails', () {
      expect(Validators.validateEmail('test@example.com'), null);
      expect(Validators.validateEmail('user.name+tag@domain.co.uk'), null);
    });

    test('validateEmail rejects invalid emails', () {
      expect(Validators.validateEmail('invalid'), isNotNull);
      expect(Validators.validateEmail('@domain.com'), isNotNull);
    });

    test('validatePassword enforces requirements', () {
      expect(Validators.validatePassword('weak'), isNotNull);
      expect(Validators.validatePassword('StrongPass123!'), null);
    });
  });
}
```

#### 4.2 Integration Tests
- Test complete registration flow with email normalization
- Test login with different email cases
- Test form validation edge cases

#### 4.3 UI Tests
- Test validation error display
- Test real-time validation feedback
- Test form submission with valid/invalid data

## Success Criteria

### Functional Requirements
- [ ] Email input automatically converts to lowercase
- [ ] Registration validates all required fields
- [ ] Login validates email and password
- [ ] Backend stores emails in lowercase only
- [ ] Form shows clear validation errors
- [ ] Real-time validation provides immediate feedback

### Non-Functional Requirements
- [ ] Form validation is performant (no blocking operations)
- [ ] Error messages are user-friendly and actionable
- [ ] Email normalization works across all platforms
- [ ] Backward compatibility with existing user data

## Risk Assessment

### High Risk
- **Email Case Sensitivity**: Existing users with mixed-case emails
- **Backend Compatibility**: API may not handle case-insensitive email lookup
- **Data Migration**: Existing email data may need normalization

### Mitigation Strategies
- **Gradual Rollout**: Implement email normalization with backward compatibility
- **Data Migration Script**: Create script to normalize existing email data
- **API Versioning**: Ensure backward compatibility during transition

## Timeline

### Week 1: Planning & Design
- Complete validation requirements
- Design validation error messages
- Create mockups for enhanced forms

### Week 2: Core Implementation
- Implement validation utilities
- Update AuthProvider with email normalization
- Create custom form widgets

### Week 3: UI Implementation
- Update registration screen
- Update login screen
- Implement real-time validation

### Week 4: Backend Integration & Testing
- Update API integration
- Implement comprehensive tests
- Performance testing and optimization

### Week 5: Deployment & Monitoring
- Deploy to staging environment
- User acceptance testing
- Production deployment with monitoring

## Dependencies

### Internal Dependencies
- AuthProvider implementation
- Firebase Auth integration
- Backend API endpoints
- UI component library

### External Dependencies
- None (using existing Flutter/Dart capabilities)

## Monitoring & Analytics

### Key Metrics
- Form completion rate
- Validation error rate
- Registration success rate
- Login success rate
- Email normalization effectiveness

### Error Tracking
- Validation failure patterns
- API integration errors
- Email normalization issues

## Conclusion

This implementation plan provides a comprehensive approach to enhancing the login and registration forms with robust input validation and email normalization. The phased approach ensures quality implementation while minimizing risks to existing functionality.

The email normalization feature addresses the specific requirement of storing all emails in lowercase format, ensuring consistency across the system while maintaining user experience.</content>
<parameter name="filePath">LOGIN_REGISTRATION_VALIDATION_PLAN.md