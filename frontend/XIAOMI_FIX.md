# Fixing Installation Issues on Xiaomi/Mi Phones

If you're getting `INSTALL_FAILED_USER_RESTRICTED` error on your Xiaomi/Mi phone, follow these steps:

## Quick Fix Steps

### Step 1: Enable "Install via USB"

1. Go to **Settings** → **Additional settings** → **Developer options**
2. Scroll down and find **"Install via USB"** (may also be called "USB installation" or "Install via USB (Security)")
3. **Toggle it ON**
4. You may be asked to enter your **Mi account password** - enter it

### Step 2: Disable MIUI Optimization (If Step 1 doesn't work)

1. In **Developer options**, find **"MIUI Optimization"**
2. Toggle it **OFF**
3. Your phone will **restart automatically**
4. After restart, go back to Developer options
5. Enable **"Install via USB"** again

### Step 3: Allow Unknown Sources

1. Go to **Settings** → **Apps** → **Manage apps** → **Permissions**
2. Or **Settings** → **Additional settings** → **Privacy**
3. Enable **"Install apps via USB"** or **"Unknown sources"**

### Step 4: Check Security Settings

1. Go to **Settings** → **Security**
2. Find **"Device admin apps"** or **"Security"**
3. Make sure nothing is blocking installations

### Step 5: Try Installing Again

```bash
cd frontend
flutter clean
flutter run
```

## Alternative: Install APK Manually

If the above doesn't work, you can install the APK manually:

1. **Build the APK:**
   ```bash
   cd frontend
   flutter build apk
   ```

2. **Transfer APK to phone:**
   - The APK will be in: `build/app/outputs/flutter-apk/app-release.apk`
   - Copy it to your phone via USB or email

3. **Install on phone:**
   - Open **File Manager** on your phone
   - Find the APK file
   - Tap it to install
   - Allow installation from unknown sources when prompted

## MIUI-Specific Settings

Xiaomi phones have MIUI (Mi User Interface) which has extra security:

- **MIUI Version**: Settings → About phone → MIUI version
- **Security App**: Open the Security app → Settings → Enable "Install apps via USB"
- **Developer Options**: Make sure all USB-related options are enabled

## Still Not Working?

1. **Check MIUI version:**
   - Older MIUI versions may have different menu locations
   - Try searching in Settings for "USB installation" or "Install via USB"

2. **Try different USB connection mode:**
   - When connected, pull down notification panel
   - Change USB mode to "File Transfer" or "MTP"

3. **Restart both devices:**
   - Restart your phone
   - Restart your computer
   - Try again

4. **Check if phone is locked:**
   - Unlock your phone screen
   - Keep it unlocked during installation

5. **Use wireless debugging (Android 11+):**
   - Developer options → Wireless debugging
   - Pair and connect wirelessly
   - This sometimes bypasses USB restrictions

## Common Xiaomi Settings Locations

- **Developer Options**: Settings → Additional settings → Developer options
- **Install via USB**: Developer options → Install via USB
- **USB Debugging**: Developer options → USB debugging
- **Security**: Settings → Security → (various options)

## Test Connection

After enabling settings, verify connection:

```bash
flutter devices
```

You should see your Mi 9T listed. Then try:

```bash
flutter run
```

The installation should proceed without the user restriction error.

