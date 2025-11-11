# Implementation Notes - Missing Features

## Overview
This document outlines the missing features that need to be implemented in the MASH Grower Mobile app, based on the database schema analysis.

---

## 1. lastLoginAt Field Implementation

### Current Status
- ❌ **NOT IMPLEMENTED** in mobile app
- ✅ **EXISTS** in database schema (`users.lastLoginAt TIMESTAMP`)

### What Needs to be Done

#### Mobile App Changes
1. **Update User Model** (`lib/data/models/user_model.dart`)
   - Add `DateTime? lastLoginAt` field
   - Update `fromJson` and `toJson` methods

2. **Update Auth Provider** (`lib/presentation/providers/auth_provider.dart`)
   - Parse `lastLoginAt` from backend response
   - Display last login info in user profile

3. **Update Profile Screen** (`lib/presentation/screens/profile/profile_screen.dart`)
   - Show "Last Login" information
   - Format: "Last login: Nov 10, 2025 at 2:30 PM"

### Backend API Requirements

#### ⚠️ BACKEND DEVELOPER NOTE
The backend should automatically update `lastLoginAt` when:
- User logs in successfully (POST `/api/v1/auth/login`)
- User verifies email (POST `/api/v1/auth/verify-email`)
- Session is created

**Expected API Response:**
```json
{
  "success": true,
  "user": {
    "id": "...",
    "email": "...",
    "firstName": "...",
    "lastName": "...",
    "lastLoginAt": "2025-11-10T14:30:00.000Z"
  }
}
```

---

## 2. Address Management Implementation

### Current Status
- ✅ **PARTIALLY IMPLEMENTED** in registration flow
- ❌ **NOT STORED** in backend `addresses` table
- ✅ **Philippine PSGC API** already integrated for address selection

### Database Schema
```sql
-- addresses table
id              TEXT PRIMARY KEY
userId          TEXT NOT NULL (FK to users.id)
type            TEXT NOT NULL (e.g., 'home', 'work', 'billing', 'shipping')
firstName       TEXT NOT NULL
lastName        TEXT NOT NULL
company         TEXT
street1         TEXT NOT NULL
street2         TEXT
city            TEXT NOT NULL
state           TEXT NOT NULL (Province in PH)
postalCode      TEXT NOT NULL
country         TEXT NOT NULL DEFAULT 'Philippines'
phoneNumber     TEXT
isDefault       BOOLEAN NOT NULL DEFAULT false
createdAt       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
updatedAt       TIMESTAMP NOT NULL
```

### What Needs to be Done

#### Mobile App Changes

1. **Create Address Model** (`lib/data/models/address_model.dart`)
```dart
class AddressModel {
  final String id;
  final String userId;
  final String type; // 'home', 'work', 'billing', 'shipping'
  final String firstName;
  final String lastName;
  final String? company;
  final String street1;
  final String? street2;
  final String city;
  final String state; // Province
  final String postalCode;
  final String country;
  final String? phoneNumber;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

2. **Create Address Repository** (`lib/data/repositories/address_repository.dart`)
   - `Future<List<AddressModel>> getUserAddresses()`
   - `Future<AddressModel> createAddress(AddressModel address)`
   - `Future<AddressModel> updateAddress(String id, AddressModel address)`
   - `Future<void> deleteAddress(String id)`
   - `Future<AddressModel> setDefaultAddress(String id)`

3. **Create Address Provider** (`lib/presentation/providers/address_provider.dart`)
   - Manage address state
   - CRUD operations for addresses
   - Default address selection

4. **Create Address Management Screens**
   - `lib/presentation/screens/address/address_list_screen.dart`
   - `lib/presentation/screens/address/add_address_screen.dart`
   - `lib/presentation/screens/address/edit_address_screen.dart`

5. **Update Registration Flow**
   - Save address to `addresses` table after successful registration
   - Set as default address (type: 'home')

6. **Update Profile Screen**
   - Add "Manage Addresses" option
   - Show default address
   - Allow adding/editing/deleting addresses

### Backend API Requirements

#### ⚠️ BACKEND DEVELOPER NOTE
The following API endpoints need to be created:

```typescript
// Address Management Endpoints
GET    /api/v1/users/:userId/addresses          // Get all user addresses
POST   /api/v1/users/:userId/addresses          // Create new address
GET    /api/v1/users/:userId/addresses/:id      // Get specific address
PUT    /api/v1/users/:userId/addresses/:id      // Update address
DELETE /api/v1/users/:userId/addresses/:id      // Delete address
PUT    /api/v1/users/:userId/addresses/:id/default // Set as default
```

**POST/PUT Request Body:**
```json
{
  "type": "home",
  "firstName": "Kevin",
  "lastName": "Llanes",
  "company": null,
  "street1": "123 Main St, Bldg 5, Unit 3A",
  "street2": null,
  "city": "Quezon City",
  "state": "Metro Manila",
  "postalCode": "1100",
  "country": "Philippines",
  "phoneNumber": "+639171234567",
  "isDefault": true
}
```

**GET Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "addr_123",
      "userId": "user_456",
      "type": "home",
      "firstName": "Kevin",
      "lastName": "Llanes",
      "street1": "123 Main St",
      "city": "Quezon City",
      "state": "Metro Manila",
      "postalCode": "1100",
      "country": "Philippines",
      "phoneNumber": "+639171234567",
      "isDefault": true,
      "createdAt": "2025-11-10T10:00:00.000Z",
      "updatedAt": "2025-11-10T10:00:00.000Z"
    }
  ]
}
```

---

## 3. Philippine Address API Integration

### Current Status
- ✅ **ALREADY IMPLEMENTED** using PSGC (Philippine Standard Geographic Code) API
- ✅ Located in `lib/core/services/psgc_service.dart`
- ✅ Used in registration flow

### API Details
- **Base URL:** `https://psgc.gitlab.io/api`
- **Endpoints:**
  - `GET /provinces.json` - Get all provinces
  - `GET /cities-municipalities.json` - Get all cities/municipalities
  - `GET /barangays.json` - Get all barangays

### Features Already Working
- Province selection
- City/Municipality selection (filtered by province)
- Barangay selection (filtered by city)
- Caching to avoid repeated API calls
- Alphabetical sorting

### Integration Points
- ✅ Registration flow (`account_setup_page.dart`)
- ❌ Profile edit screen (needs to be added)
- ❌ Address management screens (needs to be added)

---

## 4. Session Management

### Current Status
- ✅ **EXISTS** in database schema (`sessions` table)
- ❌ **NOT FULLY UTILIZED** in mobile app

### Database Schema
```sql
-- sessions table
id              TEXT PRIMARY KEY
userId          TEXT NOT NULL (FK to users.id)
clerkSessionId  TEXT
token           TEXT NOT NULL UNIQUE
status          SessionStatus NOT NULL DEFAULT 'ACTIVE'
deviceInfo      JSONB
ipAddress       TEXT
userAgent       TEXT
lastActivity    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
expiresAt       TIMESTAMP NOT NULL
revokedAt       TIMESTAMP
revokedReason   TEXT
createdAt       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
updatedAt       TIMESTAMP NOT NULL
```

### What Needs to be Done

#### Mobile App Changes

1. **Create Session Model** (`lib/data/models/session_model.dart`)
```dart
class SessionModel {
  final String id;
  final String userId;
  final String token;
  final String status; // 'ACTIVE', 'EXPIRED', 'REVOKED'
  final Map<String, dynamic>? deviceInfo;
  final String? ipAddress;
  final String? userAgent;
  final DateTime lastActivity;
  final DateTime expiresAt;
  final DateTime? revokedAt;
  final String? revokedReason;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

2. **Update Session Service** (`lib/core/services/session_service.dart`)
   - Store session ID from backend
   - Track device info (device model, OS version, app version)
   - Handle session expiration
   - Implement session refresh

3. **Create Active Sessions Screen** (`lib/presentation/screens/security/active_sessions_screen.dart`)
   - Show all active sessions
   - Display device info, location, last activity
   - Allow revoking sessions
   - Highlight current session

### Backend API Requirements

#### ⚠️ BACKEND DEVELOPER NOTE
The following API endpoints need to be created or verified:

```typescript
// Session Management Endpoints
GET    /api/v1/users/:userId/sessions           // Get all user sessions
GET    /api/v1/users/:userId/sessions/active    // Get active sessions only
DELETE /api/v1/users/:userId/sessions/:id       // Revoke specific session
DELETE /api/v1/users/:userId/sessions/all       // Revoke all sessions except current
```

**GET Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "session_123",
      "userId": "user_456",
      "status": "ACTIVE",
      "deviceInfo": {
        "deviceModel": "iPhone 14 Pro",
        "osVersion": "iOS 17.0",
        "appVersion": "1.0.0"
      },
      "ipAddress": "192.168.1.1",
      "lastActivity": "2025-11-10T14:30:00.000Z",
      "expiresAt": "2025-11-17T14:30:00.000Z",
      "createdAt": "2025-11-10T10:00:00.000Z",
      "isCurrent": true
    }
  ]
}
```

---

## 5. User Profile Update

### Current Status
- ✅ **SCREEN EXISTS** (`edit_profile_screen.dart`)
- ❌ **BACKEND API NOT CONNECTED** (TODO comment exists)

### What Needs to be Done

#### Mobile App Changes

1. **Update User Repository** (`lib/data/repositories/user_repository.dart`)
   - Create if doesn't exist
   - Add `Future<UserModel> updateProfile(UpdateProfileRequest request)`

2. **Create Update Profile Request Model** (`lib/data/models/user/update_profile_request_model.dart`)
```dart
class UpdateProfileRequestModel {
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? username;
  // Add other updatable fields
}
```

3. **Update Edit Profile Screen**
   - Connect to backend API
   - Handle validation
   - Show success/error messages
   - Update local user state

### Backend API Requirements

#### ⚠️ BACKEND DEVELOPER NOTE
Verify or create the following endpoint:

```typescript
PUT /api/v1/users/:userId/profile
```

**Request Body:**
```json
{
  "firstName": "Kevin",
  "lastName": "Llanes",
  "phoneNumber": "+639171234567",
  "username": "byemmecaquin"
}
```

**Response:**
```json
{
  "success": true,
  "user": {
    "id": "user_456",
    "email": "k@gmail.com",
    "firstName": "Kevin",
    "lastName": "Llanes",
    "username": "byemmecaquin",
    "phoneNumber": "+639171234567",
    "lastLoginAt": "2025-11-10T14:30:00.000Z",
    "updatedAt": "2025-11-10T15:00:00.000Z"
  }
}
```

---

## Implementation Priority

### High Priority (Implement First)
1. ✅ **lastLoginAt** - Simple field addition
2. ✅ **User Profile Update** - Complete existing screen

### Medium Priority (Implement Second)
3. ✅ **Address Management** - Core e-commerce feature
4. ✅ **Session Management** - Security feature

### Low Priority (Nice to Have)
5. ⚪ Additional profile fields
6. ⚪ Advanced session analytics

---

## Testing Checklist

### Address Management
- [ ] Create new address
- [ ] Edit existing address
- [ ] Delete address
- [ ] Set default address
- [ ] Multiple addresses per user
- [ ] Address validation
- [ ] Philippine address selection (Province, City, Barangay)

### Session Management
- [ ] View active sessions
- [ ] Revoke specific session
- [ ] Revoke all sessions
- [ ] Session expiration handling
- [ ] Device info display

### User Profile
- [ ] Update first name
- [ ] Update last name
- [ ] Update phone number
- [ ] Update username
- [ ] View last login time
- [ ] Profile image upload

---

## Notes for Backend Developer

### Critical Requirements
1. **Address API** - Must be created (doesn't exist yet)
2. **Session API** - Verify if exists, create if missing
3. **Profile Update API** - Verify if exists
4. **lastLoginAt** - Auto-update on login

### Data Consistency
- Ensure `lastLoginAt` is updated on every successful login
- Ensure `updatedAt` is updated on profile/address changes
- Ensure session tokens are properly validated
- Ensure address deletion doesn't break orders (soft delete recommended)

### Security Considerations
- Validate user can only access their own addresses
- Validate user can only revoke their own sessions
- Validate user can only update their own profile
- Implement rate limiting on address CRUD operations

---

## Philippine Address Data Structure

### Example Complete Address
```json
{
  "street1": "123 Main St, Bldg 5, Unit 3A",
  "barangay": "Barangay Commonwealth",
  "city": "Quezon City",
  "province": "Metro Manila",
  "region": "National Capital Region (NCR)",
  "postalCode": "1121",
  "country": "Philippines"
}
```

### PSGC Codes
- Province Code: 10-digit code (e.g., "1339000000")
- City Code: 10-digit code (e.g., "133903000")
- Barangay Code: 10-digit code (e.g., "133903015")

---

## Summary

### Mobile App Work Required
- 4 new models (Address, Session, UpdateProfile, etc.)
- 2 new repositories (Address, User)
- 2 new providers (Address, Session)
- 4 new screens (Address List, Add/Edit Address, Active Sessions)
- Updates to existing screens (Profile, Edit Profile)

### Backend API Work Required
- 6 Address endpoints (CRUD + default)
- 4 Session endpoints (list, revoke)
- 1 Profile update endpoint (verify/create)
- Auto-update lastLoginAt on login

### Estimated Timeline
- Mobile: 3-4 days
- Backend: 2-3 days
- Testing: 1-2 days
- **Total: 6-9 days**

---

Last Updated: November 10, 2025
