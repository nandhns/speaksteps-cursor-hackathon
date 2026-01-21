# Web Deployment Checklist - 24-Feature Model

## ✅ Pre-Deployment Status

### Frontend Code Updates
- [x] **cue_predictor_interface.dart** - Updated to 24 features
- [x] **cue_predictor_native.dart** - Updated for 24 features + scaler loading
- [x] **cue_predictor_web.dart** - Updated rule-based logic for 24 features
- [x] **writing_exercise_screen.dart** - Added 24-feature computation
- [x] **comprehension_exercise_screen.dart** - Added 24-feature computation
- [x] **scaler_params.json** - Copied to frontend/assets/ml/

### Model Artifacts
- [x] **model.tflite** - In frontend/assets/ml/
- [x] **model_float16.tflite** - In frontend/assets/ml/ (used by native predictor)
- [x] **model_metadata.json** - In frontend/assets/ml/ (24 features, 0.4 threshold)
- [x] **model.joblib** - In frontend/assets/ml/ (scaler extracted)
- [x] **scaler_params.json** - In frontend/assets/ml/ (24 values)
- [x] **feature_importance.csv** - In frontend/assets/ml/ (reference)

### Configuration Files
- [x] **pubspec.yaml** - Assets configured (assets/ml/, images/)
- [x] **firebase.json** - Web hosting configured for build/web
- [x] **l10n.yaml** - Localization configured
- [x] **analysis_options.yaml** - Linting configured

## 🔨 Web Build Process

### Build Status
- [ ] Web build in progress (running `flutter build web --release`)
- [ ] Assets will be copied to build/web/assets/ automatically
- [ ] Scaler file will be available at runtime

### Build Output Directory
- **Path**: `frontend/build/web/`
- **Expected Structure**:
  ```
  build/web/
  ├── assets/
  │   ├── images/
  │   └── ml/
  │       ├── model.tflite
  │       ├── model_float16.tflite
  │       ├── model_metadata.json
  │       ├── scaler_params.json
  │       └── ...
  ├── canvaskit/
  ├── flutter.js
  ├── flutter_bootstrap.js
  └── index.html
  ```

## 🚀 Firebase Deployment

### Pre-Deployment Checks
- [ ] Verify build/web exists and contains assets/ml/scaler_params.json
- [ ] Run: `firebase deploy --only hosting` from frontend directory
- [ ] Verify Firebase Hosting is active in project

### Deployment Command
```bash
cd frontend
firebase deploy --only hosting
```

### Post-Deployment Verification
- [ ] App loads at Firebase Hosting URL
- [ ] Network tab shows assets/ml/ files being loaded
- [ ] Console logs show "Scaler loaded: 24 means, 24 scales"
- [ ] ML predictions show difficulty scores (0-1), not binary
- [ ] Cue triggering works with 0.4 threshold

## 📋 Features Deployed

### 24-Feature Model Schema
1. responseTimeSeconds - Current response time
2. responseTimeRollingAvg - Rolling avg last 5 (NEW)
3. hintCount - Hints on current question
4. hintsUsedRatio - Cumulative hints normalized (NEW)
5. consecutiveIncorrect - Incorrect streak normalized (NEW)
6. consecutiveCorrect - Correct streak normalized (NEW)
7. difficultyFlag - Easy/hard (0/1)
8. deviceMobileFlag - Web/mobile (0/1)
9. therapistAssignedLevel - 1-5
10. questionTypeEncoded - 0-8
11. cueTypeEncoded - 0-7
12-15. time_morning/afternoon/evening/night (one-hot)
16-17. module_comprehension/writing (one-hot)
18-21. cat_animals/body_parts/clothing/food (one-hot)
22. exerciseDurationNormalized - Seconds/300
23. sessionProgressRatio - Current/total (NEW)
24. recentAccuracyRate - Rolling accuracy last 5 (NEW)

### Removed Features (Leakage Prevention)
- ❌ cueGiven (outcome variable)
- ❌ cueStage (outcome variable)
- ❌ correctBeforeCueFlag (outcome variable - caused alternating behavior)
- ❌ moduleDurationNormalized (outcome variable)
- ❌ cueSequenceNormalized (outcome variable)

### Model Performance
- **Accuracy**: 87.1%
- **Precision**: 94.1%
- **Recall**: 87.8%
- **F1**: 90.84%
- **AUC**: 93.83%
- **Threshold**: 0.4 (difficulty score ≥ 0.4 triggers cue)

## 🧪 Testing Checklist

### Web-Specific Tests
- [ ] Rule-based predictor working (no TFLite on web)
- [ ] 24-feature input correctly constructed
- [ ] Rolling features computed per-session
- [ ] Thresholds applied correctly (0.4)
- [ ] Debug logs show 24-feature schema
- [ ] No compilation errors in console
- [ ] Network requests for assets succeed

### Functional Tests
- [ ] Comprehension exercise starts without errors
- [ ] Writing exercise starts without errors
- [ ] First question: rolling avg = 0, recent acc = 0.5
- [ ] Second question: rolling features populate
- [ ] Cues appear after 10+ seconds (no alternating)
- [ ] Cue levels progress: functional → rhyming → written
- [ ] Streak tracking resets on correct/incorrect
- [ ] Session ends cleanly

## 📦 Deployment Files

### Source Files
- `frontend/lib/services/cue_predictor_interface.dart`
- `frontend/lib/services/cue_predictor_web.dart`
- `frontend/lib/services/cue_predictor_native.dart`
- `frontend/lib/screens/patient/writing_exercise_screen.dart`
- `frontend/lib/screens/patient/comprehension_exercise_screen.dart`

### Asset Files
- `frontend/assets/ml/model.tflite`
- `frontend/assets/ml/model_float16.tflite`
- `frontend/assets/ml/model_metadata.json`
- `frontend/assets/ml/model.joblib`
- `frontend/assets/ml/scaler_params.json` ← **NEW**
- `frontend/assets/ml/feature_importance.csv`

## ✨ Production Ready

All code updates are complete and assets are staged. The web build will automatically include all files from `assets/ml/` directory. After build completes, Firebase deployment will make the updated app live.

**Last Updated**: 2026-01-21
**Model Version**: 24-Feature Difficulty Estimator (trained with no leakage)
**Deployment Status**: Ready for Firebase Hosting
