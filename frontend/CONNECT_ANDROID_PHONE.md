# How to Connect Your Android Phone

Follow these steps to connect your physical Android phone and run the Flutter app.

## Step 1: Enable Developer Options

1. **Open Settings** on your Android phone
2. Scroll down and tap **About phone** (or **About device**)
3. Find **Build number** (or **Software information** → **Build number**)
4. **Tap Build number 7 times** until you see "You are now a developer!"
5. You'll see a message confirming Developer Options are enabled

## Step 2: Enable USB Debugging

1. Go back to **Settings**
2. Find and tap **Developer options** (usually under System or Advanced)
3. Toggle **Developer options** ON (if not already on)
4. Scroll down and toggle **USB debugging** ON
5. If prompted, tap **OK** to confirm

## Step 3: Connect Your Phone

1. **Connect your phone to your computer** using a USB cable
2. On your phone, you may see a popup asking "Allow USB debugging?"
3. Check **"Always allow from this computer"** (optional but recommended)
4. Tap **Allow** or **OK**

## Step 4: Verify Connection

Open a terminal/command prompt and run:

```bash
cd frontend
flutter devices
```

You should see your phone listed, for example:
```
2 connected devices:

sdk gphone64 arm64 (mobile) • emulator-5554 • android-arm64  • Android 13 (API 33)
SM A12345 (mobile)          • ABC123XYZ     • android-arm64  • Android 12 (API 31)
```

The device with your phone's model name is your physical phone.

## Step 5: Run the App

```bash
flutter run
```

Or if you have multiple devices, specify your phone:

```bash
flutter run -d <device-id>
```

Replace `<device-id>` with the ID shown in `flutter devices` (e.g., `ABC123XYZ`)

## Troubleshooting

### INSTALL_FAILED_USER_RESTRICTED Error (Xiaomi/Mi Phones)

If you see `INSTALL_FAILED_USER_RESTRICTED: Install canceled by user` on Xiaomi/Mi phones:

1. **Enable "Install via USB" in Developer Options:**
   - Go to **Settings** → **Developer options**
   - Find **"Install via USB"** (or **"USB installation"**)
   - Toggle it **ON**
   - You may need to enter your Mi account password

2. **Disable MIUI Optimization (if needed):**
   - In **Developer options**, find **"MIUI Optimization"**
   - Toggle it **OFF**
   - Your phone will restart

3. **Allow installation from unknown sources:**
   - Go to **Settings** → **Apps** → **Manage apps** → **Permissions**
   - Or **Settings** → **Additional settings** → **Privacy**
   - Enable **"Install apps via USB"** or **"Unknown sources"**

4. **Try again:**
   ```bash
   flutter run
   ```

**Note:** Xiaomi phones have additional security layers. Make sure all installation permissions are enabled.

### Phone Not Detected

1. **Check USB cable**: Try a different cable (data cable, not just charging cable)
2. **Check USB mode**: On your phone, when connected, pull down notification panel and ensure it's set to "File Transfer" or "MTP" mode (not "Charging only")
3. **Install USB drivers**: 
   - Windows: Install your phone manufacturer's USB drivers (Samsung, Google, etc.)
   - Mac/Linux: Usually works automatically
4. **Restart ADB**:
   ```bash
   flutter doctor
   adb kill-server
   adb start-server
   flutter devices
   ```

### "Unauthorized" Error

1. On your phone, check for the USB debugging authorization popup
2. Tap **Allow** or **OK**
3. Check **"Always allow from this computer"** if you want to avoid this in the future

### "Device Offline" Error

1. Disconnect and reconnect your phone
2. Revoke USB debugging authorizations:
   - Go to Developer Options → Revoke USB debugging authorizations
3. Reconnect and authorize again

### Windows: "adb: no devices/emulators found"

1. Install your phone's USB drivers:
   - **Samsung**: Install Samsung USB Driver
   - **Google Pixel**: Install Google USB Driver
   - **Other brands**: Check manufacturer's website
2. Try different USB ports (USB 2.0 ports often work better)
3. Restart your computer

### Mac: Permission Issues

If you see permission errors:
1. System Preferences → Security & Privacy
2. Allow the terminal/command line tool if prompted

## Alternative: Wireless Debugging (Android 11+)

If USB connection is problematic, you can use wireless debugging:

1. **On your phone:**
   - Developer Options → **Wireless debugging** → ON
   - Tap **Pair device with pairing code**
   - Note the IP address and port (e.g., `192.168.1.100:12345`)
   - Note the pairing code

2. **On your computer:**
   ```bash
   adb pair <ip-address>:<port>
   ```
   Enter the pairing code when prompted

3. **Connect wirelessly:**
   ```bash
   adb connect <ip-address>:<port>
   ```

4. **Verify:**
   ```bash
   flutter devices
   ```

## Quick Test

Once connected, try running:

```bash
cd frontend
flutter run -d android
```

The app should install and launch on your phone!

## Tips

- **Keep USB debugging enabled** - You can leave it on for development
- **Use a good USB cable** - Some cables only charge, not transfer data
- **Check battery** - Some phones disable USB debugging when battery is low
- **Same WiFi network** - For wireless debugging, phone and computer must be on same network

## Still Having Issues?

Run Flutter doctor to check your setup:

```bash
flutter doctor -v
```

This will show detailed information about your Flutter, Android SDK, and device connection status.

