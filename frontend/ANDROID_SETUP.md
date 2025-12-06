# Android Setup Guide

This Flutter app has been configured for Android and is ready to run on Android devices.

## Quick Start

### Prerequisites
- Flutter SDK installed (3.9.2 or higher)
- Android Studio or Android SDK installed
- An Android device or emulator

### Running on Android

1. **Connect an Android device** or start an Android emulator

2. **Check connected devices:**
   ```bash
   cd frontend
   flutter devices
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```
   Or specify Android explicitly:
   ```bash
   flutter run -d android
   ```

4. **Build APK for testing:**
   ```bash
   flutter build apk
   ```
   The APK will be in `build/app/outputs/flutter-apk/app-release.apk`

5. **Build App Bundle for Play Store:**
   ```bash
   flutter build appbundle
   ```

## Mobile-Responsive Features

The app has been optimized for mobile devices with the following responsive features:

### Therapist Dashboard
- **Mobile (< 600px width):**
  - View switcher buttons moved to bottom navigation bar
  - Patient list in "By Patient" view uses a drawer instead of sidebar
  - Report containers stack vertically instead of in rows

### Patient View
- **Mobile (< 600px width):**
  - Category selection displays in a 2x2 grid instead of single row
  - Exercise type cards stack vertically if needed
  - All screens are scrollable

### Exercise Screens
- Writing and comprehension exercises are fully responsive
- Answer buttons adapt to screen size
- Touch-friendly UI elements

## Android Configuration

### App Name
- Display name: **SpeakSteps**
- Package name: `com.example.frontend` (update this for production)

### Minimum Requirements
- Minimum SDK: Defined by Flutter (typically API 21+)
- Target SDK: Latest Android version
- Supports both phones and tablets

### Permissions
Currently, the app doesn't require special permissions. If you need to add permissions (e.g., for camera, microphone, storage), add them to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```

## Firebase Setup for Android

If you're using Firebase, you need to:

1. **Add Android app to Firebase Console:**
   - Go to Firebase Console
   - Add an Android app
   - Package name: `com.example.frontend`
   - Download `google-services.json`

2. **Place the file:**
   - Copy `google-services.json` to `android/app/`

3. **Update build.gradle:**
   - Add to `android/app/build.gradle.kts`:
   ```kotlin
   plugins {
       // ... existing plugins
       id("com.google.gms.google-services")
   }
   ```
   - Add to `android/build.gradle.kts`:
   ```kotlin
   dependencies {
       classpath("com.google.gms:google-services:4.4.0")
   }
   ```

4. **Run FlutterFire CLI:**
   ```bash
   cd frontend
   flutterfire configure
   ```

## Testing

### Run on Emulator
1. Start Android Studio
2. Open AVD Manager
3. Create/start an emulator
4. Run `flutter run`

### Run on Physical Device
1. Enable Developer Options on your Android device
2. Enable USB Debugging
3. Connect via USB
4. Run `flutter run`

**📱 Detailed instructions:** See [CONNECT_ANDROID_PHONE.md](CONNECT_ANDROID_PHONE.md) for step-by-step guide to connect your physical phone.

## Troubleshooting

### "No devices found"
- Make sure an emulator is running or a device is connected
- Run `flutter doctor` to check Android setup

### Build errors
- Run `flutter clean`
- Run `flutter pub get`
- Check that Android SDK is properly installed

### App crashes on launch
- Check logs: `flutter logs`
- Verify Firebase configuration if using Firebase
- Check that all dependencies are compatible

## Production Build

Before releasing to Play Store:

1. **Update package name** in:
   - `android/app/build.gradle.kts` (applicationId)
   - `android/app/src/main/AndroidManifest.xml` (if needed)

2. **Configure signing:**
   - Create a keystore
   - Update `android/app/build.gradle.kts` with signing config

3. **Update app metadata:**
   - App name in `AndroidManifest.xml`
   - Version in `pubspec.yaml`

4. **Build release:**
   ```bash
   flutter build appbundle --release
   ```

## Responsive Breakpoints

The app uses a 600px breakpoint to switch between mobile and desktop layouts:
- **< 600px**: Mobile layout (drawer, stacked containers)
- **≥ 600px**: Desktop layout (sidebar, row layouts)

This ensures optimal experience on phones, tablets, and web browsers.

