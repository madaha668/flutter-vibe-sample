# Nomad Notes React Native - Quick Start Guide

Get the app running in 5 minutes!

## Prerequisites Check

Before starting, ensure you have:

- [ ] **Node.js 18+** installed (`node --version`)
- [ ] **npm or yarn** installed (`npm --version`)
- [ ] **Backend running** at accessible IP (e.g., `http://10.0.56.2:8000`)
- [ ] **iOS Simulator** (macOS with Xcode) OR **Android Emulator** (Android Studio)

## Step 1: Install Dependencies

```bash
cd nomad_notes_rn
npm install
```

**Expected output:** Dependencies installed without errors (~2 minutes)

## Step 2: Find Your Backend IP

The backend must be accessible from simulators/emulators. **DO NOT use `localhost` or `127.0.0.1`!**

### Find Your Network IP:

**macOS/Linux:**
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

**Windows:**
```bash
ipconfig
```

**Example output:** `inet 10.0.56.2` → Use `http://10.0.56.2:8000`

## Step 3: Verify Backend is Accessible

```bash
# Replace 10.0.56.2 with YOUR network IP
curl http://10.0.56.2:8000/api/docs/
```

**Expected:** HTML response (API documentation page)

**If this fails:**
- Ensure backend is running: `cd ../backend && docker compose up`
- Check backend is listening on `0.0.0.0:8000` (not `127.0.0.1:8000`)
- Check firewall allows port 8000

## Step 4: Run on iOS Simulator (macOS Only)

```bash
# Replace 10.0.56.2 with YOUR backend IP
NOMAD_API_URL=http://10.0.56.2:8000 npm run ios
```

**What happens:**
1. Metro bundler starts
2. iOS Simulator opens automatically
3. App builds and launches (~2 minutes first time)
4. You should see the Sign In screen

## Step 5: Run on Android Emulator

### 5a. Start Android Emulator First

**Option 1: Via Android Studio**
- Open Android Studio
- Click "Device Manager" (phone icon)
- Click ▶ next to any emulator

**Option 2: Via Command Line**
```bash
# List available emulators
emulator -list-avds

# Start one (example)
emulator -avd Pixel_5_API_34 &
```

### 5b. Launch App

```bash
# Replace 10.0.56.2 with YOUR backend IP
NOMAD_API_URL=http://10.0.56.2:8000 npm run android
```

**What happens:**
1. Metro bundler starts
2. App builds and installs on emulator (~2 minutes first time)
3. You should see the Sign In screen

## Step 6: Test the App

### Create an Account

1. Tap "Don't have an account? Sign Up"
2. Enter:
   - Full Name: `Test User`
   - Email: `test@example.com`
   - Password: `testpass123` (min 8 chars)
3. Tap "Sign Up"

**Expected:** App navigates to Notes List screen (empty state)

### Create a Note

1. Tap the **+** (FAB button) at bottom-right
2. Enter:
   - Title: `My First Note`
   - Note: `This is a test note from React Native app`
3. Tap the **✓** (checkmark) in header

**Expected:** Returns to list, note appears

### Verify Backend Received Data

```bash
# Check backend logs
cd ../backend
docker compose logs -f backend

# You should see POST requests:
# POST /api/auth/signup/ 201
# POST /api/notes/ 201
```

## Quick Reference

### Run Commands

```bash
# iOS (macOS only)
NOMAD_API_URL=http://YOUR_IP:8000 npm run ios

# Android
NOMAD_API_URL=http://YOUR_IP:8000 npm run android

# Web browser
NOMAD_API_URL=http://YOUR_IP:8000 npm run web

# Pre-configured development scripts
npm run ios:dev      # Uses http://10.0.56.2:8000
npm run android:dev  # Uses http://10.0.56.2:8000
```

### Common Issues

#### "Cannot connect to server"

**Solution:**
```bash
# 1. Check backend is running
curl http://YOUR_IP:8000/api/docs/

# 2. Check you set NOMAD_API_URL
echo $NOMAD_API_URL

# 3. Restart with correct URL
NOMAD_API_URL=http://YOUR_IP:8000 npm start
```

#### iOS: "No devices found"

**Solution:**
```bash
# Open Simulator app manually
open -a Simulator

# Then run again
npm run ios
```

#### Android: "Could not connect to development server"

**Solution:**
```bash
# 1. Ensure emulator is running
adb devices  # Should list emulator

# 2. Restart Metro bundler
npm start -- --reset-cache

# 3. Try again
npm run android
```

#### "Module not found" or TypeScript errors

**Solution:**
```bash
# Clear everything and reinstall
rm -rf node_modules
npm install
npm start -- --clear
```

## Environment Variables Reference

| Variable | Description | Example |
|----------|-------------|---------|
| `NOMAD_API_URL` | Backend API base URL | `http://10.0.56.2:8000` |

**CRITICAL:** NEVER use `localhost` or `127.0.0.1` from simulators/emulators!

## What's Next?

- **Read Full Documentation:** See `README.md` for detailed info
- **Test Different Environments:** Try staging/production URLs
- **Run on Physical Device:** See README.md "Testing on Real Devices"
- **Compare with Flutter:** Check `../nomad_notes/` for Flutter implementation

## Troubleshooting Resources

1. **Check backend logs:** `docker compose logs -f backend`
2. **Check Metro bundler:** Look for errors in terminal
3. **Check app logs:**
   - iOS: Xcode > Window > Devices and Simulators > View Console
   - Android: `adb logcat | grep ReactNativeJS`
4. **Full documentation:** `README.md`
5. **Backend docs:** `../backend/README.md`

## Success Criteria

You're all set if:

- ✅ App launches without crashing
- ✅ You can sign up successfully
- ✅ You can create and view notes
- ✅ Backend logs show successful API calls
- ✅ No "cannot connect" errors

**Enjoy building with React Native + Django!**
