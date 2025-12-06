# Quick Start - View Frontend Without Firebase

The frontend is set up to work **without Firebase** using mock data! You can see and test the entire UI immediately.

## Run the App (No Firebase Required!)

1. **Install dependencies:**
   ```bash
   cd frontend
   flutter pub get
   ```

2. **Run the app:**
   ```bash
   flutter run -d chrome
   ```

That's it! The app will use mock data by default.

## Test Accounts (Mock Data)

### Patient Account
- **Email:** `patient@test.com`
- **Password:** (any password works)
- **Role:** Patient

### Therapist Account
- **Email:** `therapist@test.com`
- **Password:** (any password works)
- **Role:** Therapist

### Or Create New Account
- Click "Sign Up" on the login screen
- Enter any email, password, name, and select role
- The account will be created in mock storage

## What You Can Test

### As Patient:
1. Sign in with `patient@test.com` (any password)
2. See 2 sample exercises available
3. Click on an exercise to complete it
4. Answer the multiple-choice question
5. See immediate feedback and score
6. Score is saved (in mock storage)

### As Therapist:
1. Sign in with `therapist@test.com` (any password)
2. See dashboard with patient list
3. View patient progress statistics
4. Click on a patient to see detailed progress
5. See exercise history and scores

## Sample Data Included

The mock service includes:
- 2 pre-configured exercises
- 1 patient account with sample scores
- 1 therapist account
- Sample exercise completion history

## Switch to Firebase (When Ready)

When your backend developer sets up Firebase:

1. Follow `FIREBASE_SETUP.md` to configure Firebase
2. Open `lib/services/app_service.dart`
3. Change this line:
   ```dart
   static const bool useFirebase = false; // Change to true
   ```
4. Update `main.dart` to initialize Firebase (see comments in file)

## Mock vs Firebase

- **Mock Service** (current): Works immediately, no setup needed, data resets on app restart
- **Firebase Service**: Requires setup, data persists, real-time updates across devices

The app automatically uses the correct service based on the `useFirebase` flag in `app_service.dart`.

## Troubleshooting

**App won't run?**
- Make sure Flutter is installed: `flutter doctor`
- Install dependencies: `flutter pub get`

**Can't see exercises?**
- Mock data includes 2 exercises by default
- They should appear automatically

**Want to test with different data?**
- Edit `lib/services/mock_service.dart`
- Modify `_mockExercises` or `_mockUsers` arrays

Enjoy testing the frontend! 🎉

