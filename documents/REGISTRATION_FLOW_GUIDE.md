# Registration Flow Implementation Guide

## Overview
The registration flow has been completely revamped to align with the Figma design specifications. It now follows a multi-step wizard pattern with 6 distinct pages.

## Flow Structure

### Page 1: Email Entry (`email_page.dart`)
- **Purpose**: Collect user's email or username
- **Features**:
  - Email/username input field
  - Email validation
  - Social sign-up options (Google, Facebook)
  - Link to sign-in page
- **Action**: Sends OTP to email and navigates to verification page

### Page 2: OTP Verification (`otp_verification_page.dart`)
- **Purpose**: Verify email ownership via OTP
- **Features**:
  - 4-digit OTP input boxes
  - Auto-focus on next field
  - Resend OTP functionality with 60-second timer
  - Step indicator (1/4)
- **Action**: Verifies OTP and proceeds to profile setup

### Page 3: Profile Setup (`profile_setup_page.dart`)
- **Purpose**: Collect user's personal information
- **Features**:
  - First name (required)
  - Middle name (optional)
  - Last name (required)
  - Contact number with +639 country code
  - Step indicator (2/4)
  - Back/Next navigation
- **Action**: Stores profile data and proceeds to account setup

### Page 4: Account Setup (`account_setup_page.dart`)
- **Purpose**: Set up account details and address
- **Features**:
  - Profile photo upload (via image picker)
  - Username field
  - Philippine address selector (Region, Province, City, Barangay)
  - Street address input
  - Step indicator (3/4)
  - Back/Next navigation
- **Action**: Stores account data and proceeds to password setup

### Page 5: Password Setup (`password_setup_page.dart`)
- **Purpose**: Create secure password
- **Features**:
  - Password field with visibility toggle
  - Confirm password field
  - Real-time password requirements validation:
    - At least 8 characters
    - At least one uppercase letter
    - At least one number
  - Visual indicators (red X / green checkmark)
  - Terms and policies agreement
  - Step indicator (4/4)
  - Back/Next navigation
- **Action**: Completes registration and creates account

### Page 6: Success Feedback (`success_page.dart`)
- **Purpose**: Confirm successful account creation
- **Features**:
  - Success icon with decorative background
  - Success message
  - "Great!" button to proceed to login
- **Action**: Navigates to login screen

## State Management

### RegistrationProvider (`registration_provider.dart`)
Manages all registration state across the flow:

**State Variables**:
- Email/username
- OTP and verification status
- Profile information (first, middle, last name, contact)
- Account details (username, address, profile image)
- Password and confirmation
- Loading states and error messages
- OTP timer

**Key Methods**:
- `sendOtp()`: Sends OTP to email
- `verifyOtp()`: Verifies OTP code
- `resendOtp()`: Resends OTP with timer reset
- `completeRegistration()`: Creates user account
- `reset()`: Clears all registration data

## UI Components

### RegistrationStepIndicator (`registration_step_indicator.dart`)
Reusable step indicator widget showing progress through the flow:
- Displays numbered circles (1-4)
- Shows checkmarks for completed steps
- Highlights current step
- Includes step labels (Verify, Profile, Account, Password)

## Design System

### Colors
- **Primary Green**: `#2D5F4C` - Used for buttons, active states, headings
- **Light Green**: `#9BC4A8` - Used for decorative elements
- **Background**: `#F5F5F5` - Light gray background
- **White**: `#FFFFFF` - Input fields, cards

### Typography
- **Headings**: Bold, dark green color
- **Body Text**: Regular weight, gray color
- **Labels**: Medium weight, dark gray

### Input Fields
- Border radius: 12px
- White background
- Gray border (#E0E0E0)
- Green border on focus (#2D5F4C, 2px)
- Padding: 16px horizontal, 16px vertical

### Buttons
- **Primary**: Green background, white text, 56px height
- **Secondary**: White background, gray border, 56px height
- Border radius: 12px
- No elevation

## Navigation Flow

```
Onboarding → Email Entry → OTP Verification → Profile Setup → Account Setup → Password Setup → Success → Login
```

## Integration Points

### Backend Integration (TODO)
The following methods in `RegistrationProvider` need backend integration:

1. **sendOtp()**: Call API to send OTP email
2. **verifyOtp()**: Call API to verify OTP code
3. **resendOtp()**: Call API to resend OTP
4. **completeRegistration()**: Call API to create user account with all collected data

### Data Structure for Backend
```dart
{
  'email': String,
  'firstName': String,
  'middleName': String,
  'lastName': String,
  'contactNumber': String, // Format: +639XXXXXXXXX
  'username': String,
  'address': {
    'region': String,
    'province': String,
    'city': String,
    'barangay': String,
    'street': String,
  },
  'password': String,
  'profileImage': String?, // Optional file path
}
```

## File Structure

```
lib/
├── presentation/
│   ├── providers/
│   │   └── registration_provider.dart
│   ├── screens/
│   │   └── auth/
│   │       ├── registration_flow_screen.dart
│   │       └── registration_pages/
│   │           ├── email_page.dart
│   │           ├── otp_verification_page.dart
│   │           ├── profile_setup_page.dart
│   │           ├── account_setup_page.dart
│   │           ├── password_setup_page.dart
│   │           └── success_page.dart
│   └── widgets/
│       └── registration/
│           └── registration_step_indicator.dart
```

## Dependencies Added

- `image_picker: ^1.1.2` - For profile photo upload

## Testing Checklist

- [ ] Email validation works correctly
- [ ] OTP timer counts down properly
- [ ] OTP resend functionality works
- [ ] All form validations work
- [ ] Step indicators update correctly
- [ ] Back navigation preserves data
- [ ] Profile photo upload works
- [ ] Address picker displays correctly
- [ ] Password requirements validate in real-time
- [ ] Success page navigates to login
- [ ] Social sign-up buttons show appropriate messages

## Future Enhancements

1. **Address Picker**: Implement full Philippine address database with cascading dropdowns
2. **Email Verification**: Integrate with actual email service
3. **Social Authentication**: Complete Google and Facebook sign-up integration
4. **Profile Photo**: Add image cropping and compression
5. **Username Availability**: Real-time username availability check
6. **Password Strength Meter**: Visual password strength indicator
7. **Analytics**: Track registration funnel drop-off points
8. **Error Handling**: More detailed error messages and recovery flows

## Notes

- The flow uses `PageView` with disabled swipe gestures to prevent accidental navigation
- All navigation is controlled programmatically via Next/Back buttons
- The `WillPopScope` widget handles Android back button to navigate to previous page
- Registration data is stored in `RegistrationProvider` until completion
- On success, all registration data is cleared via `reset()` method
