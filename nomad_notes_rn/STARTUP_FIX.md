# Fixing App Startup Issues

## Issues Found

1. ✅ **NOMAD_API_URL not being passed** - Environment variable not reaching the app
2. ✅ **Font loader error** - Missing `expo-font` dependency

---

## Fix #1: Install Missing Dependencies

The font error is because `expo-font` is missing. I've updated `package.json`, now install:

```bash
cd /Volumes/Sandisk1TB0/src/flutter/nomad_notes_rn

# Install new dependencies
npm install

# Clear cache
npm run clear-cache
```

**Added dependencies:**
- `expo-font` - Required for React Native Paper icons
- `expo-splash-screen` - Required for app initialization
- `react-native-vector-icons` - Required for Material icons

---

## Fix #2: Pass API URL Correctly with Expo Go

The issue is that environment variables passed via command line **don't work with Expo Go** in the standard way. We need to use Expo's environment system.

### Option A: Create .env File (Recommended for Development)

```bash
cd /Volumes/Sandisk1TB0/src/flutter/nomad_notes_rn

# Create .env file
cat > .env << 'EOF'
NOMAD_API_URL=http://10.0.56.2:8000
EOF
```

Then update `app.json` to read from .env:

Already done! Your `app.json` has:
```json
"extra": {
  "apiUrl": "${NOMAD_API_URL}"
}
```

### Option B: Set Environment Variable Before Starting Expo

For Expo Go, environment variables must be set **before** starting the Metro bundler:

```bash
# Set the variable first
export NOMAD_API_URL=http://10.0.56.2:8000

# Then start (without repeating the variable)
npm run ios

# Or in one line
NOMAD_API_URL=http://10.0.56.2:8000 npm start
# Then press 'i' in the Metro terminal
```

### Option C: Use app.config.js Instead of app.json

This allows dynamic configuration:

```bash
cd /Volumes/Sandisk1TB0/src/flutter/nomad_notes_rn

# Rename app.json to app.config.js
mv app.json app.config.js
```

Then the config will automatically pick up environment variables.

---

## Complete Fix Procedure

Run these commands in order:

```bash
# 1. Go to project directory
cd /Volumes/Sandisk1TB0/src/flutter/nomad_notes_rn

# 2. Install missing dependencies
npm install

# 3. Clear all caches
npm run clear-cache

# 4. Create .env file with your backend IP
echo "NOMAD_API_URL=http://10.0.56.2:8000" > .env

# 5. Kill any running Metro bundler (if exists)
# Press Ctrl+C in terminal where Metro is running

# 6. Start fresh with environment variable
NOMAD_API_URL=http://10.0.56.2:8000 npm start

# 7. Wait for Metro to start, then press 'i' to open iOS simulator
# Or just run:
NOMAD_API_URL=http://10.0.56.2:8000 npm run ios
```

---

## Alternative: Convert app.json to app.config.js

This is more reliable for environment variables:

```bash
cd /Volumes/Sandisk1TB0/src/flutter/nomad_notes_rn
```

I'll create the app.config.js file for you.

---

## Expected Result After Fixes

After running the fixes:

1. ✅ No font loader errors
2. ✅ NOMAD_API_URL is properly set
3. ✅ App shows Sign In screen
4. ✅ You can interact with the app

---

## Verification

After starting the app, you should see:

**In Metro Bundler output:**
```
 LOG  [API Config] Using API URL from environment: http://10.0.56.2:8000
```

**NOT:**
```
 WARN  [API Config] WARNING: NOMAD_API_URL not set!
```

**In the app:**
- Sign In screen loads without errors
- Icons display correctly
- No red error screen

---

## Quick Commands Summary

```bash
# Full reset and start
cd /Volumes/Sandisk1TB0/src/flutter/nomad_notes_rn
npm install
npm run clear-cache
echo "NOMAD_API_URL=http://10.0.56.2:8000" > .env
NOMAD_API_URL=http://10.0.56.2:8000 npm run ios
```

---

## If Still Getting "NOMAD_API_URL not set" Warning

The issue is that Expo Go has some limitations with environment variables. Let's use a different approach - **hardcode for development, but make it obvious**:

Create a new file `src/core/config/dev-config.ts`:

```typescript
// TEMPORARY: For development only
// This file should NOT be committed to git for production
export const DEV_API_URL = 'http://10.0.56.2:8000';
```

Then update `src/core/config/api-config.ts` to use it as fallback during development. But I'll show you a better solution in the next step.

---

## Next Steps

1. **Run the commands above** to install dependencies and create .env
2. **Start the app** with `NOMAD_API_URL=http://10.0.56.2:8000 npm run ios`
3. **Check Metro bundler output** - should say "Using API URL from environment"
4. **Test the app** - Sign In screen should load without errors

Let me know if you still see the warnings after this!
