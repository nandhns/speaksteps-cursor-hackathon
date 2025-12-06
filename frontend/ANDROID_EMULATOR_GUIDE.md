# Android Studio Emulator Setup Guide

This guide will help you set up and use an Android virtual emulator to run your SpeakSteps Flutter app.

## Prerequisites

1. **Android Studio** - Download from [developer.android.com/studio](https://developer.android.com/studio)
2. **Flutter SDK** - Already installed (verify with `flutter doctor`)
3. **Android SDK** - Installed via Android Studio

## Step 1: Install Android Studio Components

1. Open **Android Studio**
2. Go to **Tools** → **SDK Manager** (or click the SDK Manager icon)
3. In the **SDK Platforms** tab, check:
   - ✅ **Android 13.0 (Tiramisu)** or newer (API 33+)
   - ✅ **Android 12.0 (S)** (API 31) - recommended
4. In the **SDK Tools** tab, ensure these are checked:
   - ✅ **Android SDK Build-Tools**
   - ✅ **Android SDK Command-line Tools**
   - ✅ **Android SDK Platform-Tools**
   - ✅ **Android Emulator**
   - ✅ **Intel x86 Emulator Accelerator (HAXM installer)** (for Intel CPUs)
   - ✅ **Google Play services**
5. Click **Apply** and wait for installation

## Step 2: Create a Virtual Device (AVD)

1. In Android Studio, go to **Tools** → **Device Manager** (or click the Device Manager icon)
2. Click **Create Device** (or the **+** button)
3. Choose a device definition:
   - Recommended: **Pixel 5** or **Pixel 6**
   - Or any device with at least 4GB RAM
4. Click **Next**
5. Select a system image:
   - Recommended: **API 33 (Android 13)** or **API 31 (Android 12)**
   - Make sure it has the **Download** link if not installed
   - Choose **x86_64** architecture (faster on Intel/AMD)
   - For Apple Silicon (M1/M2): Choose **arm64-v8a**
6. Click **Next**
7. Configure AVD:
   - **AVD Name**: Give it a name (e.g., "Pixel_5_API_33")
   - **Startup orientation**: Portrait (default)
   - **Graphics**: Automatic (or Hardware - GLES 2.0 for better performance)
   - **Camera**: None (unless you need it)
   - **Memory and Storage**:
     - RAM: 4096 MB (4GB) minimum
     - VM heap: 512 MB
     - Internal Storage: 2048 MB (2GB) minimum
8. Click **Finish**

## Step 3: Start the Emulator

### Option A: From Android Studio
1. Open **Device Manager** (Tools → Device Manager)
2. Find your created device
3. Click the **Play** button (▶️) next to the device
4. Wait for the emulator to boot (first time may take 2-3 minutes)

### Option B: From Command Line
```bash
# List available emulators
emulator -list-avds

# Start a specific emulator (replace with your AVD name)
emulator -avd Pixel_5_API_33
```

## Step 4: Verify Flutter Can See the Emulator

1. Open a terminal/command prompt
2. Run:
   ```bash
   flutter devices
   ```
3. You should see your emulator listed, for example:
   ```
   sdk gphone64 arm64 (mobile) • emulator-5554 • android-arm64  • Android 13 (API 33) (emulator)
   ```

## Step 5: Run Your Flutter App

### Option A: From Command Line (Recommended)

1. Navigate to the frontend directory:
   ```bash
   cd frontend
   ```

2. Install dependencies (if not done already):
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```
   Flutter will automatically detect and use the running emulator.

   Or specify the device explicitly:
   ```bash
   flutter run -d emulator-5554
   ```

### Option B: From Android Studio

1. Open the `frontend` folder in Android Studio
2. Wait for Flutter to sync (you'll see "Flutter SDK" in the status bar)
3. Make sure your emulator is running
4. Click the **Run** button (▶️) or press **Shift + F10**
5. Select your emulator from the device dropdown if prompted

### Option C: From VS Code / Cursor

1. Make sure your emulator is running
2. Press **F5** or click the **Run** button
3. Select your emulator from the device list

## Troubleshooting

### Emulator Won't Start

**Issue**: "HAXM is not installed" or "Intel HAXM installation failed"
- **Solution**: 
  - For Intel CPUs: Install HAXM manually from [Intel's website](https://github.com/intel/haxm/releases)
  - For AMD CPUs: Enable **Windows Hypervisor Platform** in Windows Features
  - For Apple Silicon: No HAXM needed, use arm64 images

**Issue**: "Emulator process was killed"
- **Solution**: 
  - Increase RAM allocation in AVD settings
  - Close other applications to free up memory
  - Try a device with lower specs

### Flutter Can't See Emulator

**Issue**: `flutter devices` shows nothing
- **Solution**:
  ```bash
  # Check if emulator is running
  adb devices
  
  # If emulator is running but not listed, restart adb
  adb kill-server
  adb start-server
  flutter devices
  ```

### App Crashes on Launch

**Issue**: App installs but crashes immediately
- **Solution**:
  ```bash
  # Check logs
  flutter logs
  
  # Or use Android Studio Logcat
  # View → Tool Windows → Logcat
  ```

### Slow Performance

**Solutions**:
1. **Enable Hardware Acceleration**:
   - In AVD settings, set Graphics to **Hardware - GLES 2.0**
   - Enable **Use Host GPU**

2. **Allocate More Resources**:
   - Increase RAM to 6-8GB if available
   - Increase VM heap to 1024 MB

3. **Use x86_64 Images**:
   - x86_64 is faster than arm64 on Intel/AMD CPUs
   - Only use arm64 if you have Apple Silicon (M1/M2)

4. **Close Unnecessary Apps**:
   - Close other applications to free up system resources

### Cold Boot Takes Too Long

**Solution**: Use **Quick Boot** (Snapshots)
- When creating/editing AVD, enable **Enable Quick Boot**
- This saves the emulator state for faster startup

## Recommended Emulator Settings

For best performance, use these settings:

- **Device**: Pixel 5 or Pixel 6
- **API Level**: 31 (Android 12) or 33 (Android 13)
- **Architecture**: x86_64 (Intel/AMD) or arm64-v8a (Apple Silicon)
- **RAM**: 4096 MB (4GB) minimum, 6144 MB (6GB) recommended
- **VM Heap**: 512 MB minimum, 1024 MB recommended
- **Graphics**: Hardware - GLES 2.0
- **Quick Boot**: Enabled

## Quick Commands Reference

```bash
# List all devices (physical + emulators)
flutter devices

# List only emulators
emulator -list-avds

# Start emulator
emulator -avd <AVD_NAME>

# Run app on specific device
flutter run -d <device_id>

# Hot reload (press 'r' in terminal while app is running)
# Hot restart (press 'R' in terminal)
# Quit (press 'q' in terminal)

# Check Flutter setup
flutter doctor

# Clean build
flutter clean
flutter pub get
```

## Next Steps

Once your app is running on the emulator:

1. **Test the login**:
   - Email: `patient@test.com` (any password)
   - Email: `therapist@test.com` (any password)

2. **Try the features**:
   - Patient exercises
   - Therapist dashboard
   - Progress tracking

3. **Hot Reload**: Make code changes and see them instantly (press `r` in terminal)

Enjoy testing your SpeakSteps app! 🎉

