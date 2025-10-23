# Camera & Network Permissions Test Proposal

## Overview
This document outlines the testing procedure for camera and network permissions on iOS and Android physical devices for the Nomad Notes app.

## Test Environment Requirements

### iOS Physical Device
- iPhone running iOS 14.0 or later
- Device not connected to Mac (to avoid localhost network interference)
- Clean install of the app (or clear app data/reinstall)

### Android Physical Device
- Android phone running Android 6.0+ (API level 23+)
- Clean install of the app (or clear app data/reinstall)

## Pre-Test Setup

### 1. Clean Build
```bash
cd nomad_notes

# Clean Flutter build cache
flutter clean

# Get dependencies
flutter pub get

# For iOS - update pods
cd ios && pod install && cd ..
```

### 2. Backend Setup
Ensure the Django backend is running and accessible on the local network:
```bash
# In backend directory
docker compose up

# Note the IP address of your development machine
# e.g., 192.168.1.100:8000
```

### 3. Update API Configuration
Update `nomad_notes/lib/core/config/api_config.dart` to point to your local network backend:
```dart
// Replace localhost with your machine's local IP
static const String baseUrl = 'http://192.168.1.100:8000';
```

## Test Cases

### A. iOS Permission Tests

#### A1. Local Network Permission (iOS 14+)
**Objective:** Verify local network permission dialog appears and functions correctly

**Steps:**
1. Install fresh build of the app on iPhone
2. Launch the app for the first time
3. **Expected:** Local network permission dialog should appear within 1 second
   - Dialog text: "Nomad Notes Would Like to Find and Connect to Devices on Your Local Network"
4. Tap "OK" to allow
5. **Expected:** Permission granted, app can make HTTP requests to local backend

**Test Scenarios:**
- [ ] First launch triggers permission prompt
- [ ] Accepting permission allows backend API calls
- [ ] Denying permission blocks backend API calls (expected to fail)
- [ ] Re-enabling in Settings > Nomad Notes > Local Network allows API calls

#### A2. Camera Permission (iOS)
**Objective:** Verify camera permission for visual notes

**Steps:**
1. Navigate to create new note screen
2. Tap "Add Photo" or camera icon
3. Select "Take Photo" option
4. **Expected:** Camera permission dialog appears
   - Dialog text: "This app requires access to the camera to capture photos for visual notes."
5. Tap "OK" to allow
6. **Expected:** Camera opens successfully
7. Take a photo
8. **Expected:** Photo attaches to note

**Test Scenarios:**
- [ ] Camera permission prompt appears when accessing camera
- [ ] Accepting permission opens camera successfully
- [ ] Denying permission shows error message (graceful failure)
- [ ] Re-enabling in Settings > Nomad Notes > Camera allows camera access

#### A3. Photo Library Permission (iOS)
**Objective:** Verify photo library access for visual notes

**Steps:**
1. Navigate to create new note screen
2. Tap "Add Photo" or camera icon
3. Select "Choose from Library" option
4. **Expected:** Photo library permission dialog appears
   - Dialog text: "This app requires access to your photo library to attach images to notes."
5. Tap "Select Photos..." or "Allow Access to All Photos"
6. **Expected:** Photo library opens successfully
7. Select a photo
8. **Expected:** Photo attaches to note

**Test Scenarios:**
- [ ] Photo library permission prompt appears
- [ ] Accepting permission opens photo library
- [ ] Limited selection works (iOS 14+)
- [ ] Denying permission shows error message

#### A4. HTTP Network Requests (iOS)
**Objective:** Verify HTTP requests work over local network

**Steps:**
1. Ensure local network permission is granted
2. Attempt to sign up/sign in
3. **Expected:** HTTP requests to `http://192.168.x.x:8000` succeed
4. Create a note
5. **Expected:** Note syncs to backend successfully

**Test Scenarios:**
- [ ] Sign up with new account succeeds
- [ ] Sign in with existing account succeeds
- [ ] Note creation/update/delete operations succeed
- [ ] HTTP requests don't fail due to ATS (App Transport Security)

---

### B. Android Permission Tests

#### B1. Camera Permission (Android)
**Objective:** Verify camera permission for visual notes

**Steps:**
1. Navigate to create new note screen
2. Tap "Add Photo" or camera icon
3. Select "Take Photo" option
4. **Expected:** Camera permission dialog appears (Android 6.0+)
   - Dialog shows camera permission request
5. Tap "Allow"
6. **Expected:** Camera opens successfully
7. Take a photo
8. **Expected:** Photo attaches to note

**Test Scenarios:**
- [ ] Camera permission prompt appears (Android 6.0+)
- [ ] Accepting permission opens camera
- [ ] Denying permission shows error message
- [ ] "Don't ask again" scenario - user must go to app settings
- [ ] Re-enabling in Settings > Apps > Nomad Notes > Permissions allows camera

#### B2. Photo Library/Storage Permission (Android)
**Objective:** Verify photo library/storage access

**Steps:**
1. Navigate to create new note screen
2. Tap "Add Photo" or camera icon
3. Select "Choose from Gallery" option
4. **Expected:**
   - Android 13+ (API 33+): No permission needed (scoped storage), gallery opens directly
   - Android 6-12: Storage permission dialog appears
5. If prompted, tap "Allow"
6. **Expected:** Photo gallery opens successfully
7. Select a photo
8. **Expected:** Photo attaches to note

**Test Scenarios:**
- [ ] Android 13+: Gallery opens without permission prompt
- [ ] Android 6-12: Storage permission prompt appears
- [ ] Accepting permission (if prompted) opens gallery
- [ ] Denying permission shows error message
- [ ] Re-enabling in Settings > Apps > Nomad Notes > Permissions works

#### B3. Internet Permission (Android)
**Objective:** Verify internet access for backend API

**Steps:**
1. Ensure app is installed with internet permission
2. Attempt to sign up/sign in
3. **Expected:** HTTP requests to backend succeed
4. Create a note
5. **Expected:** Note syncs to backend successfully

**Test Scenarios:**
- [ ] Sign up with new account succeeds
- [ ] Sign in with existing account succeeds
- [ ] Note creation/update/delete operations succeed
- [ ] App works on both WiFi and mobile data

#### B4. Network State Permission (Android)
**Objective:** Verify app can detect network connectivity

**Steps:**
1. Start app with WiFi/data enabled
2. Turn off WiFi and mobile data
3. **Expected:** App shows appropriate "no connection" message
4. Turn WiFi/data back on
5. **Expected:** App reconnects and syncs

**Test Scenarios:**
- [ ] App detects online state
- [ ] App detects offline state
- [ ] App shows appropriate messages for connection state
- [ ] App recovers gracefully when connection restored

---

## Test Results Template

### iOS Test Results
| Test Case | Device Model | iOS Version | Result | Notes |
|-----------|--------------|-------------|--------|-------|
| A1: Local Network | iPhone ___ | ___._ | ✅/❌ | |
| A2: Camera | iPhone ___ | ___._ | ✅/❌ | |
| A3: Photo Library | iPhone ___ | ___._ | ✅/❌ | |
| A4: HTTP Requests | iPhone ___ | ___._ | ✅/❌ | |

### Android Test Results
| Test Case | Device Model | Android Version | Result | Notes |
|-----------|--------------|-----------------|--------|-------|
| B1: Camera | ___ | ___._ | ✅/❌ | |
| B2: Photo Library | ___ | ___._ | ✅/❌ | |
| B3: Internet | ___ | ___._ | ✅/❌ | |
| B4: Network State | ___ | ___._ | ✅/❌ | |

---

## Common Issues & Troubleshooting

### iOS

**Issue:** Local network permission doesn't appear
- **Solution:** Check that `NSBonjourServices` and `NSLocalNetworkUsageDescription` are in Info.plist
- **Solution:** Verify `triggerLocalNetworkPermission()` is called in AppDelegate
- **Solution:** Try on iOS 14+ device (permission not needed on iOS 13)

**Issue:** Camera/Photo library permission already granted
- **Solution:** Delete app and reinstall, OR go to Settings > General > Transfer or Reset iPhone > Reset Location & Privacy

**Issue:** HTTP requests fail with "The resource could not be loaded"
- **Solution:** Check that `NSAppTransportSecurity` allows local networking in Info.plist
- **Solution:** Verify backend is accessible at `http://[IP]:8000` from Safari on the device

### Android

**Issue:** Camera permission not appearing
- **Solution:** Verify `CAMERA` permission is in AndroidManifest.xml
- **Solution:** Check that targetSdkVersion is 23 or higher (requires runtime permissions)

**Issue:** Photo picker doesn't request permission on Android 13+
- **Solution:** This is expected behavior (scoped storage)

**Issue:** Permission already granted
- **Solution:** Clear app data: Settings > Apps > Nomad Notes > Storage > Clear data
- **Solution:** Uninstall and reinstall the app

**Issue:** Backend connection fails
- **Solution:** Verify phone and computer are on same WiFi network
- **Solution:** Check firewall isn't blocking port 8000
- **Solution:** Test backend URL in Chrome on the phone

---

## Success Criteria

### iOS
- ✅ Local network permission dialog appears on first launch
- ✅ Camera permission dialog appears when taking photo
- ✅ Photo library permission dialog appears when selecting from library
- ✅ All permissions can be granted/denied/re-enabled
- ✅ HTTP requests to local backend succeed with permissions granted
- ✅ Photos can be captured and attached to notes

### Android
- ✅ Camera permission dialog appears when taking photo (API 23+)
- ✅ Storage permission dialog appears when needed (API 23-32)
- ✅ All permissions can be granted/denied/re-enabled
- ✅ HTTP requests to backend succeed
- ✅ Photos can be captured and attached to notes
- ✅ App works on both WiFi and mobile data

---

## Notes for Tester

1. **First-time permissions are critical** - Test on clean installs to verify permission prompts appear correctly
2. **Test permission denial flows** - Ensure app handles denied permissions gracefully with clear error messages
3. **Test Settings re-enable** - Verify that enabling permissions in system Settings allows functionality
4. **Document edge cases** - Note any unexpected behavior or error messages
5. **Network testing** - Test both local network (HTTP) and internet connectivity scenarios

## Files Modified

### iOS
- `nomad_notes/ios/Runner/AppDelegate.swift` - Added local network permission trigger
- `nomad_notes/ios/Runner/Info.plist` - Added all permission descriptions and network settings
- `nomad_notes/ios/Runner/Runner.entitlements` - Added wifi-info capability
- `nomad_notes/ios/Runner.xcodeproj/project.pbxproj` - Updated deployment target to iOS 14.0

### Android
- `nomad_notes/android/app/src/main/AndroidManifest.xml` - Added all necessary permissions
