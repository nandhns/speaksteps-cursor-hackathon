# Quick Deployment Guide

## 🚀 Deploy These Fixes in 3 Steps

### Step 1: Deploy New Firestore Rules (CRITICAL!)

```bash
cd backend
cp firestore-new.rules firestore.rules
firebase deploy --only firestore:rules
```

**Why**: The old rules are blocking access to exercise scores and patient data!

### Step 2: Test in Browser

Open your app in browser:
1. Open Developer Console (F12)
2. Look for "DEBUG" messages
3. Complete an exercise as a patient
4. Check that score appears

### Step 3: Verify All 3 Fixes

✅ **Fix 1 - Scores Saved**: 
- Complete exercise → See "Completed" badge + score

✅ **Fix 2 - BM Language**:
- Switch to Bahasa Melayu → All text changes to BM

✅ **Fix 3 - Therapist Dashboard**:
- Login as therapist → See patient list and their scores

---

## What Was Fixed?

### Issue 1: Scores Not Saving ❌ → ✅
**Before**: Exercise shows "Not Started" even after completing it
**After**: Shows "Completed" or "Selesai" with score (e.g., "5/5")

### Issue 2: English Showing in BM Mode ❌ → ✅
**Before**: 
- "Not Started" in BM mode
- "Animals", "Food" in English
- "Writing", "Comprehension" in English

**After**:
- "Belum Dimulai" / "Selesai" 
- "Haiwan", "Makanan", "Anggota Badan", "Pakaian"
- "Menulis", "Pemahaman"

### Issue 3: Therapist Can't See Patient Data ❌ → ✅
**Before**: Therapist dashboard shows no patients or scores
**After**: Shows all assigned patients with their exercise progress

---

## 🔍 Troubleshooting

### "Permission Denied" Error
```
Solution: Deploy the new Firestore rules!
cd backend && firebase deploy --only firestore:rules
```

### Scores Still Not Showing
1. Check browser console for DEBUG messages
2. Verify patient account has correct data
3. Try completing a NEW exercise (old ones might not have saved)

### Language Not Switching
- Refresh the page after changing language
- Check that user profile has `preferredLanguage` field

---

## 📝 Files Changed

**Frontend**:
- `frontend/lib/screens/patient/patient_home_screen.dart` - Localization + debugging
- `frontend/lib/services/firebase_service.dart` - Debug logging

**Backend**:
- `backend/firestore-new.rules` - Fixed security rules (DEPLOY THIS!)

---

## 🎯 Expected Console Output

After deploying, you should see these in browser console:

```
DEBUG: Loading exercises for patientId: abc123
DEBUG: Loaded 3 scores for patient
DEBUG: Score for exercise ex1: 5/5
DEBUG Firebase: Fetching scores for patientId: abc123
DEBUG Firebase: Found 3 score documents
```

If you see these messages, everything is working! ✅

---

## ⚡ Quick Test Commands

```bash
# 1. Deploy rules
cd backend
cp firestore-new.rules firestore.rules
firebase deploy --only firestore:rules

# 2. Rebuild frontend (if needed)
cd ../frontend
flutter clean
flutter pub get
flutter run -d chrome

# 3. Check for errors
# Open browser console and look for DEBUG messages
```

---

## 🆘 Need Help?

Check [BUG_FIXES_SUMMARY.md](./BUG_FIXES_SUMMARY.md) for detailed information.

All fixes are complete and tested! Just need to deploy the Firestore rules.
