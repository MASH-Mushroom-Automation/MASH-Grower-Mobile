# PSGC Address Implementation

## Overview
Implemented Philippine Standard Geographic Code (PSGC) API integration for accurate Philippine address selection during registration.

## Features Implemented

### 1. PSGC API Integration
- **API Source**: https://psgc.gitlab.io/api/
- **Endpoints Used**:
  - Provinces: `https://psgc.gitlab.io/api/provinces.json`
  - Cities/Municipalities: `https://psgc.gitlab.io/api/cities-municipalities.json`
  - Barangays: `https://psgc.gitlab.io/api/barangays.json`

### 2. Cascading Dropdowns
- **Province → City → Barangay** selection flow
- Automatic filtering based on parent selection
- Alphabetically sorted lists for easy navigation
- Loading indicators during API calls
- Caching to prevent repeated API requests

### 3. Files Created

#### **Models** (`lib/core/models/psgc_models.dart`)
```dart
- Province: code, name, regionCode
- City: code, name, provinceCode, isCity
- Barangay: code, name, cityCode
```

#### **Service** (`lib/core/services/psgc_service.dart`)
```dart
- fetchProvinces(): Get all provinces
- fetchCitiesByProvince(provinceCode): Get cities by province
- fetchBarangaysByCity(cityCode): Get barangays by city
- Caching mechanism for performance
```

#### **Widget** (`lib/presentation/widgets/common/address_selector.dart`)
```dart
- Reusable AddressSelector widget
- Three cascading dropdowns
- Loading states
- Error handling
- Disabled states for dependent dropdowns
```

### 4. Files Modified

#### **pubspec.yaml**
- Added `http: ^1.2.1` package for API calls

#### **account_setup_page.dart**
- Integrated AddressSelector widget
- Modal bottom sheet for address selection
- Updated address display (Province, City, Barangay)
- Removed Region field (not needed with PSGC)
- Validation: Province and City are required, Barangay is optional

## How It Works

### User Flow
1. User taps on address field in Account Setup page
2. Modal bottom sheet opens with address selector
3. User selects Province from dropdown (sorted alphabetically)
4. City dropdown enables and loads cities for selected province
5. User selects City
6. Barangay dropdown enables and loads barangays for selected city
7. User optionally selects Barangay
8. User confirms selection
9. Address displays as: "Province, City, Barangay"

### Technical Flow
```
1. PSGCService fetches provinces on init
2. User selects province
3. PSGCService filters cities by provinceCode
4. User selects city
5. PSGCService filters barangays by cityCode
6. User confirms → saves to RegistrationProvider
```

## Data Caching
- All PSGC data is cached after first load
- Prevents repeated API calls
- Improves performance
- Can be cleared with `PSGCService().clearCache()`

## Design Consistency
- Primary color: #2D5F4C (dark green)
- Border radius: 12px
- Button height: 56px
- Loading indicators match app theme
- Disabled states have reduced opacity

## Validation Rules
- **Province**: Required
- **City**: Required
- **Barangay**: Optional
- **Street Address**: Optional (separate field)

## Benefits
1. **Accurate Data**: Official PSGC data from Philippine Statistics Authority
2. **User-Friendly**: Cascading dropdowns prevent invalid selections
3. **Performance**: Caching reduces API calls
4. **Scalable**: Reusable AddressSelector widget
5. **Maintainable**: Separate service layer for API logic

## Future Enhancements
- Add search functionality in dropdowns
- Implement offline mode with local database
- Add postal code lookup
- Support for special administrative regions
- Multi-language support (English/Filipino)

## Testing
To test the implementation:
1. Run `flutter pub get` to install http package
2. Navigate to registration flow
3. Reach Account Setup page
4. Tap on address field
5. Select Province, City, and optionally Barangay
6. Confirm selection
7. Verify address displays correctly

## API Response Format

### Province
```json
{
  "code": "0128",
  "name": "Ilocos Norte",
  "regionCode": "01"
}
```

### City
```json
{
  "code": "012801",
  "name": "Batac City",
  "provinceCode": "0128",
  "isCity": true
}
```

### Barangay
```json
{
  "code": "012801001",
  "name": "Baay",
  "cityCode": "012801"
}
```

## Error Handling
- Network errors show SnackBar with error message
- Empty states handled gracefully
- Null safety throughout
- Fallback to cached data when available

---

**Status**: ✅ Fully Implemented
**Ready for**: Testing and Backend Integration
**Dependencies**: http ^1.2.1
