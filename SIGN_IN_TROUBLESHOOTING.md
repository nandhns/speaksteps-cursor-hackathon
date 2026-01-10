# Sign-In Troubleshooting Guide

## Current Status
✅ **Database**: 17 exercises seeded successfully  
✅ **User Document**: john.patient@speaksteps.com exists in Firestore  
✅ **Firebase Config**: Project IDs match across all files  
✅ **No questionText**: Field removed from all exercises  
✅ **Logging Added**: Detailed debug logs added to track sign-in process  

## Steps to Fix Sign-In Issue

### Step 1: Rebuild the App
The app needs to be rebuilt to include the new logging and fixes:

```bash
cd frontend
flutter clean
flutter pub get
flutter run
```

**Important**: Make sure to run on your **physical device**, not the emulator.

### Step 2: Watch the Console Output
When you run the app and try to sign in, watch for these log messages in your console:

```
🔐 Starting sign-in process for: john.patient@speaksteps.com
✅ Firebase Auth successful: john.patient@speaksteps.com
📥 Fetching user from Firestore: g8KEOA79AiR8Gq5BAIvkBbXHjJI2
✅ User document found for: g8KEOA79AiR8Gq5BAIvkBbXHjJI2
   User data keys: [role, id, name, createdAt, caregiverName, patientPhone, email, diagnosis, caregiverPhone]
✅ User data loaded successfully: John Smith
```

### Step 3: Check for Errors
If sign-in fails, you should see error messages with ❌. Look for:

**Error 1: Firebase Auth Failed**
```
❌ Firebase Auth error: ...
```
**Solution**: 
- Check if Email/Password authentication is enabled in Firebase Console
- Go to: Firebase Console > Authentication > Sign-in method > Email/Password > Enable

**Error 2: User Document Not Found**
```
❌ User document NOT found for: [UID]
```
**Solution**: The UID from Firebase Auth doesn't match Firestore. Re-seed the database.

**Error 3: Firestore Permission Denied**
```
❌ Error getting user from Firestore: [PERMISSION_DENIED]
```
**Solution**: Check your Firestore rules. They should allow read/write for authenticated users.

### Step 4: Verify Firebase Authentication
In Firebase Console:

1. Go to **Authentication > Users**
2. Check if `john.patient@speaksteps.com` exists
3. **Important**: Note the UID (should be: `g8KEOA79AiR8Gq5BAIvkBbXHjJI2`)
4. If the UID is different, you need to either:
   - Delete and recreate the Firebase Auth user with the correct UID (not recommended)
   - OR update the Firestore document ID to match the Firebase Auth UID

### Step 5: Test Sign-In Credentials
Make sure you're using the exact credentials:

- **Email**: `john.patient@speaksteps.com`
- **Password**: `Patient123!`

**Note**: The email is case-sensitive! Use `@speaksteps.com`, not `@email.com`.

### Step 6: Clear App Data (if needed)
If there's cached data causing issues:

**On Android:**
1. Go to Settings > Apps > SpeakSteps
2. Clear Storage & Clear Cache
3. Restart the app

**On iOS:**
1. Delete the app completely
2. Reinstall from Flutter

## Common Issues & Solutions

### Issue: "Firebase initialized successfully" but sign-in still fails
**Cause**: The app is connecting to Firebase, but there's a mismatch between Auth UID and Firestore document ID.

**Solution**: Run this to check:
```bash
cd backend
node check_firestore.js
```
Look for the document ID matching your Firebase Auth UID.

### Issue: Sign-in works on one device but not another
**Cause**: Different Firebase configuration for Android/iOS, or network issues.

**Solution**: 
1. Check `frontend/lib/firebase_options.dart` has configurations for both platforms
2. Ensure both devices have internet connection
3. Try signing in with a different network (mobile data vs WiFi)

### Issue: "Sign in failed" with no console errors
**Cause**: The app might be using Mock Service instead of Firebase Service.

**Solution**: Check `frontend/lib/services/app_service.dart`:
```dart
static const bool useFirebase = true; // Should be true!
```

## Need More Help?

### Get Detailed Logs
1. Run the app with: `flutter run --verbose`
2. Try to sign in
3. Copy ALL the console output (especially lines with 🔐, ✅, ❌)
4. Share the logs for detailed diagnosis

### Check Database State
```bash
cd backend
node check_firestore.js
```
This shows exactly what's in your Firestore database.

### Re-seed Database (if needed)
```bash
cd backend
node seed_firestore.js
```

## What We Fixed
1. ✅ Removed `questionText` field from all exercises
2. ✅ Re-seeded database with correct Bahasa Melayu exercises
3. ✅ Added detailed logging to track sign-in process
4. ✅ Verified Firebase configuration matches across all files
5. ✅ Confirmed user document exists in Firestore with correct UID

## Next Steps
1. **Rebuild the app**: `cd frontend && flutter clean && flutter pub get && flutter run`
2. **Try signing in** with `john.patient@speaksteps.com` / `Patient123!`
3. **Watch the console** for the detailed log messages
4. **Share any error messages** you see (lines with ❌)

The detailed logging will show us exactly where the sign-in process is failing!


