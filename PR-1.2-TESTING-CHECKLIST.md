# PR-1.2 Offline Mode Enhancement - Testing Checklist

## Integration Completion Summary

✅ **All integrations completed successfully**
- OfflineHandler service created with connectivity monitoring
- Offline indicator widgets (full banner + compact variant)
- App.dart enhanced with OfflineHandler integration
- UserSettingsScreen updated with offline mode toggle
- DatabaseHelper enhanced with data retention policies
- Zero compilation errors (25 style warnings, same as baseline)

---

## Manual Testing Checklist

### 1. Offline Indicator Visual Display

#### Full Banner Indicator (Top of Screen)
- [ ] **Banner appearance when offline**
  - [ ] Banner appears at top when device loses network
  - [ ] Banner shows "You're offline" with airplane icon
  - [ ] Banner color is orange (amber) for manual offline mode
  - [ ] Banner color is red for automatic offline (no network)
  - [ ] Banner shows staleness message (e.g., "Data may be 5 minutes old")

- [ ] **Banner interactions**
  - [ ] Tapping banner opens detailed offline info dialog
  - [ ] Dialog explains current offline status
  - [ ] Dialog shows data staleness details
  - [ ] Dialog has "Got it" button to dismiss
  - [ ] Banner auto-hides when back online

- [ ] **Banner transitions**
  - [ ] Smooth fade-in when going offline
  - [ ] Smooth fade-out when back online
  - [ ] No flickering or rapid on/off cycles
  - [ ] Consistent positioning at screen top

#### Compact Indicator (App Bar Badge)
- [ ] **Compact indicator display**
  - [ ] Small badge appears in app bar when offline
  - [ ] Badge shows "Offline" text clearly
  - [ ] Badge color matches offline state (orange/red)
  - [ ] Badge doesn't obstruct other UI elements

- [ ] **Compact indicator interactions**
  - [ ] Tapping badge opens offline info dialog
  - [ ] Badge auto-hides when back online
  - [ ] Badge updates in real-time

---

### 2. Settings Integration (UserSettingsScreen)

#### Offline Mode Toggle Location
- [ ] **Settings screen navigation**
  - [ ] Open app and tap Settings tab (4th icon in bottom nav)
  - [ ] Scroll to "App Settings" section
  - [ ] Verify "Offline Mode" toggle is visible
  - [ ] Toggle is below "Device Settings" section
  - [ ] Toggle is above "Support" section

#### Offline Mode Toggle Functionality
- [ ] **Toggle state display**
  - [ ] Shows "Offline Mode" as title
  - [ ] Shows current network status as subtitle (e.g., "Currently online")
  - [ ] Shows "Force offline mode (testing)" when enabled
  - [ ] Toggle switch reflects current state correctly
  - [ ] Icon appears next to toggle (WiFi off icon)

- [ ] **Enable forced offline mode**
  - [ ] Tap toggle switch to enable
  - [ ] Subtitle updates to "Force offline mode (testing)"
  - [ ] Offline banner appears at top of screen
  - [ ] App behaves as if network is unavailable
  - [ ] Setting persists after app restart
  - [ ] Verify stored in SharedPreferences

- [ ] **Disable forced offline mode**
  - [ ] Tap toggle switch to disable
  - [ ] Subtitle updates to show network status
  - [ ] Offline banner disappears
  - [ ] App resumes normal network operations
  - [ ] Setting persists after app restart

- [ ] **Tap for more info**
  - [ ] Tap the "Offline Mode" list tile (not just switch)
  - [ ] Dialog opens with detailed explanation
  - [ ] Dialog explains forced offline vs automatic offline
  - [ ] Dialog shows current connectivity status
  - [ ] Dialog shows data staleness information
  - [ ] Dialog has "Close" button

#### Theme Selector (Same Section)
- [ ] **Theme selector visibility**
  - [ ] "App Theme" option appears in same section
  - [ ] Shows current theme mode (System, Light, Dark)
  - [ ] Icon appears next to theme selector

- [ ] **Theme selection**
  - [ ] Tap theme selector opens dialog
  - [ ] Dialog shows 3 options (System, Light, Dark)
  - [ ] Selecting option updates theme immediately
  - [ ] Theme persists after app restart

---

### 3. Connectivity Monitoring (OfflineHandler)

#### Network Detection
- [ ] **Automatic offline detection**
  - [ ] Enable airplane mode on device
  - [ ] Offline banner appears within 1-2 seconds
  - [ ] Banner shows "You're offline" with red color
  - [ ] Disable airplane mode
  - [ ] Banner disappears within 1-2 seconds

- [ ] **WiFi disconnection**
  - [ ] Disconnect from WiFi network
  - [ ] Offline banner appears
  - [ ] Reconnect to WiFi
  - [ ] Banner disappears

- [ ] **Mobile data switching**
  - [ ] If using mobile device, switch between WiFi and cellular
  - [ ] No offline banner when switching networks
  - [ ] Smooth transition between connection types

#### Forced Offline Mode Override
- [ ] **Manual override behavior**
  - [ ] Enable forced offline in settings
  - [ ] Banner appears even with active network
  - [ ] Banner color is orange (amber)
  - [ ] Banner shows "You're in offline mode (testing)"
  - [ ] App refuses network requests
  - [ ] Disable forced offline
  - [ ] App resumes network operations

---

### 4. Data Staleness Tracking

#### Staleness Messages
- [ ] **Time since last online**
  - [ ] Go offline for 1 minute, check banner shows "Data may be 1 minute old"
  - [ ] Go offline for 5 minutes, check banner shows "Data may be 5 minutes old"
  - [ ] Go offline for 1 hour, check banner shows "Data may be 1 hour old"
  - [ ] Go offline for 1 day, check banner shows "Data may be 1 day old"
  - [ ] Verify messages are human-readable and accurate

- [ ] **Staleness info in dialog**
  - [ ] Tap offline banner or settings toggle
  - [ ] Dialog shows detailed staleness information
  - [ ] Dialog explains when data was last synced
  - [ ] Dialog warns about stale sensor readings

---

### 5. Data Retention Management (DatabaseHelper)

#### Automatic Cleanup
- [ ] **30-day retention policy**
  - [ ] Test database has old sensor readings (older than 30 days)
  - [ ] Call `DatabaseHelper().cleanupOldData()`
  - [ ] Verify old sensor readings are deleted
  - [ ] Verify old alerts (30+ days) are deleted
  - [ ] Verify old notifications (30+ days) are deleted

- [ ] **7-day queue retention**
  - [ ] Test database has old sync queue items (older than 7 days)
  - [ ] Call `DatabaseHelper().cleanupOldData()`
  - [ ] Verify old synced queue items are deleted
  - [ ] Verify unsynced queue items are NOT deleted

- [ ] **Preserve unsynced data**
  - [ ] Create sensor readings marked as unsynced
  - [ ] Wait or change timestamps to simulate old data
  - [ ] Run cleanup
  - [ ] Verify unsynced sensor readings are preserved
  - [ ] Verify only synced old data is deleted

#### Staleness Queries
- [ ] **Get stale data counts**
  - [ ] Call `DatabaseHelper().getStaleDataCounts()`
  - [ ] Verify returns map with counts per table
  - [ ] Check sensor_readings count matches expected
  - [ ] Check alerts count matches expected
  - [ ] Check notifications count matches expected
  - [ ] Check sync_queue count matches expected

- [ ] **Get oldest timestamps**
  - [ ] Call `DatabaseHelper().getOldestRecordTimestamps()`
  - [ ] Verify returns map with oldest timestamp per table
  - [ ] Verify timestamps are accurate
  - [ ] Verify empty tables return null or empty

---

### 6. Offline Mode Info Dialog

#### Dialog Content
- [ ] **Dialog appearance**
  - [ ] Opens from tapping offline banner
  - [ ] Opens from tapping settings toggle tile
  - [ ] Shows title "Offline Mode"
  - [ ] Shows WiFi off icon at top

- [ ] **Status information**
  - [ ] Shows current connectivity status clearly
  - [ ] Explains if in forced offline mode
  - [ ] Shows data staleness information
  - [ ] Uses clear, non-technical language

- [ ] **Dialog interactions**
  - [ ] "Close" button dismisses dialog
  - [ ] Tapping outside dialog dismisses it
  - [ ] Dialog doesn't block critical app functions

---

### 7. Cross-Screen Consistency

#### Indicator Visibility Across App
- [ ] **Dashboard screen**
  - [ ] Offline banner appears at top
  - [ ] Dashboard content still accessible
  - [ ] Sensor data shows staleness indicators

- [ ] **Device screens**
  - [ ] Offline banner appears on device list screen
  - [ ] Offline banner appears on device detail screen
  - [ ] Device control disabled when offline

- [ ] **Profile screens**
  - [ ] Offline banner appears on profile screen
  - [ ] Settings screen shows offline toggle
  - [ ] Profile edit disabled when offline

- [ ] **All screens consistency**
  - [ ] Banner positioning consistent across screens
  - [ ] Banner color consistent with offline state
  - [ ] No screen-specific bugs or glitches

---

### 8. Performance Testing

#### OfflineHandler Singleton
- [ ] **Memory management**
  - [ ] OfflineHandler.instance returns same instance
  - [ ] No memory leaks when switching screens
  - [ ] Connectivity listeners properly disposed

- [ ] **Polling efficiency**
  - [ ] StreamBuilder polls every 1 second (verify with logs)
  - [ ] No excessive CPU usage
  - [ ] Battery drain is minimal
  - [ ] App remains responsive

#### Database Performance
- [ ] **Cleanup operation speed**
  - [ ] cleanupOldData() completes in reasonable time (< 5 seconds)
  - [ ] No UI freezing during cleanup
  - [ ] Background thread execution (no main thread blocking)

---

### 9. Edge Cases & Error Handling

#### Network State Changes
- [ ] **Rapid on/off cycles**
  - [ ] Rapidly toggle airplane mode on/off
  - [ ] Indicator doesn't flicker excessively
  - [ ] App remains stable

- [ ] **Network timeout**
  - [ ] Simulate slow network connection
  - [ ] App detects as online but shows staleness
  - [ ] No crashes or freezes

#### Settings Persistence
- [ ] **App restart with forced offline**
  - [ ] Enable forced offline mode
  - [ ] Close and reopen app
  - [ ] Forced offline mode still enabled
  - [ ] Offline banner still shows

- [ ] **App restart while actually offline**
  - [ ] Go into airplane mode
  - [ ] Close and reopen app
  - [ ] Offline banner appears immediately
  - [ ] No network errors in logs

#### Database Edge Cases
- [ ] **Empty database cleanup**
  - [ ] Run cleanupOldData() on empty database
  - [ ] No crashes or errors
  - [ ] Returns successfully

- [ ] **Large dataset cleanup**
  - [ ] Populate database with 10,000+ records
  - [ ] Run cleanupOldData()
  - [ ] Operation completes without timeout
  - [ ] Correct records are deleted

---

## Automated Testing Checklist

### Unit Tests to Write

#### OfflineHandler Tests
- [ ] Test `initialize()` sets up connectivity listener
- [ ] Test `isOnline` getter returns connectivity status
- [ ] Test `isForcedOffline` getter reads from SharedPreferences
- [ ] Test `timeSinceLastOnline` calculates correctly
- [ ] Test `isDataStale()` returns true when offline > threshold
- [ ] Test `setForcedOfflineMode(true)` saves to storage
- [ ] Test `setForcedOfflineMode(false)` removes from storage
- [ ] Test `addConnectivityListener()` registers callback
- [ ] Test `removeConnectivityListener()` unregisters callback
- [ ] Test `dispose()` cleans up resources
- [ ] Test connectivity change triggers callbacks
- [ ] Test last online timestamp updates when online
- [ ] Mock connectivity_plus for testing
- [ ] Mock SharedPreferences for testing

#### DatabaseHelper Retention Tests
- [ ] Test `cleanupOldData()` deletes records older than retention period
- [ ] Test sensor readings older than 30 days are deleted
- [ ] Test alerts older than 30 days are deleted
- [ ] Test notifications older than 30 days are deleted
- [ ] Test sync queue older than 7 days (synced) are deleted
- [ ] Test unsynced sensor readings are preserved
- [ ] Test unsynced queue items are preserved
- [ ] Test `getStaleDataCounts()` returns correct counts
- [ ] Test `getOldestRecordTimestamps()` returns correct timestamps
- [ ] Test empty table handling
- [ ] Mock sqflite database for testing
- [ ] Test concurrent access safety

---

### Widget Tests

#### OfflineIndicator Widget Tests
- [ ] Test banner renders when offline
- [ ] Test banner hidden when online
- [ ] Test banner color changes based on offline type
- [ ] Test staleness message updates
- [ ] Test tap opens info dialog
- [ ] Test StreamBuilder polling behavior
- [ ] Mock OfflineHandler for testing

#### CompactOfflineIndicator Widget Tests
- [ ] Test compact badge renders when offline
- [ ] Test compact badge hidden when online
- [ ] Test badge color reflects offline state
- [ ] Test tap opens info dialog
- [ ] Mock OfflineHandler for testing

#### UserSettingsScreen Tests
- [ ] Test offline toggle renders in App Settings section
- [ ] Test toggle switch state reflects offline mode
- [ ] Test subtitle updates based on connectivity
- [ ] Test tap toggle updates forced offline mode
- [ ] Test tap tile opens info dialog
- [ ] Test theme selector renders in same section
- [ ] Mock OfflineHandler and ThemeProvider

---

### Integration Tests

#### End-to-End Offline Flow
- [ ] Test app launch while offline
- [ ] Test switching to offline mode in settings
- [ ] Test offline indicator appears across all screens
- [ ] Test data staleness increases over time
- [ ] Test reconnecting to network clears offline state
- [ ] Test forced offline persists across app restarts

#### Database Cleanup Integration
- [ ] Test cleanup runs on app startup (if implemented)
- [ ] Test cleanup runs on demand
- [ ] Test cleanup integrates with sync service (when PR-1.3 done)
- [ ] Test data integrity after cleanup

---

## Regression Testing

### Verify No Breaking Changes
- [ ] Authentication flow still works
- [ ] Login and registration unchanged
- [ ] Device discovery still functional
- [ ] Sensor data display still works
- [ ] Device control still functional
- [ ] Navigation between screens unchanged
- [ ] Theme switching still works
- [ ] Profile management unchanged

### Check All Providers
- [ ] AuthProvider not affected
- [ ] SensorProvider not affected
- [ ] DeviceProvider not affected
- [ ] NotificationProvider not affected
- [ ] ThemeProvider not affected
- [ ] All other providers functional

---

## Code Quality Checks

### Code Review
- [ ] All new code follows Flutter best practices
- [ ] Provider pattern correctly implemented
- [ ] Singleton pattern correctly used
- [ ] No memory leaks in listeners
- [ ] Proper error handling in all methods
- [ ] Clear variable and method naming
- [ ] Adequate code comments
- [ ] No console.log() in production code

### Static Analysis
- [ ] flutter analyze shows 0 errors
- [ ] Only non-blocking warnings remain
- [ ] No unused imports
- [ ] No deprecated API usage (or documented)
- [ ] Lint rules followed

### Documentation
- [ ] PR-1.2-OFFLINE-MODE-SUMMARY.md complete
- [ ] All new methods documented
- [ ] Integration points documented
- [ ] Testing checklist complete (this file)

---

## Pre-Merge Checklist

### Git Workflow
- [ ] Branch: feature/pr-1.2-offline-mode-enhancement
- [ ] All changes committed with descriptive messages
- [ ] Pushed to remote repository
- [ ] PR created against develop branch
- [ ] PR description includes PR-1.2-OFFLINE-MODE-SUMMARY.md

### Files Verified
- [x] lib/core/services/offline_handler.dart (created)
- [x] lib/presentation/widgets/offline_indicator.dart (created)
- [x] lib/app.dart (modified)
- [x] lib/data/datasources/local/database_helper.dart (modified)
- [x] lib/presentation/screens/home/user_settings_screen.dart (modified)
- [x] PR-1.2-OFFLINE-MODE-SUMMARY.md (created)
- [ ] PR-1.2-TESTING-CHECKLIST.md (this file)

### Quality Gates
- [x] All compilation errors fixed
- [ ] Manual testing completed
- [ ] Core functionality tested
- [ ] Edge cases tested
- [ ] Performance acceptable
- [ ] No regressions detected

---

## Testing Notes

### Known Limitations
- Offline mode tutorial deferred to Phase 4 (UX polish)
- Background sync integration pending PR-1.3
- Advanced staleness strategies pending PR-1.3
- Conflict resolution pending PR-1.5

### Testing Environment
- Test on both Android and iOS if possible
- Test on emulator and physical device
- Test with varying network conditions
- Test with populated and empty database

### Expected Behavior
- Offline banner should appear within 1-2 seconds of connectivity change
- Forced offline mode should persist across app restarts
- Data retention cleanup should be non-disruptive
- App should remain fully functional when offline (read-only mode)

---

## Sign-off

- [ ] Developer testing complete
- [ ] Code review passed
- [ ] QA testing passed (if applicable)
- [ ] Documentation reviewed
- [ ] Ready for merge to develop

**Tested by:** _________________
**Date:** _________________
**Notes:** _________________
