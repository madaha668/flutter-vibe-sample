# Building Native iOS App (Without Expo Go)

## Current Error

```
CommandError: Expo Go is not installed on device "iPhone 16 Plus",
while running in offline mode.
```

## Why This Happens

- **Expo Go** is a development app that runs your code
- In **offline mode**, Expo can't download/install Expo Go
- **Solution:** Either use online mode to install Expo Go, OR build a native app

---

## Solution 1: Use Expo Go (Easiest - RECOMMENDED)

Let Expo download and install Expo Go (requires internet once):

```bash
# Allow online mode to install Expo Go
NOMAD_API_URL=http://10.0.56.2:8000 npx expo start --ios

# The first time, it will:
# 1. Download Expo Go (~100MB)
# 2. Install it on the simulator
# 3. Launch your app inside Expo Go

# After that, you can use offline mode
```

**After first run, Expo Go is installed, and you can use offline mode:**

```bash
NOMAD_API_URL=http://10.0.56.2:8000 npm run ios:dev
```

---

## Solution 2: Build Native iOS App (No Expo Go)

Create a standalone native iOS app that doesn't require Expo Go:

### Step 1: Generate Native iOS Project

```bash
cd /Volumes/Sandisk1TB0/src/flutter/nomad_notes_rn

# Generate ios/ directory with native Xcode project
npx expo prebuild --platform ios --clean
```

**What this does:**
- Creates `ios/` directory
- Generates Xcode project
- Configures native dependencies
- Creates a standalone app

### Step 2: Install CocoaPods Dependencies

```bash
cd ios
pod install
cd ..
```

### Step 3: Run Native iOS App

```bash
# Option A: Use Expo (still works with native builds)
NOMAD_API_URL=http://10.0.56.2:8000 npx expo run:ios --device "iPhone 16 Plus"

# Option B: Use React Native CLI
NOMAD_API_URL=http://10.0.56.2:8000 npx react-native run-ios --simulator="iPhone 16 Plus"

# Option C: Open in Xcode and run
open ios/nomadnotesrn.xcworkspace
# Then click Run button in Xcode
```

---

## Solution 3: Install Expo Go Manually

Install Expo Go on the simulator manually:

```bash
# 1. Boot the simulator
xcrun simctl boot "iPhone 16 Plus"

# 2. Download Expo Go
curl -L -o ExpoGo.tar.gz https://dpq5q02fu5f55.cloudfront.net/Exponent-2.31.2.tar.gz

# 3. Extract
tar -xvf ExpoGo.tar.gz

# 4. Install on simulator
xcrun simctl install booted Exponent.app

# 5. Now offline mode will work
NOMAD_API_URL=http://10.0.56.2:8000 npm run ios:dev
```

---

## Comparison

| Method | Pros | Cons |
|--------|------|------|
| **Expo Go (Solution 1)** | Fast setup, hot reload, easy debugging | Needs initial online connection |
| **Native Build (Solution 2)** | Production-ready, no Expo Go needed | Slower builds, larger setup |
| **Manual Install (Solution 3)** | Works offline after setup | Manual download required |

---

## RECOMMENDED: Solution 1 (Use Expo Go Online Once)

**Just run this:**

```bash
cd /Volumes/Sandisk1TB0/src/flutter/nomad_notes_rn

# Allow online access ONCE to install Expo Go
NOMAD_API_URL=http://10.0.56.2:8000 npx expo start --ios

# Wait for Expo Go to install (~1-2 minutes)
# Your app will launch automatically
```

**After this first run:**
- Expo Go is installed on the simulator
- You can use offline mode: `npm run ios:dev`
- No more "Expo Go not installed" errors

---

## Troubleshooting

### "Expo Go is not installed"

**Solution:** Remove `--offline` flag for first run:
```bash
NOMAD_API_URL=http://10.0.56.2:8000 npx expo start --ios
```

### "Network request failed"

**Solution:** Check if simulator can access internet:
- Open Safari in simulator
- Try visiting google.com
- If it fails, restart simulator

### "Unable to resolve module"

**Solution:** Clear cache and reinstall:
```bash
npm run reset
NOMAD_API_URL=http://10.0.56.2:8000 npx expo start --ios
```

### "iPhone 16 Plus not found"

**Solution:** List available simulators and choose one:
```bash
xcrun simctl list devices

# Run on specific simulator
NOMAD_API_URL=http://10.0.56.2:8000 npx expo start --ios --simulator "iPhone 15 Pro"
```

---

## After First Successful Run

Once Expo Go is installed, you can:

1. **Use offline mode:**
   ```bash
   npm run ios:dev
   ```

2. **Fast Refresh works** - edit code and see changes instantly

3. **Debug menu available** - shake simulator or Cmd+D

4. **Multiple runs without internet**

---

## Quick Fix

**Just run this command:**

```bash
cd /Volumes/Sandisk1TB0/src/flutter/nomad_notes_rn
NOMAD_API_URL=http://10.0.56.2:8000 npx expo start --ios
```

Remove the `--offline` flag for the first run. That's it!
