# Simulator Testing Guide

Comprehensive guide for testing React Native apps on iOS Simulator and Android Emulator.

## Table of Contents

1. [iOS Simulator Setup](#ios-simulator-setup)
2. [Android Emulator Setup](#android-emulator-setup)
3. [Running the App](#running-the-app)
4. [Debugging](#debugging)
5. [Common Issues](#common-issues)

---

## iOS Simulator Setup

### Prerequisites

- **macOS only** (iOS Simulator requires macOS)
- **Xcode 14+** installed from App Store
- **Xcode Command Line Tools** installed

### Install Xcode Command Line Tools

```bash
xcode-select --install
```

### Verify Installation

```bash
xcrun simctl list devices
```

**Expected:** List of iOS simulators (iPhone 14, 15, etc.)

### Create New iOS Simulator (Optional)

1. Open **Xcode**
2. Go to **Window > Devices and Simulators**
3. Click **Simulators** tab
4. Click **+** button
5. Choose:
   - **Device Type:** iPhone 15 Pro
   - **iOS Version:** Latest available
   - **Name:** Custom name (optional)
6. Click **Create**

### Recommended Simulators

For testing, create these simulators:

- **iPhone 15 Pro** - Modern flagship, 6.1" screen
- **iPhone SE (3rd gen)** - Small screen (4.7")
- **iPad Pro (12.9")** - Tablet testing

### Manage Simulators via CLI

```bash
# List all simulators
xcrun simctl list devices

# Boot a specific simulator
xcrun simctl boot "iPhone 15 Pro"

# Open Simulator app
open -a Simulator

# Shutdown all simulators
xcrun simctl shutdown all

# Erase simulator (factory reset)
xcrun simctl erase "iPhone 15 Pro"

# Delete simulator
xcrun simctl delete "iPhone 15 Pro"

# Install app on simulator
xcrun simctl install booted path/to/app.app

# Uninstall app
xcrun simctl uninstall booted com.nomadnotes.app
```

---

## Android Emulator Setup

### Prerequisites

- **Android Studio** installed (any OS)
- **Android SDK** installed via Android Studio
- **Intel HAXM** (Windows/macOS Intel) or **Hypervisor.Framework** (macOS Apple Silicon)

### Install Android Studio

1. Download from https://developer.android.com/studio
2. Run installer
3. Follow setup wizard:
   - Install **Android SDK**
   - Install **Android Virtual Device (AVD)**
   - Install **SDK Tools**

### Create Android Virtual Device (AVD)

#### Via Android Studio GUI:

1. Open **Android Studio**
2. Click **More Actions > Virtual Device Manager** (or Tools > Device Manager)
3. Click **Create Device**
4. Choose a device:
   - **Phone:** Pixel 5, Pixel 7
   - **Tablet:** Pixel Tablet
5. Click **Next**
6. Select system image:
   - **Recommended:** Latest API (e.g., API 34 - Android 14)
   - **ABI:** x86_64 (Intel/AMD) or arm64-v8a (Apple Silicon)
7. Click **Next**
8. Configure AVD:
   - **Name:** Pixel_5_API_34
   - **Startup orientation:** Portrait
   - **Graphics:** Hardware (faster)
9. Click **Finish**

#### Via Command Line:

```bash
# List available system images
sdkmanager --list | grep system-images

# Download system image (example: API 34 for x86_64)
sdkmanager "system-images;android-34;google_apis;x86_64"

# Create AVD
avdmanager create avd \
  --name Pixel_5_API_34 \
  --package "system-images;android-34;google_apis;x86_64" \
  --device "pixel_5"

# List created AVDs
avdmanager list avd
```

### Recommended AVDs

Create these for testing:

- **Pixel 5 (API 34)** - Modern device, 6.0" screen
- **Pixel 7 (API 34)** - Latest flagship, 6.3" screen
- **Pixel Tablet (API 34)** - Tablet testing (10.95")

### Manage AVDs via CLI

```bash
# List available AVDs
emulator -list-avds

# Start AVD
emulator -avd Pixel_5_API_34

# Start with options
emulator -avd Pixel_5_API_34 \
  -no-snapshot-load \     # Cold boot
  -gpu host \             # Hardware acceleration
  -no-boot-anim           # Skip boot animation

# Start in background
emulator -avd Pixel_5_API_34 > /dev/null 2>&1 &

# Check running emulators
adb devices

# Kill all emulators
adb devices | grep emulator | cut -f1 | xargs -I {} adb -s {} emu kill

# Delete AVD
avdmanager delete avd --name Pixel_5_API_34
```

### Configure Emulator Performance

Edit AVD config file:

**macOS/Linux:** `~/.android/avd/Pixel_5_API_34.avd/config.ini`
**Windows:** `C:\Users\USERNAME\.android\avd\Pixel_5_API_34.avd\config.ini`

```ini
# Increase RAM for better performance
hw.ramSize=4096

# Enable hardware acceleration
hw.gpu.enabled=yes
hw.gpu.mode=host

# Increase internal storage
disk.dataPartition.size=4096M
```

---

## Running the App

### Method 1: Using npm scripts with environment variable

**iOS:**
```bash
# Set API URL and run on iOS
NOMAD_API_URL=http://10.0.56.2:8000 npm run ios

# Run on specific simulator
NOMAD_API_URL=http://10.0.56.2:8000 npm run ios -- --simulator="iPhone 15 Pro"
```

**Android:**
```bash
# Ensure emulator is running FIRST
emulator -avd Pixel_5_API_34 &

# Set API URL and run on Android
NOMAD_API_URL=http://10.0.56.2:8000 npm run android
```

### Method 2: Using pre-configured scripts

```bash
# Development environment (uses 10.0.56.2:8000)
npm run ios:dev
npm run android:dev

# Staging environment
npm run ios:staging
npm run android:staging
```

### Method 3: Start Metro bundler separately

```bash
# Terminal 1: Start Metro bundler
NOMAD_API_URL=http://10.0.56.2:8000 npm start

# Terminal 2: Run on iOS
i  # Press 'i' in Metro terminal

# OR run on Android
a  # Press 'a' in Metro terminal
```

### Metro Bundler Shortcuts

When Metro is running, press:

- **i** - Run on iOS simulator
- **a** - Run on Android emulator
- **r** - Reload app
- **d** - Open developer menu
- **j** - Open Chrome DevTools
- **c** - Clear Metro cache
- **q** - Quit Metro

---

## Debugging

### iOS Simulator Debugging

#### Open Developer Menu

**Simulator:** Press `Cmd + D` (or Device > Shake Gesture)

#### Common Debug Actions

```bash
# Enable Fast Refresh (auto-reload on save)
# In-app: Shake > Enable Fast Refresh

# Open React DevTools
# In-app: Shake > Open React DevTools

# View console logs
# Terminal where Metro is running shows logs

# View iOS system logs
xcrun simctl spawn booted log stream --predicate 'processImagePath endswith "nomad-notes-rn"'

# View app logs in Xcode
# Xcode > Window > Devices and Simulators > Select device > View Console
```

#### Network Debugging

```bash
# iOS Simulator uses host network by default
# Test backend connectivity from simulator:
# Open Safari in simulator > go to http://10.0.56.2:8000/api/docs/
```

### Android Emulator Debugging

#### Open Developer Menu

**Emulator:** Press `Cmd + M` (macOS) or `Ctrl + M` (Windows/Linux)
**Or:** Shake gesture via menu bar > ... > Virtual sensors > Move

#### Common Debug Actions

```bash
# Enable Fast Refresh
# In-app: Shake > Enable Fast Refresh

# Open React DevTools
# In-app: Shake > Open React DevTools

# View console logs (filtered)
adb logcat | grep ReactNativeJS

# View all logs
adb logcat

# View app-specific logs
adb logcat | grep "com.nomadnotes.app"

# Clear logs
adb logcat -c
```

#### Network Debugging

```bash
# Test backend connectivity from emulator
adb shell
curl http://10.0.56.2:8000/api/docs/

# Or use Chrome in emulator
# Open Chrome > go to http://10.0.56.2:8000/api/docs/
```

### React Native Debugger

Install standalone debugger:

```bash
# macOS
brew install --cask react-native-debugger

# Windows (via Chocolatey)
choco install react-native-debugger

# Or download from:
# https://github.com/jhen0409/react-native-debugger/releases
```

**Usage:**
1. Start React Native Debugger app
2. In app, shake device > "Debug"
3. Debugger will connect automatically

### Chrome DevTools

```bash
# In Metro terminal, press 'j'
# Or in app: Shake > "Debug"
# Opens Chrome DevTools at http://localhost:8081/debugger-ui/
```

---

## Common Issues

### iOS Simulator Issues

#### Issue: "No devices found"

**Solution:**
```bash
# Boot simulator manually
xcrun simctl boot "iPhone 15 Pro"
open -a Simulator

# Then run app
npm run ios
```

#### Issue: "Build failed" or TypeScript errors

**Solution:**
```bash
# Clear Metro cache
npm start -- --reset-cache

# Clean build
cd ios && xcodebuild clean && cd ..

# Reinstall dependencies
rm -rf node_modules
npm install

# Run again
npm run ios
```

#### Issue: Simulator is slow

**Solution:**
```bash
# Shutdown simulator
xcrun simctl shutdown all

# Erase simulator (factory reset)
xcrun simctl erase "iPhone 15 Pro"

# Restart Mac (frees up memory)
sudo reboot
```

#### Issue: "Unable to connect to development server"

**Solution:**
```bash
# Ensure Metro is running on correct port
lsof -i :8081  # Should show node process

# Restart Metro
npm start -- --reset-cache
```

### Android Emulator Issues

#### Issue: Emulator won't start

**Solution:**
```bash
# Check if HAXM/virtualization is enabled
# macOS: System Preferences > Security & Privacy > Allow kernel extension

# Cold boot emulator
emulator -avd Pixel_5_API_34 -no-snapshot-load

# Or recreate AVD
avdmanager delete avd --name Pixel_5_API_34
# Then recreate via Android Studio
```

#### Issue: "Could not connect to development server"

**Solution:**
```bash
# Reverse port forwarding (Metro runs on host port 8081)
adb reverse tcp:8081 tcp:8081

# Restart Metro
npm start -- --reset-cache

# Reload app
# In-app: Shake > Reload (or press 'r' in Metro terminal)
```

#### Issue: App crashes on startup

**Solution:**
```bash
# Clear app data
adb shell pm clear com.nomadnotes.app

# Uninstall and reinstall
adb uninstall com.nomadnotes.app
npm run android

# Check logs for error
adb logcat | grep ReactNativeJS
```

#### Issue: Emulator is slow

**Solution:**
```bash
# Increase RAM in AVD settings
# Edit ~/.android/avd/Pixel_5_API_34.avd/config.ini
# Set: hw.ramSize=4096

# Enable hardware acceleration
# Ensure "Graphics: Hardware" is selected in AVD settings

# Close other apps to free resources
```

### Network Issues (Both Platforms)

#### Issue: "Cannot connect to server"

**Solution:**
```bash
# 1. Verify backend is running
curl http://10.0.56.2:8000/api/docs/

# 2. Check API URL is set
echo $NOMAD_API_URL

# 3. Check backend is listening on 0.0.0.0 (not 127.0.0.1)
# In backend docker-compose.yml:
# command: python manage.py runserver 0.0.0.0:8000

# 4. Check firewall allows port 8000
# macOS: System Preferences > Security & Privacy > Firewall

# 5. Restart app with correct URL
NOMAD_API_URL=http://YOUR_IP:8000 npm start
```

#### Issue: "Network request failed"

**Solution:**
```bash
# Check if simulator/emulator has internet access
# iOS: Open Safari > visit google.com
# Android: Open Chrome > visit google.com

# If no internet:
# - Restart simulator/emulator
# - Check host machine internet connection
# - Check VPN is not blocking local network
```

---

## Testing Checklist

Before considering testing complete, verify:

### Functionality Tests

- [ ] **Sign Up:** Create new account successfully
- [ ] **Sign In:** Login with existing account
- [ ] **Token Refresh:** App stays signed in after closing/reopening
- [ ] **Create Note:** Create note and see it in list
- [ ] **Edit Note:** Tap note, edit, save changes
- [ ] **Delete Note:** Delete note from list
- [ ] **Sign Out:** Sign out and return to login screen

### Network Tests

- [ ] **Backend connectivity:** Can reach `http://YOUR_IP:8000/api/docs/`
- [ ] **API calls work:** Backend logs show successful requests
- [ ] **Token refresh:** 401 errors trigger automatic token refresh
- [ ] **Error handling:** Offline mode shows appropriate error messages

### UI Tests

- [ ] **Splash screen:** Shows during initial load
- [ ] **Auth screens:** SignIn and SignUp forms work correctly
- [ ] **Navigation:** Tabs switch between Notes and Profile
- [ ] **Loading states:** Spinners show during API calls
- [ ] **Error messages:** Snackbars display errors properly

### Platform-Specific Tests

**iOS:**
- [ ] Safe area insets respected (notch, home indicator)
- [ ] Keyboard dismissal works (tap outside)
- [ ] Gestures work (swipe back)

**Android:**
- [ ] Back button navigation works
- [ ] Status bar color correct
- [ ] Material Design ripple effects work

---

## Performance Tips

### iOS Simulator

- **Use Release mode for performance testing:**
  ```bash
  npm run ios -- --configuration Release
  ```

- **Disable slow animations:**
  Simulator > Debug > Toggle Slow Animations

- **Use newer Macs:**
  M1/M2/M3 Macs run simulators significantly faster than Intel

### Android Emulator

- **Use x86_64 images on Intel/AMD:**
  Much faster than ARM images

- **Use arm64-v8a images on Apple Silicon:**
  Native performance on M1/M2/M3 Macs

- **Enable hardware acceleration:**
  Ensure GPU acceleration is enabled in AVD settings

- **Allocate more resources:**
  Increase RAM to 4GB or more in AVD config

---

## Quick Reference Commands

### iOS Simulator

```bash
# List simulators
xcrun simctl list devices

# Boot simulator
xcrun simctl boot "iPhone 15 Pro"

# Run app
NOMAD_API_URL=http://10.0.56.2:8000 npm run ios

# Reset simulator
xcrun simctl erase "iPhone 15 Pro"

# View logs
xcrun simctl spawn booted log stream
```

### Android Emulator

```bash
# List AVDs
emulator -list-avds

# Start emulator
emulator -avd Pixel_5_API_34 &

# Run app (ensure emulator is already running)
NOMAD_API_URL=http://10.0.56.2:8000 npm run android

# View logs
adb logcat | grep ReactNativeJS

# Restart ADB
adb kill-server && adb start-server
```

### Debugging

```bash
# Clear Metro cache
npm start -- --reset-cache

# Reload app
# Press 'r' in Metro terminal

# Open DevTools
# Press 'j' in Metro terminal

# Check running processes
lsof -i :8081  # Metro bundler
lsof -i :8000  # Backend API
```

---

## Resources

- **React Native Debugging:** https://reactnative.dev/docs/debugging
- **iOS Simulator Guide:** https://developer.apple.com/documentation/xcode/running-your-app-in-simulator
- **Android Emulator Guide:** https://developer.android.com/studio/run/emulator
- **Expo Debugging:** https://docs.expo.dev/debugging/runtime-issues/

**Happy Testing!**
