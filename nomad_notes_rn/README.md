# Nomad Notes - React Native App

Cross-platform mobile application built with React Native and Expo, using the existing Django backend.

## Features

- **Authentication**: JWT-based signup/signin with automatic token refresh
- **Notes Management**: Create, read, update, and delete notes
- **Cross-Platform**: iOS, Android, and Web support
- **Material Design 3**: Consistent UI matching Flutter app
- **Environment-Based Configuration**: NO hardcoded API endpoints

## Architecture

### Technology Stack

- **React Native 0.74** with TypeScript (strict mode)
- **Expo SDK 51** for managed workflow
- **TanStack Query (React Query) v5** for server state management
- **Zustand** for client state management
- **React Navigation v6** for routing
- **React Native Paper** for Material Design 3 components
- **Axios** for HTTP client with auto token refresh

### Project Structure

```
src/
├── app/                    # App-level configuration
│   ├── navigation/         # Auth-aware routing
│   ├── providers/          # React Query, theme providers
│   └── theme/              # Material Design 3 theme
├── core/                   # Shared infrastructure
│   ├── api/                # Axios client, types
│   ├── config/             # Environment configuration (NO HARDCODED URLs!)
│   ├── storage/            # Secure token storage
│   └── utils/              # Error handling, validators
└── features/               # Feature modules
    ├── auth/               # Authentication (signup, signin, signout)
    │   ├── api/            # Auth API calls
    │   ├── hooks/          # Auth state + React Query hooks
    │   └── screens/        # SignIn, SignUp, Splash screens
    ├── notes/              # Notes management
    │   ├── api/            # Notes CRUD API
    │   ├── hooks/          # Notes queries and mutations
    │   ├── screens/        # List, Editor screens
    │   └── components/     # NoteCard component
    └── profile/            # User profile
        └── screens/        # Profile screen
```

## Prerequisites

1. **Node.js 18+** and npm/yarn
2. **Expo CLI**: `npm install -g expo-cli`
3. **Development Tools**:
   - For iOS: **Xcode 14+** (macOS only) and iOS Simulator
   - For Android: **Android Studio** with Android SDK and emulator
4. **Backend Server**: Django backend running (see `../backend/`)

## Installation

```bash
# Navigate to project directory
cd nomad_notes_rn

# Install dependencies
npm install

# Copy environment configuration
cp .env.example .env

# Edit .env and set your backend URL (IMPORTANT!)
# Example: NOMAD_API_URL=http://10.0.56.2:8000
```

## Configuration

### Backend API URL (CRITICAL!)

**NEVER hardcode the API URL!** Always pass it via environment variable:

#### Method 1: Using .env file (Development)

```bash
# .env file
NOMAD_API_URL=http://10.0.56.2:8000
```

#### Method 2: Command Line (Recommended)

```bash
# iOS Simulator
NOMAD_API_URL=http://10.0.56.2:8000 npm run ios

# Android Emulator
NOMAD_API_URL=http://10.0.56.2:8000 npm run android

# Staging environment
NOMAD_API_URL=https://staging-api.nomadnotes.com npm run ios

# Production
NOMAD_API_URL=https://api.nomadnotes.com npm run ios
```

#### Method 3: Package.json Scripts

Pre-configured scripts are available:

```bash
# Development (uses 10.0.56.2:8000)
npm run ios:dev
npm run android:dev

# Staging
npm run ios:staging
npm run android:staging
```

### Finding Your Backend IP Address

The backend must be accessible from the simulator/emulator:

```bash
# macOS/Linux
ifconfig | grep "inet "

# Windows
ipconfig

# Use the network IP (e.g., 10.0.56.2), NOT 127.0.0.1 or localhost
```

## Running the App

### 1. Start the Backend Server

```bash
cd ../backend
docker compose up
# Backend should be running at http://YOUR_IP:8000
```

### 2. Test Backend Connectivity

```bash
# From your development machine
curl http://10.0.56.2:8000/api/docs/

# Should return the API documentation page
```

### 3. Start Metro Bundler

```bash
cd nomad_notes_rn
NOMAD_API_URL=http://10.0.56.2:8000 npm start
```

### 4. Run on iOS Simulator (macOS only)

```bash
# Start iOS simulator and launch app
NOMAD_API_URL=http://10.0.56.2:8000 npm run ios

# Or use pre-configured script
npm run ios:dev

# Run on specific simulator
npm run ios -- --simulator="iPhone 15 Pro"

# List available simulators
xcrun simctl list devices
```

**iOS Simulator Networking:**
- The iOS simulator can access your host machine's network
- Use your machine's network IP (e.g., `http://10.0.56.2:8000`)
- `localhost` will NOT work (it refers to the simulator itself)

### 5. Run on Android Emulator

```bash
# Start Android emulator first (via Android Studio)
# Then launch app
NOMAD_API_URL=http://10.0.56.2:8000 npm run android

# Or use pre-configured script
npm run android:dev

# List available emulators
emulator -list-avds

# Start specific emulator
emulator -avd Pixel_5_API_34
```

**Android Emulator Networking:**
- The Android emulator can access your host machine's network
- Use your machine's network IP (e.g., `http://10.0.56.2:8000`)
- `10.0.2.2` is a special alias for `127.0.0.1` on the host (only works if backend runs on localhost)

### 6. Run on Physical Device

#### iOS (via Expo Go)

```bash
# 1. Install Expo Go from App Store
# 2. Ensure iPhone and development machine are on SAME WiFi network
# 3. Start Metro bundler
NOMAD_API_URL=http://10.0.56.2:8000 npm start

# 4. Scan QR code with Camera app
# 5. App will open in Expo Go
```

#### Android (via Expo Go)

```bash
# 1. Install Expo Go from Google Play Store
# 2. Ensure Android device and development machine are on SAME WiFi network
# 3. Start Metro bundler
NOMAD_API_URL=http://10.0.56.2:8000 npm start

# 4. Scan QR code with Expo Go app
# 5. App will load
```

**Physical Device Networking:**
- Device and development machine MUST be on the same WiFi network
- Use your machine's network IP (e.g., `http://10.0.56.2:8000`)
- Backend must be accessible from your local network (not just localhost)

### 7. Run on Web (Browser)

```bash
NOMAD_API_URL=http://10.0.56.2:8000 npm run web

# Opens browser at http://localhost:19006
```

## Testing Different Environments

### Local Development

```bash
# Backend at http://10.0.56.2:8000
NOMAD_API_URL=http://10.0.56.2:8000 npm run ios
```

### Staging Server

```bash
# Backend at https://staging-api.nomadnotes.com
NOMAD_API_URL=https://staging-api.nomadnotes.com npm run android
```

### Production Server

```bash
# Backend at https://api.nomadnotes.com
NOMAD_API_URL=https://api.nomadnotes.com npm run ios
```

## Common Issues & Troubleshooting

### Issue 1: "Cannot connect to server"

**Symptoms:** App shows "Cannot connect to server" error on signup/signin

**Solutions:**

```bash
# 1. Verify backend is running
curl http://10.0.56.2:8000/api/docs/

# 2. Check API URL is set correctly
echo $NOMAD_API_URL

# 3. Ensure you're using network IP, not localhost
# ❌ WRONG: http://localhost:8000
# ❌ WRONG: http://127.0.0.1:8000
# ✅ CORRECT: http://10.0.56.2:8000

# 4. Restart Metro bundler with correct URL
NOMAD_API_URL=http://10.0.56.2:8000 npm start
```

### Issue 2: "Network request failed"

**Symptoms:** API calls timeout or fail immediately

**Solutions:**

```bash
# iOS Simulator: Check network connectivity
# Go to Settings > WiFi (should show connected)

# Android Emulator: Check if you can access internet
# Open Chrome browser in emulator and visit google.com

# Firewall: Ensure port 8000 is not blocked
# macOS: System Preferences > Security & Privacy > Firewall
# Windows: Windows Defender Firewall

# Django: Ensure backend is listening on 0.0.0.0 (not 127.0.0.1)
# In backend docker-compose.yml or manage.py runserver command:
python manage.py runserver 0.0.0.0:8000
```

### Issue 3: iOS Simulator - "Expo Go not opening"

**Solutions:**

```bash
# 1. Reset Metro bundler cache
npm start -- --clear

# 2. Rebuild iOS app
npm run ios -- --clean

# 3. Reset iOS Simulator
# Device > Erase All Content and Settings...
```

### Issue 4: Android Emulator - "App keeps crashing"

**Solutions:**

```bash
# 1. Clear Metro cache
npm start -- --clear

# 2. Clear Android build cache
cd android && ./gradlew clean && cd ..

# 3. Restart emulator
# Close emulator and restart via Android Studio
```

### Issue 5: "Module not found" errors

**Solutions:**

```bash
# 1. Clear node_modules and reinstall
rm -rf node_modules
npm install

# 2. Clear Metro bundler cache
npm start -- --reset-cache

# 3. Clear watchman cache (macOS/Linux)
watchman watch-del-all
```

## Development Commands

```bash
# Start Metro bundler
npm start

# Run on iOS simulator
npm run ios

# Run on Android emulator
npm run android

# Run on web browser
npm run web

# Type checking
npm run type-check

# Linting
npm run lint

# Clear Metro cache
npm start -- --clear
```

## Simulator Management

### iOS Simulator Management

```bash
# List all available simulators
xcrun simctl list devices

# Boot a specific simulator
xcrun simctl boot "iPhone 15 Pro"

# Shutdown simulator
xcrun simctl shutdown all

# Reset simulator to factory state
xcrun simctl erase "iPhone 15 Pro"

# Open Simulator app
open -a Simulator

# Install app on running simulator
npm run ios -- --simulator="iPhone 15 Pro"
```

### Android Emulator Management

```bash
# List available AVDs (Android Virtual Devices)
emulator -list-avds

# Start specific emulator
emulator -avd Pixel_5_API_34

# Start emulator in background
emulator -avd Pixel_5_API_34 -no-snapshot-load &

# Kill all emulators
adb devices | grep emulator | cut -f1 | xargs -I {} adb -s {} emu kill

# Cold boot emulator (slower but fresh start)
emulator -avd Pixel_5_API_34 -no-snapshot-load

# List running emulators
adb devices
```

### Creating New Emulators

#### iOS Simulator

```bash
# Use Xcode to create/manage simulators
# Xcode > Window > Devices and Simulators
# Click "+" to add new simulator
```

#### Android Emulator

```bash
# Open Android Studio
# Tools > Device Manager > Create Device
# Or use command line:
avdmanager create avd -n Pixel_7_API_34 -k "system-images;android-34;google_apis;x86_64"
```

## Testing on Real Devices

### iOS Device (Development Build)

Requires Apple Developer account:

```bash
# Install Expo CLI tools
npm install -g eas-cli

# Login to Expo account
eas login

# Configure iOS credentials
eas build:configure

# Create development build
eas build --platform ios --profile development

# Install on connected device
eas build:run --platform ios
```

### Android Device (Development Build)

```bash
# Enable USB debugging on Android device:
# Settings > About Phone > Tap "Build Number" 7 times
# Settings > Developer Options > Enable "USB Debugging"

# Connect device via USB
# Verify device is connected
adb devices

# Install and run app
NOMAD_API_URL=http://10.0.56.2:8000 npm run android

# Note: Your computer and phone must be on the same WiFi network
# for the app to connect to the backend
```

## Building for Production

```bash
# Install EAS CLI
npm install -g eas-cli

# Configure build
eas build:configure

# Build for iOS
NOMAD_API_URL=https://api.nomadnotes.com eas build --platform ios

# Build for Android
NOMAD_API_URL=https://api.nomadnotes.com eas build --platform android

# Build for both platforms
NOMAD_API_URL=https://api.nomadnotes.com eas build --platform all
```

## API Endpoints

All endpoints match the Django backend API:

### Authentication
- `POST /api/auth/signup/` - Create account
- `POST /api/auth/signin/` - Login
- `POST /api/auth/refresh/` - Refresh access token
- `POST /api/auth/signout/` - Sign out (blacklist token)
- `GET /api/auth/me/` - Get current user

### Notes
- `GET /api/notes/` - List user's notes
- `POST /api/notes/` - Create note
- `GET /api/notes/:id/` - Get note by ID
- `PATCH /api/notes/:id/` - Update note
- `DELETE /api/notes/:id/` - Delete note

## Project Comparison

### React Native vs Flutter

**Similarities:**
- Same Django backend (zero changes)
- Same authentication flow (JWT with auto-refresh)
- Same Material Design 3 UI
- Feature-based architecture
- Type safety (TypeScript vs Dart)

**Differences:**
- **State Management**: Zustand + React Query vs Riverpod
- **UI Framework**: React Native components vs Flutter widgets
- **Navigation**: React Navigation vs go_router
- **Language**: TypeScript vs Dart
- **Bundle Size**: Typically smaller than Flutter
- **Hot Reload**: Faster than Flutter

## License

MIT

## Support

For issues related to:
- **React Native app**: Check this README and troubleshooting section
- **Backend API**: See `../backend/README.md`
- **Flutter comparison**: See `../nomad_notes/README.md`
