# Mock Service vs Firebase Service

## Current Setup: Mock Service (Default)

✅ **The app works immediately without Firebase!**

The frontend uses a **Mock Service** by default, which means:
- No Firebase setup required
- Pre-loaded sample data
- Works offline
- Perfect for testing UI and functionality
- Data resets when app restarts (in-memory storage)

## How to Switch

### Using Mock (Current - No Setup)
```dart
// lib/services/app_service.dart
static const bool useFirebase = false; // ← Current setting
```

### Using Firebase (When Backend is Ready)
```dart
// lib/services/app_service.dart
static const bool useFirebase = true; // ← Change to true
```

Then follow `FIREBASE_SETUP.md` to configure Firebase.

## What's Included in Mock Service

### Pre-configured Users
- **Patient:** `patient@test.com` (any password works)
- **Therapist:** `therapist@test.com` (any password works)

### Sample Exercises
- Word Recognition exercise
- Sentence Completion exercise

### Sample Scores
- Patient has 2 completed exercises with scores
- Shows progress in therapist dashboard

## Architecture

The app uses a **service abstraction layer**:

```
App Code
   ↓
AppService (interface)
   ↓
ServiceFactory (chooses implementation)
   ↓
┌─────────────┬──────────────┐
│ MockService │ FirebaseService │
└─────────────┴──────────────┘
```

This means:
- All screens use `AppService` interface
- Switching between Mock and Firebase is just one line change
- No code changes needed in screens when switching

## Files Involved

- `lib/services/app_service.dart` - Interface and factory
- `lib/services/mock_service.dart` - Mock implementation
- `lib/services/firebase_service.dart` - Firebase implementation

## Benefits

1. **Development:** Test UI without backend setup
2. **Demo:** Show frontend functionality immediately
3. **Testing:** Easy to test with known data
4. **Flexibility:** Switch to Firebase when ready

## When to Use Each

### Use Mock When:
- ✅ Testing frontend UI
- ✅ Demonstrating to stakeholders
- ✅ Backend not ready yet
- ✅ Quick prototyping

### Use Firebase When:
- ✅ Backend is configured
- ✅ Need persistent data
- ✅ Need real-time updates
- ✅ Production deployment

## Testing Both

You can easily test both:
1. Test with Mock first (current setup)
2. Set up Firebase
3. Change `useFirebase = true`
4. Test with real Firebase
5. Switch back to Mock if needed

The app handles both seamlessly!

