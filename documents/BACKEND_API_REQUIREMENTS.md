# Backend API Requirements - Missing Features

## 🚨 CRITICAL: Backend Developer Action Items

This document outlines the **missing or incomplete API endpoints** that need to be implemented in the MASH Backend to support the mobile app features.

---

## 1. User lastLoginAt Field

### Status
- ✅ Database field exists: `users.lastLoginAt TIMESTAMP`
- ❌ **NOT automatically updated on login**

### Required Changes

#### Auto-Update on Login
Update the login endpoint to set `lastLoginAt`:

```typescript
// POST /api/v1/auth/login
// After successful authentication, update lastLoginAt

await prisma.user.update({
  where: { id: user.id },
  data: { lastLoginAt: new Date() }
});
```

#### Include in API Responses
Add `lastLoginAt` to all user response objects:

```json
{
  "success": true,
  "user": {
    "id": "cmhq5o0c7000eqi01e73g3j72",
    "email": "k@gmail.com",
    "firstName": "Kevin",
    "lastName": "Llanes",
    "lastLoginAt": "2025-11-10T14:30:00.000Z"
  }
}
```

### Affected Endpoints
- `POST /api/v1/auth/login`
- `POST /api/v1/auth/verify-email`
- `GET /api/v1/auth/me`
- `GET /api/v1/users/:id`

---

## 2. Address Management API (NEW - DOES NOT EXIST)

### Status
- ✅ Database table exists: `addresses`
- ❌ **API endpoints DO NOT EXIST**

### Required Endpoints

#### 1. Get All User Addresses
```typescript
GET /api/v1/users/:userId/addresses

// Response
{
  "success": true,
  "data": [
    {
      "id": "addr_123",
      "userId": "user_456",
      "type": "home",
      "firstName": "Kevin",
      "lastName": "Llanes",
      "company": null,
      "street1": "123 Main St, Bldg 5, Unit 3A",
      "street2": null,
      "city": "Quezon City",
      "state": "Metro Manila",
      "postalCode": "1121",
      "country": "Philippines",
      "phoneNumber": "+639171234567",
      "isDefault": true,
      "createdAt": "2025-11-10T10:00:00.000Z",
      "updatedAt": "2025-11-10T10:00:00.000Z"
    }
  ]
}
```

#### 2. Create New Address
```typescript
POST /api/v1/users/:userId/addresses

// Request Body
{
  "type": "home",
  "firstName": "Kevin",
  "lastName": "Llanes",
  "company": null,
  "street1": "123 Main St, Bldg 5, Unit 3A",
  "street2": null,
  "city": "Quezon City",
  "state": "Metro Manila",
  "postalCode": "1121",
  "country": "Philippines",
  "phoneNumber": "+639171234567",
  "isDefault": true
}

// Response
{
  "success": true,
  "data": {
    "id": "addr_123",
    "userId": "user_456",
    // ... full address object
  }
}
```

#### 3. Get Specific Address
```typescript
GET /api/v1/users/:userId/addresses/:addressId

// Response
{
  "success": true,
  "data": {
    "id": "addr_123",
    // ... full address object
  }
}
```

#### 4. Update Address
```typescript
PUT /api/v1/users/:userId/addresses/:addressId

// Request Body (same as create)
{
  "type": "work",
  "firstName": "Kevin",
  // ... other fields
}

// Response
{
  "success": true,
  "data": {
    "id": "addr_123",
    // ... updated address object
  }
}
```

#### 5. Delete Address
```typescript
DELETE /api/v1/users/:userId/addresses/:addressId

// Response
{
  "success": true,
  "message": "Address deleted successfully"
}
```

#### 6. Set Default Address
```typescript
PUT /api/v1/users/:userId/addresses/:addressId/default

// Response
{
  "success": true,
  "data": {
    "id": "addr_123",
    "isDefault": true,
    // ... full address object
  }
}

// Note: This should set isDefault=false for all other addresses
```

### Business Logic Requirements

1. **Default Address Logic**
   - When setting an address as default, unset all other addresses
   - First address created should be default automatically
   - Cannot delete the default address if it's the only one

2. **Validation**
   - Validate user can only access their own addresses
   - Validate required fields: firstName, lastName, street1, city, state, postalCode, country
   - Validate type is one of: 'home', 'work', 'billing', 'shipping'
   - Validate phoneNumber format if provided

3. **Security**
   - Ensure userId in URL matches authenticated user
   - Prevent users from accessing other users' addresses

---

## 3. Session Management API (VERIFY IF EXISTS)

### Status
- ✅ Database table exists: `sessions`
- ❓ **API endpoints may not exist or may be incomplete**

### Required Endpoints

#### 1. Get All User Sessions
```typescript
GET /api/v1/users/:userId/sessions

// Response
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
      "userAgent": "MASH-Mobile/1.0.0",
      "lastActivity": "2025-11-10T14:30:00.000Z",
      "expiresAt": "2025-11-17T14:30:00.000Z",
      "createdAt": "2025-11-10T10:00:00.000Z",
      "isCurrent": true
    }
  ]
}
```

#### 2. Get Active Sessions Only
```typescript
GET /api/v1/users/:userId/sessions/active

// Response (same format as above, filtered by status='ACTIVE')
```

#### 3. Revoke Specific Session
```typescript
DELETE /api/v1/users/:userId/sessions/:sessionId

// Response
{
  "success": true,
  "message": "Session revoked successfully"
}

// Note: Update session status to 'REVOKED' and set revokedAt timestamp
```

#### 4. Revoke All Sessions (Except Current)
```typescript
DELETE /api/v1/users/:userId/sessions/all

// Response
{
  "success": true,
  "message": "All sessions revoked except current",
  "revokedCount": 3
}
```

### Business Logic Requirements

1. **Session Creation**
   - Store device info (from User-Agent or custom header)
   - Store IP address
   - Set expiration (e.g., 7 days)
   - Update lastActivity on each API call

2. **Session Validation**
   - Check if session is expired
   - Check if session is revoked
   - Update lastActivity timestamp

3. **Current Session Detection**
   - Mark the session used for the current request as `isCurrent: true`

---

## 4. User Profile Update API (VERIFY IF EXISTS)

### Status
- ❓ **Endpoint may not exist or may be incomplete**

### Required Endpoint

```typescript
PUT /api/v1/users/:userId/profile

// Request Body
{
  "firstName": "Kevin",
  "lastName": "Llanes",
  "phoneNumber": "+639171234567",
  "username": "byemmecaquin"
}

// Response
{
  "success": true,
  "user": {
    "id": "user_456",
    "email": "k@gmail.com",
    "firstName": "Kevin",
    "lastName": "Llanes",
    "username": "byemmecaquin",
    "phoneNumber": "+639171234567",
    "imageUrl": "https://...",
    "lastLoginAt": "2025-11-10T14:30:00.000Z",
    "updatedAt": "2025-11-10T15:00:00.000Z"
  }
}
```

### Business Logic Requirements

1. **Validation**
   - Validate username is unique (if changed)
   - Validate phone number format
   - Validate required fields

2. **Security**
   - Ensure userId in URL matches authenticated user
   - Cannot change email through this endpoint
   - Cannot change role through this endpoint

---

## 5. Registration Flow - Address Storage

### Status
- ✅ Registration endpoint exists: `POST /api/v1/auth/register`
- ❌ **Does not save address to `addresses` table**

### Required Changes

#### Update Registration Endpoint
After creating the user, create their first address:

```typescript
// POST /api/v1/auth/register
// After user creation, if address data is provided:

if (addressData) {
  await prisma.address.create({
    data: {
      userId: newUser.id,
      type: 'home',
      firstName: registerData.firstName,
      lastName: registerData.lastName,
      street1: addressData.street1,
      city: addressData.city,
      state: addressData.province,
      postalCode: addressData.postalCode || '0000',
      country: 'Philippines',
      phoneNumber: registerData.phoneNumber,
      isDefault: true
    }
  });
}
```

#### Optional: Extend Registration Request
If you want to accept address during registration:

```typescript
// Request Body
{
  "email": "k@gmail.com",
  "password": "PP@Namias99",
  "firstName": "Kevin",
  "lastName": "Llanes",
  "username": "byemmecaquin",
  "address": {
    "street1": "123 Main St",
    "city": "Quezon City",
    "province": "Metro Manila",
    "postalCode": "1121",
    "phoneNumber": "+639171234567"
  }
}
```

---

## Implementation Priority

### Phase 1: Critical (Implement Immediately)
1. ✅ **lastLoginAt Auto-Update** - 30 minutes
2. ✅ **User Profile Update API** - 1 hour

### Phase 2: High Priority (Implement This Week)
3. ✅ **Address Management API** - 4-6 hours
   - All 6 endpoints
   - Validation and security
   - Default address logic

### Phase 3: Medium Priority (Implement Next Week)
4. ✅ **Session Management API** - 2-3 hours
   - All 4 endpoints
   - Session validation updates

---

## Testing Checklist

### Address API
- [ ] Create address
- [ ] Get all addresses
- [ ] Get specific address
- [ ] Update address
- [ ] Delete address
- [ ] Set default address
- [ ] Cannot access other users' addresses
- [ ] Default address logic works correctly

### Session API
- [ ] Get all sessions
- [ ] Get active sessions only
- [ ] Revoke specific session
- [ ] Revoke all sessions except current
- [ ] Cannot access other users' sessions
- [ ] Current session detection works

### User Profile
- [ ] Update first name
- [ ] Update last name
- [ ] Update phone number
- [ ] Update username (unique validation)
- [ ] Cannot change email
- [ ] Cannot change role
- [ ] lastLoginAt is included in response

---

## Database Migrations

### Check if these migrations are needed:

1. **lastLoginAt Index**
```sql
CREATE INDEX IF NOT EXISTS idx_users_lastLoginAt 
ON users(lastLoginAt);
```

2. **Address Indexes**
```sql
CREATE INDEX IF NOT EXISTS idx_addresses_userId 
ON addresses(userId);

CREATE INDEX IF NOT EXISTS idx_addresses_userId_isDefault 
ON addresses(userId, isDefault);
```

3. **Session Indexes**
```sql
CREATE INDEX IF NOT EXISTS idx_sessions_userId 
ON sessions(userId);

CREATE INDEX IF NOT EXISTS idx_sessions_status 
ON sessions(status);

CREATE INDEX IF NOT EXISTS idx_sessions_expiresAt 
ON sessions(expiresAt);
```

---

## API Response Standards

### Success Response
```json
{
  "success": true,
  "data": { /* ... */ },
  "message": "Operation completed successfully"
}
```

### Error Response
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": {
      "field": "phoneNumber",
      "issue": "Invalid phone number format"
    }
  }
}
```

### Pagination Response
```json
{
  "success": true,
  "data": [ /* ... */ ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "totalPages": 5
  }
}
```

---

## Security Considerations

### Authentication
- All endpoints require valid JWT token
- Validate token on every request
- Check token expiration

### Authorization
- Users can only access their own data
- Validate `userId` in URL matches authenticated user
- Admin endpoints require admin role

### Rate Limiting
- Implement rate limiting on all endpoints
- Stricter limits on write operations (POST, PUT, DELETE)

### Input Validation
- Validate all input data
- Sanitize strings to prevent SQL injection
- Validate data types and formats

---

## Contact

If you have questions about these requirements, please contact the mobile development team.

**Document Version:** 1.0  
**Last Updated:** November 10, 2025  
**Status:** Pending Backend Implementation
