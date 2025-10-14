# macOS Network Permission Fix

## Problem

The macOS Flutter app was showing:
```
"Failed to connect to server..."
```

Even though:
- ✅ Backend was running and accessible at `http://10.0.56.2:8000`
- ✅ Browser could access `http://10.0.56.2:8000/api/docs/` successfully
- ✅ Other tools (curl, browser) worked fine

## Root Cause

**macOS App Sandbox Security**

macOS apps require explicit entitlements (permissions) to access network resources. The app had:
- ✅ `com.apple.security.network.server` - Permission to RECEIVE incoming connections
- ❌ `com.apple.security.network.client` - **MISSING** Permission to MAKE outgoing connections

Without the client entitlement, macOS blocked all HTTP requests from the app, even though the browser could access the same URL.

## Evidence

Backend logs showed NO requests from the macOS app:
```bash
# Only browser requests visible:
INFO 2025-10-14 07:57:15,564 basehttp "GET /api/docs/ HTTP/1.1" 200 4648

# No POST /api/auth/signin/ requests from macOS app
```

This confirmed the requests were blocked at the OS level before reaching the network.

## Solution

Added `com.apple.security.network.client` entitlement to both Debug and Release configurations:

### Files Modified:

**1. `nomad_notes/macos/Runner/DebugProfile.entitlements`**
```xml
<key>com.apple.security.network.client</key>
<true/>
```

**2. `nomad_notes/macos/Runner/Release.entitlements`**
```xml
<key>com.apple.security.network.client</key>
<true/>
```

## Testing

After this fix:

1. **Stop the current macOS app** (if running)
2. **Rebuild and run:**
   ```bash
   cd nomad_notes
   flutter clean
   flutter run -d macos
   ```

3. **Try to sign in** with existing credentials
4. **Check backend logs** - you should now see:
   ```bash
   docker-compose logs -f backend

   # Expected output:
   INFO basehttp "OPTIONS /api/auth/signin/ HTTP/1.1" 200 0
   INFO basehttp "POST /api/auth/signin/ HTTP/1.1" 200 683
   ```

## Why This Happened

Flutter's default macOS template doesn't include network client permissions because:
- Not all apps need network access
- Apple requires explicit permission declarations for security
- Developers must consciously grant network access

This is common when converting existing mobile apps to macOS - the iOS/Android apps don't need these entitlements, but macOS does.

## Additional Notes

### App Sandbox Entitlements Explained:

- `com.apple.security.app-sandbox` - Enables App Sandbox (required for Mac App Store)
- `com.apple.security.cs.allow-jit` - Allows Just-In-Time compilation (needed for Flutter)
- `com.apple.security.network.server` - Accept incoming connections (for local servers)
- `com.apple.security.network.client` - Make outgoing connections (for API calls) ← **This was missing**

### When You'd Need to Add More Entitlements:

- **File access**: `com.apple.security.files.user-selected.read-write`
- **Camera**: `com.apple.security.device.camera`
- **Microphone**: `com.apple.security.device.audio-input`
- **Bluetooth**: `com.apple.security.device.bluetooth`
- **Location**: `com.apple.security.personal-information.location`

See Apple's documentation for full list: https://developer.apple.com/documentation/bundleresources/entitlements

## Result

✅ macOS app can now make HTTP requests to the backend
✅ Sign in/Sign up should work
✅ All API calls will succeed
✅ Backend logs will show requests from the macOS app
