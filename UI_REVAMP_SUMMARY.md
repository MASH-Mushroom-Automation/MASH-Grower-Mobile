# UI Revamp Summary - Based on Figma Designs

## Overview
This document outlines the UI revamp for Home, Onboarding, and Login screens based on the Figma designs in `assets/designs/`.

## Design Analysis

### 🎨 Design System Extracted from Figma

#### Colors
- **Primary Green**: `#2D5F4C` - Main brand color, buttons, headers
- **Light Gray Background**: `#F5F5F5` - Screen backgrounds
- **White**: `#FFFFFF` - Cards, input fields
- **Border Gray**: `#E0E0E0` - Input borders
- **Text Dark**: `#2D5F4C` - Headings
- **Text Gray**: `#666666` - Body text
- **Success Green**: `#4CAF50` - Success states
- **Error Red**: `#F44336` - Error states

#### Typography
- **Headings**: Bold, 20-24px, Dark Green (#2D5F4C)
- **Subheadings**: Medium, 16-18px
- **Body**: Regular, 14-16px, Gray
- **Labels**: Medium, 14px, Dark Gray

#### Components
- **Border Radius**: 12px for buttons and inputs
- **Button Height**: 56px
- **Input Height**: 56px
- **Spacing**: 16px, 24px, 32px, 40px

---

## 1. ✅ Onboarding Screen - COMPLETED

### Status: **IMPLEMENTED**

The onboarding screen has been successfully revamped with:
- **5 Pages** with unique color schemes per page
- **Full-screen immersive layout** with background colors
- **Modern navigation** with floating skip button
- **Animated page indicators**
- **Bottom sheet navigation** with rounded corners
- **Dynamic theming** - colors change per page

### Design Features
- Page 1: Welcome with logo (Green theme)
- Page 2: Smart Monitoring (Orange theme)
- Page 3: Automated Systems (Blue theme)
- Page 4: Data Analytics (Purple theme)
- Page 5: Expert Support (Red theme)

### Files Modified
- `lib/presentation/screens/onboarding/onboarding_screen.dart` ✅

---

## 2. 🔄 Login Screen - IN PROGRESS

### Current Status: **PARTIALLY IMPLEMENTED**

### Design Requirements (from `Login.png`)

#### Layout
1. **Logo Section**
   - MASH Grow logo at top
   - Height: 120px
   - Centered

2. **Welcome Section**
   - Title: "Welcome Back!" (Bold, Dark Green)
   - Subtitle: "Enter your details to login to your account" (Gray)

3. **Form Fields**
   - **Email or Username**
     - Label above field
     - Placeholder: "Enter email or username"
     - White background
     - Gray border, green focus border (2px)
     - Border radius: 12px
     - Height: 56px

   - **Password**
     - Label above field
     - Placeholder: "Enter Password"
     - Eye icon for visibility toggle (green)
     - Same styling as email field

4. **Forgot Password Link**
   - Right-aligned
   - Green color with underline
   - Links to Forgot Password screen

5. **Login Button**
   - Full width
   - Height: 56px
   - Dark green background (#2D5F4C)
   - White text
   - Border radius: 12px
   - Text: "Login"

6. **Divider**
   - Horizontal line with "or" text in center

7. **Social Login Buttons**
   - **Google Login**
     - White background
     - Gray border
     - Google icon + "Login with Google"
     - Full width, height: 56px

   - **Facebook Login**
     - White background
     - Gray border
     - Facebook icon + "Login with Facebook"
     - Full width, height: 56px

8. **Sign Up Link**
   - Center-aligned
   - "Don't have an account? **Sign up**"
   - Sign up text in bold green

### Implementation Notes
- Remove `CustomTextField` dependency
- Use standard `TextFormField` with custom decoration
- Add `ForgotPasswordScreen` navigation
- Implement Google/Facebook login handlers
- Add loading states
- Add error handling with SnackBar

### Files to Modify
- `lib/presentation/screens/auth/login_screen.dart` 🔄
- `lib/presentation/screens/auth/forgot_password_screen.dart` ✅ (Created)

---

## 3. 📋 Forgot Password Flow - COMPLETED

### Status: **IMPLEMENTED**

Created forgot password screen based on `Forgot Password.png`:

#### Features
1. **Logo** at top
2. **Title**: "Forgot Password"
3. **Subtitle**: "Check your email for the OTP"
4. **Email Input Field**
   - Label: "Email"
   - Placeholder: "j.delacruz@gmail.com"
   - Validation for email format
5. **Remember Password Link**
   - "Remembered your password? Go back to Login"
6. **Send Reset Link Button**
   - Full width, green background
   - Loading state

### Files Created
- `lib/presentation/screens/auth/forgot_password_screen.dart` ✅

---

## 4. 🏠 Home Screen - PENDING

### Design Requirements (from Figma)

#### States to Implement

##### A. **No Device State** (`Home - No Device.png`)
- **Header**
  - User avatar (left)
  - "Hello, Juan Dela Cruz"
  - "Please connect your device first."
  - Notification bell icon (right)

- **Empty State Illustration**
  - Green chamber/box illustration
  - "Start growing!" heading
  - "Please connect your Chamber." subtitle

- **Connect Button**
  - Full width
  - Dark green background
  - "Connect" text

- **Bottom Navigation**
  - Home (active - green circle)
  - Devices (grid icon)
  - Analytics (chart icon)
  - Settings (gear icon)
  - Dark green background with rounded top

##### B. **Dashboard State** (`Dashboard.png`)
- **Header**
  - User avatar
  - "Hello, Juan Dela Cruz"
  - "You have 1 device actively monitoring"
  - Notification bell

- **Chamber Status Overview Card**
  - Light green background
  - Energy icon
  - "Chamber Status Overview" title
  - **Energy Stats**
    - Total Energy Used: 165 kWh
    - Energy Efficiency Target
    - "Reduce usage to 300 kWh"
  - **Circular Progress Chart**
    - 45% displayed in center
    - Green progress ring

- **Sensor Status Grid**
  - 4 sensor cards in 2x2 grid
  - Each card shows:
    - Icon (temperature, humidity, fan, irrigation)
    - Sensor name
    - "1 Sensor active" status
    - Light green background

- **Search Bar**
  - "Search" placeholder
  - Eye icon (visibility toggle)

- **Add New Button**
  - "+ Add New" text
  - Green outline
  - Right-aligned

- **Chamber Card**
  - "Chamber 1" title
  - ID: MASH-A1-CAL25-D5A91F
  - ON/OFF toggle (green when ON)
  - Light background

##### C. **Chamber Detail State** (`Chamber.png`)
- **Header**
  - Back button
  - "Chamber 1" title
  - "Manage your Environment controls"
  - Settings icon

- **Status Cards** (2x2 grid)
  - Chamber Temperature: 31°C
  - Current Temperature: 20°C
  - Humidity: 54%
  - Battery: 80%
  - Icons for each metric

- **Sensors Tab**
  - Pill-shaped button
  - Light green background

- **Sensor Control Cards** (2x2 grid)
  - Temperature Sensor: 23°C, ON/OFF toggle
  - Humidity Sensor: 54%, ON/OFF toggle
  - CO2 Sensor: Current 1200ppm, ON/OFF toggle
  - Fan: Spinning status, ON/OFF toggle
  - Each card has icon and light background

### Components to Create
1. **UserHeader Widget**
   - Avatar, name, subtitle, notification bell
   - Reusable across screens

2. **ChamberStatusCard Widget**
   - Energy stats
   - Circular progress chart
   - Sensor status grid

3. **SensorCard Widget**
   - Icon, name, status, toggle
   - Reusable for different sensor types

4. **BottomNavBar Widget**
   - Custom navigation bar
   - Active state highlighting
   - Rounded top corners

5. **EmptyStateWidget**
   - Illustration, heading, subtitle, action button
   - Reusable for different empty states

### Files to Create/Modify
- `lib/presentation/screens/home/home_screen.dart` - Main home with states
- `lib/presentation/screens/home/dashboard_screen.dart` - Dashboard view
- `lib/presentation/screens/home/chamber_detail_screen.dart` - Chamber details
- `lib/presentation/widgets/home/user_header.dart` - Header widget
- `lib/presentation/widgets/home/chamber_status_card.dart` - Status card
- `lib/presentation/widgets/home/sensor_card.dart` - Sensor card
- `lib/presentation/widgets/common/bottom_nav_bar.dart` - Navigation bar
- `lib/presentation/widgets/common/empty_state.dart` - Empty state widget

---

## 5. 📱 Additional Screens from Designs

### Connect Device Screens
- `Connect Device - Disconnected.png`
- `Connect Device- Disconnected.png`
- Shows device connection flow

### User Settings
- `User Setting.png`
- Profile settings screen

---

## Implementation Priority

### Phase 1: ✅ COMPLETED
1. ✅ Onboarding Screen - DONE
2. ✅ Forgot Password Screen - DONE

### Phase 2: 🔄 IN PROGRESS
3. 🔄 Login Screen - Needs completion
   - Replace CustomTextField with standard TextFormField
   - Update styling to match Figma
   - Test social login buttons

### Phase 3: 📋 PENDING
4. 📋 Home Screen - No Device State
5. 📋 Home Screen - Dashboard State
6. 📋 Chamber Detail Screen
7. 📋 Bottom Navigation Bar
8. 📋 Reusable Widgets

### Phase 4: 📋 FUTURE
9. 📋 Connect Device Flow
10. 📋 User Settings Screen

---

## Design Assets Location

All Figma designs are located in:
```
assets/designs/
├── Home/
│   ├── Chamber.png
│   ├── Connect Device - Disconnected.png
│   ├── Connect Device- Disconnected.png
│   ├── Dashboard.png
│   ├── Home - No Device.png
│   └── User Setting.png
├── Login and Forgot Passsword/
│   ├── Forgot Password - OTP.png
│   ├── Forgot Password.png
│   ├── Login.png
│   ├── Reset Password.png
│   └── Success Feedback.png
├── Onboarding/
│   ├── Onboard1.png
│   ├── Onboard2.png
│   ├── Onboard3.png
│   ├── Onboard4.png
│   └── Onboarding.png
└── Sign Up/
    └── (Registration flow designs)
```

---

## Next Steps

1. **Complete Login Screen**
   - Remove CustomTextField dependency
   - Implement exact Figma design
   - Test all functionality

2. **Start Home Screen Implementation**
   - Create no-device state
   - Implement dashboard
   - Build chamber detail view

3. **Create Reusable Widgets**
   - Bottom navigation bar
   - User header
   - Sensor cards
   - Status cards

4. **Testing**
   - Test all navigation flows
   - Verify design alignment
   - Check responsive behavior

---

## Notes

- All screens should use the consistent design system
- Maintain #2D5F4C as primary brand color
- Use 12px border radius for consistency
- Button height: 56px across all screens
- Spacing: 16px, 24px, 32px, 40px multiples
- Background: #F5F5F5 for screens
- Cards: White (#FFFFFF) with subtle shadows

---

**Last Updated**: October 17, 2025
**Status**: Onboarding ✅ | Login 🔄 | Home 📋
