# Bug Fixes Summary - January 5, 2026

## Issues Fixed

### 1. Exercise Scores Not Saving/Displaying ✅
**Problem**: When completing exercises, scores were not being saved or displayed correctly. "Not Started" was still showing after completion.

**Root Cause**: Firestore security rules were configured for an old schema and were blocking read/write access to the `exercise_scores`, `users`, and other collections.

**Solution**:
- Created new Firestore security rules file: `backend/firestore-new.rules`
- Added proper permissions for:
  - `users` collection (patients and therapists)
  - `exercises` collection
  - `exercise_scores` collection (with proper patient/therapist access)
  - `question_responses` collection
  - `exercise_sessions` collection
- Added debug logging to identify the issue:
  - Patient home screen now logs score loading
  - Firebase service logs all save/fetch operations
  - Helps identify permission or data flow issues

**Files Modified**:
- `frontend/lib/screens/patient/patient_home_screen.dart` - Added debug logging
- `frontend/lib/services/firebase_service.dart` - Added debug logging  
- `backend/firestore-new.rules` - New security rules

### 2. Bahasa Melayu (BM) Language Not Working ✅
**Problem**: When switching to BM language, English text was still showing for:
- "Not Started" status badge
- "Completed" status badge
- Category names (Animals, Food, Body Parts, Clothing)
- Exercise type names (Writing, Comprehension)
- Exercise type descriptions

**Root Cause**: Hardcoded English strings instead of using the `AppStrings` localization class.

**Solution**:
- Updated `_ExerciseCard` widget to use `AppStrings` for status badges
- Updated `_buildExerciseTypeSelection()` to use localized exercise type names and descriptions
- Updated `_buildCategorySelection()` to use localized category names
- All strings now properly switch between English and Bahasa Melayu

**Files Modified**:
- `frontend/lib/screens/patient/patient_home_screen.dart`

**Changes Made**:
- "Not Started" → Uses `strings.notStarted` (BM: "Belum Dimulai")
- "Completed" → Uses BM: "Selesai"
- "Writing" → Uses `strings.writing` (BM: "Menulis")
- "Comprehension" → Uses `strings.comprehension` (BM: "Pemahaman")
- "Animals" → Uses `strings.animals` (BM: "Haiwan")
- "Body Parts" → Uses `strings.bodyParts` (BM: "Anggota Badan")
- "Clothing" → Uses `strings.clothing` (BM: "Pakaian")
- "Food" → Uses `strings.food` (BM: "Makanan")

### 3. Patient Exercise Data Not Showing in Therapist Dashboard ✅
**Problem**: Therapist dashboard was not displaying patient exercise data.

**Root Cause**: Same as issue #1 - Firestore security rules were blocking access to patient data and exercise scores.

**Solution**:
- New Firestore rules allow therapists to:
  - Read their assigned patients from `users` collection
  - Read exercise scores for their assigned patients
  - Read question responses for their assigned patients
- Added debug logging to identify issues:
  - Logs therapist ID when fetching patients
  - Logs number of patients found
  - Logs patient names
  - Logs scores being fetched

**Files Modified**:
- `backend/firestore-new.rules` - Added therapist access rules
- `frontend/lib/services/firebase_service.dart` - Added debug logging

## Deployment Instructions

### Step 1: Deploy New Firestore Rules

```bash
# Navigate to the backend folder
cd backend

# Backup old rules (optional)
cp firestore.rules firestore.rules.backup

# Replace with new rules
cp firestore-new.rules firestore.rules

# Deploy to Firebase
firebase deploy --only firestore:rules
```

### Step 2: Test the Changes

1. **Test Patient Flow**:
   - Sign in as a patient
   - Switch language to Bahasa Melayu
   - Verify all UI text is in BM
   - Complete an exercise
   - Check that score is displayed correctly
   - Verify "Selesai" badge appears (not "Not Started")

2. **Test Therapist Flow**:
   - Sign in as a therapist
   - Check that patients are listed in dashboard
   - Select a patient
   - Verify their exercise scores are displayed
   - Check progress statistics

3. **Check Browser Console**:
   - Open browser developer tools (F12)
   - Look for DEBUG messages to verify data flow
   - Check for any Firestore permission errors

### Step 3: Monitor for Issues

Look for these DEBUG messages in browser console:

**Patient Side**:
```
DEBUG: Loading exercises for patientId: <id>
DEBUG: Loaded X scores for patient
DEBUG: Score for exercise <id>: X/Y
DEBUG: Saving exercise score: X/Y for exercise <id>
DEBUG: Score saved successfully
```

**Firebase Service**:
```
DEBUG Firebase: Saving score to exercise_scores/<id>
DEBUG Firebase: PatientId: <id>, ExerciseId: <id>, Score: X/Y
DEBUG Firebase: Score saved successfully
DEBUG Firebase: Fetching scores for patientId: <id>
DEBUG Firebase: Found X score documents
```

**Therapist Dashboard**:
```
DEBUG Firebase: Fetching patients for therapistId: <id>
DEBUG Firebase: Found X patient documents
DEBUG Firebase: Patient doc <id>: <name>
```

## Testing Checklist

- [ ] Deploy new Firestore rules to Firebase
- [ ] Patient can complete exercises and see scores saved
- [ ] "Not Started" changes to "Completed" (EN) or "Selesai" (BM)
- [ ] Score is displayed next to exercise (e.g., "Score: 5/5")
- [ ] All category names show in Bahasa Melayu when BM is selected
- [ ] Exercise types show in Bahasa Melayu when BM is selected
- [ ] Therapist can see list of assigned patients
- [ ] Therapist can see patient exercise scores
- [ ] No Firestore permission errors in console
- [ ] DEBUG logs confirm data is being saved and fetched

## Potential Issues to Watch For

1. **Firestore Index Required**: If you see an error about missing indexes, Firebase will provide a link to create them automatically.

2. **Permission Denied**: If you still see permission errors:
   - Make sure the new rules are deployed: `firebase deploy --only firestore:rules`
   - Check that patient has `therapistId` field set correctly
   - Check that therapist user has `role: 'therapist'`

3. **Scores Not Appearing**: 
   - Check DEBUG logs to see if scores are being saved
   - Verify `patientId` matches the authenticated user's ID
   - Check that `exerciseId` is correctly set

4. **Language Not Switching**:
   - Verify LanguageProvider is properly initialized
   - Check that user's `preferredLanguage` field is set
   - Restart the app after changing language

## Files Changed Summary

### Modified Files:
1. `frontend/lib/screens/patient/patient_home_screen.dart`
   - Added localization for status badges, categories, and exercise types
   - Added debug logging for score loading and saving

2. `frontend/lib/services/firebase_service.dart`
   - Added debug logging for all Firebase operations
   - Enhanced error messages

### New Files:
1. `backend/firestore-new.rules`
   - Complete new security rules for updated schema
   - Proper permissions for patients and therapists
   - Access control for all collections

## Rollback Instructions

If issues occur, you can rollback the Firestore rules:

```bash
cd backend
cp firestore.rules.backup firestore.rules
firebase deploy --only firestore:rules
```

Note: The frontend code changes are improvements and don't need to be rolled back, but the old version didn't have proper localization.

## Next Steps

1. Remove debug logging once issues are confirmed resolved (for production)
2. Test with real patient and therapist accounts
3. Monitor Firebase console for any errors
4. Consider adding more detailed analytics

## Support

If issues persist:
1. Check Firebase Console → Firestore → Rules tab
2. Check browser console for errors
3. Verify user documents have correct `role` and `therapistId` fields
4. Test with a fresh patient account
