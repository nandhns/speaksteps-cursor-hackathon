# How to Change the SpeakSteps Logo

This guide explains where and how to change the SpeakSteps logo throughout the app.

## Current Logo Locations

### 1. **Login Screen Logo/Icon**
   - **File:** `frontend/lib/screens/login_screen.dart`
   - **Line 99-103:** Currently uses `Icons.health_and_safety` icon
   - **Line 106:** Text "SpeakSteps" appears below the icon

### 2. **App Icons (Platform-Specific)**
   - **Android:** `frontend/android/app/src/main/res/mipmap-*/ic_launcher.png`
     - Multiple sizes: hdpi, mdpi, xhdpi, xxhdpi, xxxhdpi
   - **iOS:** `frontend/ios/Runner/Assets.xcassets/AppIcon.appiconset/`
   - **Web:** `frontend/web/icons/` and `frontend/web/favicon.png`
   - **Windows:** `frontend/windows/runner/resources/app_icon.ico`

### 3. **App Title/Name**
   - **File:** `frontend/lib/main.dart`
   - **Line 51:** App title "SpeakSteps - Aphasia Therapy"

## How to Change the Logo

### Option 1: Replace the Icon with a Custom Image Logo

1. **Add your logo image:**
   - Place your logo file (e.g., `logo.png`) in `frontend/images/` directory
   - Update `frontend/pubspec.yaml` to include the image (if not already included):
     ```yaml
     flutter:
       assets:
         - images/
         - images/logo.png  # Add this line
     ```

2. **Update the login screen:**
   - Edit `frontend/lib/screens/login_screen.dart`
   - Replace the Icon widget (lines 99-103) with an Image widget:
     ```dart
     Image.asset(
       'images/logo.png',
       height: 80,
       width: 80,
     ),
     ```

### Option 2: Change the App Icons

#### For Android:
1. Replace the icon files in `frontend/android/app/src/main/res/mipmap-*/ic_launcher.png`
2. Recommended sizes:
   - mipmap-mdpi: 48x48 px
   - mipmap-hdpi: 72x72 px
   - mipmap-xhdpi: 96x96 px
   - mipmap-xxhdpi: 144x144 px
   - mipmap-xxxhdpi: 192x192 px

#### For iOS:
1. Replace icons in `frontend/ios/Runner/Assets.xcassets/AppIcon.appiconset/`
2. Use Xcode or an online tool to generate all required sizes

#### For Web:
1. Replace `frontend/web/favicon.png` (32x32 or 16x16 px)
2. Replace icons in `frontend/web/icons/` directory

### Option 3: Change the Text Logo

If you want to change the "SpeakSteps" text:

1. **Login Screen:**
   - Edit `frontend/lib/screens/login_screen.dart`
   - Line 106: Change `'SpeakSteps'` to your desired text

2. **App Title:**
   - Edit `frontend/lib/main.dart`
   - Line 51: Change `'SpeakSteps - Aphasia Therapy'` to your desired title

3. **Other Locations:**
   - `frontend/lib/screens/patient/patient_home_screen.dart` (line 62)
   - `frontend/lib/screens/therapist/report_utils.dart` (line 561)

## Quick Steps to Add a Custom Logo Image

1. **Add your logo file:**
   ```bash
   # Place your logo.png in the images directory
   # frontend/images/logo.png
   ```

2. **Update login_screen.dart:**
   ```dart
   // Replace lines 99-103 with:
   Image.asset(
     'images/logo.png',
     height: 80,
     width: 80,
     fit: BoxFit.contain,
   ),
   ```

3. **Run the app:**
   ```bash
   flutter pub get
   flutter run
   ```

## Notes

- Logo images should be in PNG format with transparent background for best results
- Recommended logo size for login screen: 200x200 to 400x400 pixels
- For app icons, use square images (1:1 aspect ratio)
- After changing app icons, you may need to uninstall and reinstall the app to see changes

