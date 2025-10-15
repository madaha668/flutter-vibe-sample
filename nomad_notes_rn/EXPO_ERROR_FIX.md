# Fixing Expo API Fetch Error

## The Error

```
FetchError: request to https://api.expo.dev/v2/sdks/51.0.0/native-modules failed
```

## Root Causes & Solutions

### Solution 1: Use Offline Mode (RECOMMENDED - Try First)

Expo can run completely offline without fetching from api.expo.dev:

```bash
# Clear Expo cache
rm -rf .expo

# Start in offline mode
EXPO_OFFLINE=1 NOMAD_API_URL=http://10.0.56.2:8000 npx expo start --ios --offline

# Or use npm script with offline flag
NOMAD_API_URL=http://10.0.56.2:8000 npx expo start --offline
```

Then press `i` to open iOS simulator.

---

### Solution 2: Clear All Caches

```bash
# 1. Clear Expo cache
rm -rf .expo

# 2. Clear npm cache
npm cache clean --force

# 3. Clear Metro bundler cache
rm -rf node_modules/.cache

# 4. Clear watchman cache (if installed)
watchman watch-del-all

# 5. Reinstall node_modules
rm -rf node_modules
npm install

# 6. Try again with offline mode
EXPO_OFFLINE=1 NOMAD_API_URL=http://10.0.56.2:8000 npx expo start --ios --offline
```

---

### Solution 3: Check Network/Proxy/VPN

The error suggests a network connectivity issue to api.expo.dev:

```bash
# Test if you can reach api.expo.dev
curl -I https://api.expo.dev/v2/sdks/51.0.0/native-modules

# If this fails, you have a network issue:
# - Check if you're behind a corporate firewall
# - Check if you're using a VPN that blocks api.expo.dev
# - Check proxy settings
```

**If behind proxy, configure npm:**

```bash
npm config set proxy http://proxy.company.com:8080
npm config set https-proxy http://proxy.company.com:8080

# Or set environment variables
export HTTP_PROXY=http://proxy.company.com:8080
export HTTPS_PROXY=http://proxy.company.com:8080
```

---

### Solution 4: Use React Native CLI (Without Expo)

If Expo continues to fail, you can run the app with vanilla React Native CLI:

**For iOS:**
```bash
# Install CocoaPods (if not installed)
sudo gem install cocoapods

# Create ios directory (if using pure RN)
npx react-native init TempProject
# Copy ios folder from TempProject to your project

# Install pods
cd ios
pod install
cd ..

# Run with React Native CLI
npx react-native run-ios
```

**For Android:**
```bash
# Run with React Native CLI
npx react-native run-android
```

---

### Solution 5: Downgrade Expo SDK (If All Else Fails)

If the issue is specific to Expo SDK 51, try SDK 50:

```bash
# Downgrade Expo
npm install expo@~50.0.0

# Update other dependencies
npx expo install --fix

# Try again
NOMAD_API_URL=http://10.0.56.2:8000 npx expo start --ios --offline
```

---

## Quick Fix Command Sequence

Try these in order until one works:

### Try 1: Offline Mode (Fastest)
```bash
EXPO_OFFLINE=1 NOMAD_API_URL=http://10.0.56.2:8000 npx expo start --offline
# Press 'i' for iOS
```

### Try 2: Clear Cache + Offline
```bash
rm -rf .expo node_modules/.cache
EXPO_OFFLINE=1 NOMAD_API_URL=http://10.0.56.2:8000 npx expo start --offline
```

### Try 3: Full Clean + Offline
```bash
rm -rf .expo node_modules/.cache node_modules
npm install
EXPO_OFFLINE=1 NOMAD_API_URL=http://10.0.56.2:8000 npx expo start --offline
```

### Try 4: Check Network
```bash
# Test connectivity
curl -I https://api.expo.dev/v2/sdks/51.0.0/native-modules

# If it times out or fails, you have a network/firewall issue
# Use offline mode or fix network settings
```

---

## Updated npm Scripts

Add these to your package.json for easier offline usage:

```json
{
  "scripts": {
    "start": "expo start",
    "start:offline": "expo start --offline",
    "ios": "expo start --ios",
    "ios:offline": "EXPO_OFFLINE=1 expo start --ios --offline",
    "android": "expo start --android",
    "android:offline": "EXPO_OFFLINE=1 expo start --android --offline",
    "ios:dev": "NOMAD_API_URL=http://10.0.56.2:8000 expo start --ios --offline",
    "android:dev": "NOMAD_API_URL=http://10.0.56.2:8000 expo start --android --offline"
  }
}
```

Then use:
```bash
npm run ios:dev
# or
npm run android:dev
```

---

## Why This Happens

1. **Network Issues:** Firewall, VPN, or proxy blocking api.expo.dev
2. **Certificate Issues:** SSL certificate validation failing
3. **Expo Cache Corruption:** Cached data is invalid
4. **DNS Issues:** Can't resolve api.expo.dev

## Best Practice

**Always use offline mode for local development:**

- Faster startup (no API calls)
- Works without internet
- Avoids rate limiting
- More reliable

```bash
# Add to your shell profile (~/.zshrc or ~/.bashrc)
export EXPO_OFFLINE=1

# Then you can just run
npm run ios
```

---

## Verification

After trying a solution, verify it works:

```bash
# Start Metro bundler
EXPO_OFFLINE=1 NOMAD_API_URL=http://10.0.56.2:8000 npx expo start --offline

# You should see:
# ✔ Metro bundler is running
# ✔ Development server running at: exp://localhost:8081
# Press 'i' to open iOS simulator
```

Press `i` and the iOS simulator should open with your app.

---

## Still Not Working?

If none of these work, provide:

1. **Your network setup:** Behind firewall? Using VPN?
2. **Can you access:** `curl https://api.expo.dev/` (yes/no)
3. **Your Node version:** `node --version`
4. **Your npm version:** `npm --version`
5. **Your Expo version:** `npx expo --version`

Then we can provide more specific help.
