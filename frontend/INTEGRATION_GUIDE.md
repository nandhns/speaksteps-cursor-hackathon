# Firebase Integration Guide for Backend Developer

This guide explains how to connect the Flutter frontend with Firebase backend.

## Quick Start

1. **Set up Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project or use existing
   - Add a web app to get configuration

2. **Configure FlutterFire**
   ```bash
   cd frontend
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   This generates `lib/firebase_options.dart`

3. **Update main.dart**
   Uncomment the Firebase options import and initialization:
   ```dart
   import 'firebase_options.dart';
   
   await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
   );
   ```

4. **Enable Firebase Services**
   - Authentication → Enable Email/Password
   - Firestore Database → Create database (test mode for dev)

5. **Add Sample Data**
   Create exercises in Firestore collection `exercises`:
   ```json
   {
     "id": "exercise1",
     "title": "Word Recognition",
     "description": "Select the correct word for the image",
     "type": "word_recognition",
     "options": ["Apple", "Banana", "Orange", "Grape"],
     "correctAnswer": "Apple",
     "difficulty": 1
   }
   ```

## Database Schema

### Collection: `users`
```json
{
  "id": "user123",
  "email": "patient@example.com",
  "name": "John Doe",
  "role": "patient",  // or "therapist"
  "createdAt": "2024-01-01T00:00:00Z"
}
```

### Collection: `exercises`
```json
{
  "id": "exercise1",
  "title": "Word Recognition",
  "description": "Select the correct word",
  "type": "word_recognition",
  "options": ["Option A", "Option B", "Option C", "Option D"],
  "correctAnswer": "Option A",
  "difficulty": 1
}
```

### Collection: `exercise_scores`
```json
{
  "id": "score123",
  "patientId": "user123",
  "exerciseId": "exercise1",
  "exerciseTitle": "Word Recognition",
  "score": 100,
  "maxScore": 100,
  "answer": "Option A",
  "correctAnswer": "Option A",
  "completedAt": "2024-01-01T00:00:00Z",
  "metadata": {
    "timeTaken": 30,
    "difficulty": 1
  }
}
```

## How Frontend Calls Backend

### When Patient Completes Exercise

1. Patient selects answer in `ExerciseScreen`
2. Score is calculated (100 if correct, 0 if wrong)
3. `FirebaseService.saveExerciseScore()` is called
4. Score saved to Firestore `exercise_scores` collection

### When Therapist Views Dashboard

1. `FirebaseService.getTherapistPatients()` fetches all patients
2. For each patient, `getPatientProgress()` aggregates scores
3. Data displayed in `TherapistDashboardScreen`
4. Real-time updates via Firestore streams

## Service Methods Available

All methods in `lib/services/firebase_service.dart`:

**Authentication:**
- `signInWithEmail(email, password)`
- `signUpWithEmail(email, password, name, role)`
- `signOut()`

**Users:**
- `saveUser(userModel)`
- `getUser(userId)`

**Exercises:**
- `getExercises()` → Returns all exercises
- `getExercise(exerciseId)` → Returns single exercise

**Scores:**
- `saveExerciseScore(score)` → Saves patient result
- `getPatientScores(patientId)` → Gets all scores for patient
- `getPatientScoresStream(patientId)` → Real-time stream

**Progress:**
- `getTherapistPatients(therapistId)` → Gets all patients
- `getPatientProgress(patientId)` → Aggregated progress
- `getPatientProgressStream(patientId)` → Real-time stream

## Security Rules (Development)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /exercises/{exerciseId} {
      allow read: if request.auth != null;
      allow write: if false; // Only admins
    }
    
    match /exercise_scores/{scoreId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && 
                       request.resource.data.patientId == request.auth.uid;
      allow update, delete: if false;
    }
  }
}
```

## Testing the Integration

1. **Test Authentication:**
   - Sign up as patient
   - Check Firestore `users` collection
   - Sign up as therapist
   - Verify both users created

2. **Test Exercise Flow:**
   - Add exercise to Firestore
   - Patient logs in, sees exercise
   - Patient completes exercise
   - Check `exercise_scores` collection

3. **Test Therapist View:**
   - Therapist logs in
   - Should see patient in dashboard
   - Click patient, see exercise scores

## Common Issues

**"Firebase not initialized"**
- Run `flutterfire configure`
- Check `firebase_options.dart` exists

**"Permission denied"**
- Check Firestore security rules
- Verify user is authenticated

**"Collection not found"**
- Create collections manually in Firebase Console
- Or let app create them (if rules allow)

## Next Steps

1. ✅ Frontend ready
2. ⏳ Set up Firebase project
3. ⏳ Configure FlutterFire
4. ⏳ Add sample exercises
5. ⏳ Test end-to-end

See `FIREBASE_SETUP.md` for detailed setup instructions.

