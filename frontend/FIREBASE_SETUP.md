# Firebase Setup Guide for Backend Developer

This document explains how to set up Firebase for the Flutter web frontend.

## Overview

The frontend uses Firebase for:
- **Authentication** (Firebase Auth)
- **Database** (Cloud Firestore - recommended for web, or Realtime Database)

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or select an existing project
3. Follow the setup wizard

## Step 2: Add Web App to Firebase Project

1. In Firebase Console, click the web icon (`</>`)
2. Register your app with a nickname (e.g., "SpeakSteps Web")
3. Copy the Firebase configuration object (you'll need this)

## Step 3: Install FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

## Step 4: Configure FlutterFire

Navigate to the `frontend` directory and run:

```bash
cd frontend
flutterfire configure
```

This will:
- Detect your Firebase projects
- Let you select the project
- Generate `lib/firebase_options.dart` automatically
- Configure Firebase for all platforms (web, Android, iOS)

## Step 5: Update main.dart

After running `flutterfire configure`, update `main.dart`:

```dart
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}
```

## Step 6: Enable Firebase Services

### Enable Authentication

1. Go to Firebase Console → Authentication
2. Click "Get started"
3. Enable "Email/Password" sign-in method
4. Save

### Enable Firestore Database

1. Go to Firebase Console → Firestore Database
2. Click "Create database"
3. Choose "Start in test mode" (for development)
4. Select a location
5. Click "Enable"

### OR Enable Realtime Database

If you prefer Realtime Database:
1. Go to Firebase Console → Realtime Database
2. Click "Create database"
3. Choose a location
4. Set rules (start with test mode for development)

## Step 7: Set Up Database Structure

The frontend expects the following Firestore collections:

### Collection: `users`
Document structure:
```json
{
  "id": "user123",
  "email": "patient@example.com",
  "name": "John Doe",
  "role": "patient", // or "therapist"
  "createdAt": "2024-01-01T00:00:00Z"
}
```

### Collection: `exercises`
Document structure:
```json
{
  "id": "exercise1",
  "title": "Word Recognition",
  "description": "Select the correct word",
  "type": "word_recognition",
  "options": ["Apple", "Banana", "Orange", "Grape"],
  "correctAnswer": "Apple",
  "difficulty": 1
}
```

### Collection: `exercise_scores`
Document structure:
```json
{
  "id": "score123",
  "patientId": "user123",
  "exerciseId": "exercise1",
  "exerciseTitle": "Word Recognition",
  "score": 100,
  "maxScore": 100,
  "answer": "Apple",
  "correctAnswer": "Apple",
  "completedAt": "2024-01-01T00:00:00Z",
  "metadata": {
    "timeTaken": 30,
    "difficulty": 1
  }
}
```

## Step 8: Set Up Security Rules

### Firestore Rules (for development)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read their own data
    match /users/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Anyone authenticated can read exercises
    match /exercises/{exerciseId} {
      allow read: if request.auth != null;
      allow write: if false; // Only admins can write (set up admin later)
    }
    
    // Patients can write their own scores, therapists can read all
    match /exercise_scores/{scoreId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && 
                       request.resource.data.patientId == request.auth.uid;
      allow update, delete: if false; // Scores are immutable
    }
  }
}
```

### Realtime Database Rules (if using Realtime Database)

```json
{
  "rules": {
    "users": {
      "$userId": {
        ".read": "$userId === auth.uid",
        ".write": "$userId === auth.uid"
      }
    },
    "exercises": {
      ".read": "auth != null",
      ".write": false
    },
    "exercise_scores": {
      ".read": "auth != null",
      ".write": "auth != null && newData.child('patientId').val() === auth.uid"
    }
  }
}
```

## Step 9: Add Sample Data (Optional)

You can add sample exercises manually in Firebase Console or use a script:

1. Go to Firestore Database
2. Click "Start collection"
3. Collection ID: `exercises`
4. Add documents with the structure above

## Step 10: Test the Connection

1. Run the Flutter app: `flutter run -d chrome`
2. Try signing up as a patient
3. Check Firebase Console to see if data is being created

## Troubleshooting

### Error: "Firebase not initialized"
- Make sure you ran `flutterfire configure`
- Check that `firebase_options.dart` exists
- Verify `main.dart` imports and initializes Firebase correctly

### Error: "Permission denied"
- Check your Firestore/Realtime Database rules
- Make sure authentication is enabled
- Verify the user is authenticated

### Error: "Collection not found"
- Create the collections manually in Firebase Console
- Or let the app create them on first write (if rules allow)

## Integration Points

The frontend service layer (`lib/services/firebase_service.dart`) provides these methods that your backend can use:

- `signInWithEmail()` - User authentication
- `signUpWithEmail()` - User registration
- `saveUser()` - Save user profile
- `getExercises()` - Fetch available exercises
- `saveExerciseScore()` - Save patient exercise results
- `getPatientScores()` - Get patient's exercise history
- `getPatientProgress()` - Get aggregated progress data

All methods are already implemented and ready to use with Firestore. If you need to use Realtime Database instead, modify the service methods accordingly.

## Next Steps

1. Set up Firebase project and configure FlutterFire
2. Enable Authentication and Firestore
3. Add sample exercises to the database
4. Test the app with real Firebase connection
5. Adjust security rules for production

