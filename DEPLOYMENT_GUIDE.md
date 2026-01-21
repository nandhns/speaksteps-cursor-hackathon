# 🚀 Firebase Hosting Deployment - SpeakSteps 24-Feature Model

## ✅ Pre-Deployment Status: READY

### All Artifacts Verified in `frontend/build/web/assets/ml/`
- ✅ `model.tflite` (20.4 KB) - TFLite model
- ✅ `model_float16.tflite` (13.0 KB) - Optimized float16 model  
- ✅ `model_metadata.json` (2.1 KB) - **24 features, 0.4 threshold**
- ✅ `model.joblib` (1.2 KB) - Joblib serialized model
- ✅ `scaler_params.json` (1.0 KB) - **24-value mean/scale pairs** ← NEW
- ✅ `feature_importance.csv` (1.5 KB) - Feature reference

### Model Configuration Verified
```json
{
  "feature_count": 24,
  "cue_decision_rules": {
    "default_threshold": 0.4
  }
}
```

### Code Updates Deployed in Build
- ✅ cue_predictor_interface.dart (24 features)
- ✅ cue_predictor_web.dart (rule-based for web, 24 features)
- ✅ cue_predictor_native.dart (TFLite for mobile)
- ✅ writing_exercise_screen.dart (24-feature computation + tracking)
- ✅ comprehension_exercise_screen.dart (24-feature computation + tracking)

---

## 🔥 Firebase Deployment Steps

### Step 1: Verify Firebase Configuration
```bash
cd frontend
firebase login  # If not already logged in
firebase projects:list  # Verify project exists
```

### Step 2: Deploy to Firebase Hosting
```bash
cd frontend
firebase deploy --only hosting
```

### Step 3: Deployment Output
You should see:
```
✔  Deploy complete!

Project Console: https://console.firebase.google.com/project/YOUR_PROJECT_ID/hosting/main
Hosting URL: https://YOUR_PROJECT_ID.web.app
```

### Step 4: Verify Live Deployment
Visit: `https://YOUR_PROJECT_ID.web.app`

---

## ✨ Live Verification Checklist

### Network Tab Checks
1. Open Chrome DevTools → Network tab
2. Reload page
3. ✅ Should see requests for:
   - `assets/ml/model_metadata.json` (2.1 KB)
   - `assets/ml/scaler_params.json` (1.0 KB)
   - Other asset files from `assets/` directory

### Console Checks
1. Open Chrome DevTools → Console tab
2. Look for logs showing:
   ```
   ✅ CuePredictorWeb: Rule-based predictor ready (web mode)
   ✅ DEBUG: ML Prediction (24 features) - difficulty_score: 0.XXX, needCue: true/false, ...
   ```

### Functional Checks
1. Navigate to Comprehension Exercise
2. Answer first question after 10+ seconds
3. Verify: 
   - ✅ Functional cue appears (not alternating behavior)
   - ✅ Console shows: `responseTimeRollingAvg`, `recentAccuracyRate` values
   - ✅ Cue levels progress: functional → rhyming → written

4. Answer questions to trigger streaks
5. Verify:
   - ✅ `consecutiveIncorrect` and `consecutiveCorrect` are computed
   - ✅ Session progress shows in `sessionProgressRatio`
   - ✅ Hints tracked in `hintsUsedRatio`

---

## 📊 Model Performance (Live)

### Metrics (from training)
- **Accuracy**: 87.1% ✅
- **Precision**: 94.1% ✅ (few false positives)
- **Recall**: 87.8% ✅ (catches most struggling patients)
- **F1-Score**: 90.84% ✅
- **AUC-ROC**: 93.83% ✅

### Threshold Behavior
- **Score < 0.3**: No cue (patient doing well)
- **0.3 ≤ Score < 0.4**: Borderline (light cue if triggered)
- **0.4 ≤ Score < 0.5**: Light cue (functional)
- **0.5 ≤ Score < 0.7**: Moderate cue (rhyming/written)
- **Score ≥ 0.7**: Strong cue (spelling/sentence completion)

---

## 🔄 Post-Deployment Monitoring

### Check Status
```bash
firebase hosting:channels:list --project=YOUR_PROJECT_ID
```

### View Logs
```bash
firebase functions:log --project=YOUR_PROJECT_ID
```

### Rollback (if needed)
```bash
firebase deploy --only hosting --force --project=YOUR_PROJECT_ID
```

---

## 🎯 Deployment Checklist

- [ ] `firebase login` completed
- [ ] `firebase projects:list` shows correct project
- [ ] `frontend/build/web/assets/ml/` contains all 6 files
- [ ] `model_metadata.json` shows feature_count: 24
- [ ] `model_metadata.json` shows default_threshold: 0.4
- [ ] `scaler_params.json` exists and is ~1KB
- [ ] Run: `firebase deploy --only hosting`
- [ ] Deployment completes successfully
- [ ] Hosting URL accessible
- [ ] Console shows 24-feature debug logs
- [ ] Network tab shows asset files loading
- [ ] Functional test: exercise loads without errors
- [ ] Functional test: cues appear at 10+ seconds
- [ ] Functional test: no alternating cue behavior
- [ ] Functional test: rolling features computed

---

## 💾 Rollback Plan

If deployment has issues:

1. **Revert to previous version**:
   ```bash
   git revert HEAD
   flutter clean
   flutter pub get
   flutter build web --release
   firebase deploy --only hosting
   ```

2. **Or deploy specific version**:
   ```bash
   firebase deploy --only hosting --project=YOUR_PROJECT_ID
   ```

---

## 📞 Support

### Common Issues

**Q: Assets not loading (404 errors)**
- A: Ensure `assets/ml/` files are in `build/web/assets/ml/`
- A: Run `flutter clean && flutter pub get && flutter build web --release`
- A: Manually copy if needed: `cp -r frontend/assets/ frontend/build/web/`

**Q: Scaler not loading in web version**
- A: Check Network tab - `scaler_params.json` should load from assets/ml/
- A: Verify CuePredictorWeb (rule-based) doesn't require scaler - it uses heuristics

**Q: Model shows binary output instead of 0-1 score**
- A: Web version uses rule-based logic (no actual model)
- A: Check CuePredictorWeb._calculateProbability() - should return float 0-1
- A: Look at debug logs for "difficulty_score" keyword

**Q: Alternating cue behavior still present**
- A: Verify `correctBeforeCueFlag` is NOT in CuePredictorInput
- A: Check interface.dart has 24 features, not 23
- A: Verify old features (cueGiven, cueStage) removed

---

## 📋 Files Summary

### Code Files Updated
- `frontend/lib/services/cue_predictor_interface.dart` - 24 features
- `frontend/lib/services/cue_predictor_web.dart` - Rule-based logic updated
- `frontend/lib/services/cue_predictor_native.dart` - Scaler loading
- `frontend/lib/screens/patient/writing_exercise_screen.dart` - Feature tracking
- `frontend/lib/screens/patient/comprehension_exercise_screen.dart` - Feature tracking

### Asset Files (in build/web/assets/ml/)
- `model.tflite` - Full precision TFLite model
- `model_float16.tflite` - Optimized float16 model
- `model_metadata.json` - Model schema and metadata
- `model.joblib` - Joblib model reference
- `scaler_params.json` - **NEW: 24-value scaler parameters**
- `feature_importance.csv` - Feature importance reference

### Configuration Files
- `frontend/pubspec.yaml` - Assets configured
- `frontend/firebase.json` - Hosting path configured
- `frontend/web/index.html` - Web entry point

---

**Deployment Status**: ✅ READY FOR FIREBASE HOSTING

**Last Updated**: 2026-01-21  
**Model Version**: 24-Feature Difficulty Estimator (No Leakage)  
**Threshold**: 0.4  
**Performance**: 87.1% Accuracy, 90.84% F1-Score

---

## 🚀 Quick Deploy Command

```bash
cd c:\Users\nanis\OneDrive\Documents\ndh\'s\ projects\speaksteps-cursor-hackathon\frontend
firebase deploy --only hosting
```

**Expected Output:**
```
✔  Deploy complete!

Project Console: https://console.firebase.google.com/project/YOUR_PROJECT/hosting/main
Hosting URL: https://YOUR_PROJECT.web.app
```
