# SpeakSteps - Flutter Application

A Flutter application (Web & Android) for aphasia patients and therapists. Patients can complete exercises, and therapists can monitor their progress in real-time.

## Platforms Supported
- ✅ **Web** - Full-featured web application
- ✅ **Android** - Native Android app with responsive mobile UI

## Features

### Patient View
- **Exercise Interface**: Complete 1-2 exercises with multiple-choice questions
- **Score Tracking**: Immediate feedback on exercise completion
- **Progress Visualization**: See completed exercises

### Therapist View
- **Dashboard**: View all assigned patients
- **Progress Monitoring**: See patient exercise scores and statistics
- **Patient Details**: Detailed view of individual patient progress
- **Real-time Updates**: Live updates when patients complete exercises

## Project Structure

```
lib/
├── main.dart                 # App entry point, Firebase initialization
├── models/                   # Data models
│   ├── user_model.dart
│   ├── exercise_model.dart
│   ├── exercise_score_model.dart
│   └── patient_progress_model.dart
├── services/                 # Firebase service layer
│   └── firebase_service.dart
├── providers/                # State management
│   └── auth_provider.dart
├── router/                   # Navigation
│   └── app_router.dart
└── screens/                  # UI screens
    ├── login_screen.dart
    ├── patient/
    │   ├── patient_home_screen.dart
    │   └── exercise_screen.dart
    └── therapist/
        ├── therapist_dashboard_screen.dart
        └── patient_detail_screen.dart
```

## Getting Started

### Quick Start (No Firebase Required!)

The app works **immediately with mock data** - no Firebase setup needed!

1. **Install dependencies:**
   ```bash
   cd frontend
   flutter pub get
   ```

2. **Run the app:**
   
   **For Web:**
   ```bash
   flutter run -d chrome
   ```
   
   **For Android:**
   ```bash
   flutter run -d android
   ```
   See [ANDROID_SETUP.md](ANDROID_SETUP.md) for detailed Android setup instructions.

3. **Test with mock accounts:**
   - Patient: `patient@test.com` (any password)
   - Therapist: `therapist@test.com` (any password)

See `QUICK_START.md` for details!

### Using Firebase (Optional)

When ready to connect to real Firebase:

1. **Set up Firebase:**
   - Follow the instructions in `FIREBASE_SETUP.md`
   - Run `flutterfire configure` to generate Firebase configuration

2. **Switch to Firebase:**
   - Open `lib/services/app_service.dart`
   - Change `useFirebase = false` to `useFirebase = true`
   - Update `main.dart` to initialize Firebase

3. **Run the app:**
   ```bash
   flutter run -d chrome
   ```

## Firebase Integration

The app uses Firebase for:
- **Authentication**: Email/password sign-in
- **Database**: Cloud Firestore (recommended) or Realtime Database

### Key Firebase Collections

1. **`users`**: User profiles (patients and therapists)
2. **`exercises`**: Available exercises for patients
3. **`exercise_scores`**: Patient exercise completion records

See `FIREBASE_SETUP.md` for detailed setup instructions.

## How It Works

### Authentication Flow

1. User signs up/logs in via `LoginScreen`
2. `AuthProvider` manages authentication state
3. Router redirects based on user role:
   - Patient → `/patient`
   - Therapist → `/therapist`

### Patient Flow

1. Patient logs in and sees available exercises
2. Selects an exercise to complete
3. Answers multiple-choice questions
4. Score is calculated and saved to Firebase
5. Feedback is shown immediately

### Therapist Flow

1. Therapist logs in and sees dashboard
2. Views list of all patients
3. Sees aggregated statistics (total exercises, average score, last activity)
4. Clicks on patient to see detailed progress
5. Views individual exercise scores and history

## Firebase Service Layer

The `FirebaseService` class provides all Firebase operations:

### Authentication
- `signInWithEmail()` - Sign in existing user
- `signUpWithEmail()` - Create new user account
- `signOut()` - Sign out current user

### User Operations
- `saveUser()` - Save user profile to Firestore
- `getUser()` - Retrieve user data

### Exercise Operations
- `getExercises()` - Get all available exercises
- `getExercise()` - Get specific exercise by ID

### Score Operations
- `saveExerciseScore()` - Save patient exercise result
- `getPatientScores()` - Get all scores for a patient
- `getPatientScoresStream()` - Real-time stream of patient scores

### Progress Operations
- `getTherapistPatients()` - Get all patients for a therapist
- `getPatientProgress()` - Get aggregated progress data
- `getPatientProgressStream()` - Real-time stream of patient progress

## Data Models

### UserModel
- `id`, `email`, `name`, `role` (patient/therapist), `createdAt`

### Exercise
- `id`, `title`, `description`, `type`, `options`, `correctAnswer`, `difficulty`

### ExerciseScore
- `id`, `patientId`, `exerciseId`, `score`, `maxScore`, `answer`, `correctAnswer`, `completedAt`, `metadata`

### PatientProgress
- `patientId`, `patientName`, `totalExercisesCompleted`, `averageScore`, `lastActivity`, `recentScores`, `scoresByExercise`

## Customization

### Adding More Exercises

Exercises are stored in Firestore collection `exercises`. Add new documents with:
- `id`: Unique exercise identifier
- `title`: Exercise name
- `description`: Instructions for the patient
- `type`: Exercise type (e.g., "word_recognition")
- `options`: Array of answer choices
- `correctAnswer`: The correct answer
- `difficulty`: 1-5 scale

### Styling

The app uses Material 3 design. Customize colors in `main.dart`:
```dart
colorScheme: ColorScheme.fromSeed(
  seedColor: Colors.blue, // Change this
),
```

## For Backend Developers

### Integration Points

1. **Firebase Configuration**: Set up Firebase project and configure FlutterFire
2. **Database Structure**: Create Firestore collections as described in `FIREBASE_SETUP.md`
3. **Security Rules**: Set up Firestore security rules for production
4. **Sample Data**: Add initial exercises to the database

### Service Layer

All Firebase operations are abstracted in `lib/services/firebase_service.dart`. The methods are ready to use with Firestore. If you need to use Realtime Database instead, modify the service methods accordingly.

### Real-time Updates

The app uses Firestore streams for real-time updates:
- `getPatientScoresStream()` - Updates when patient completes exercise
- `getPatientProgressStream()` - Updates when patient progress changes

Therapist dashboard automatically refreshes when patients complete exercises.

## Troubleshooting

### Firebase Not Initialized
- Run `flutterfire configure`
- Check that `firebase_options.dart` exists
- Verify Firebase initialization in `main.dart`

### No Exercises Showing
- Check Firestore `exercises` collection exists
- Verify security rules allow reading exercises
- Check user is authenticated

### Scores Not Saving
- Verify Firestore security rules allow writing to `exercise_scores`
- Check user is authenticated
- Verify `patientId` matches authenticated user ID

## Next Steps

1. ✅ Frontend UI complete
2. ⏳ Backend developer: Set up Firebase
3. ⏳ Backend developer: Add sample exercises
4. ⏳ Test end-to-end flow
5. ⏳ Add caregiver view (future)

## Dependencies

- `flutter`: SDK
- `provider`: State management
- `firebase_core`: Firebase initialization
- `firebase_auth`: Authentication
- `cloud_firestore`: Firestore database
- `firebase_database`: Realtime Database (alternative)
- `go_router`: Navigation
- `intl`: Date formatting

## License

This project is part of a hackathon submission.
