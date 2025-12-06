# Integration Status: ML Pipeline & Image Assets

## Summary

**❌ ML Pipeline**: NOT integrated into the UI  
**❌ Image Assets**: NOT being used in exercises

Both features exist in the codebase but are not connected to the actual exercise screens.

---

## 1. ML Pipeline Status

### ✅ What Exists
- **`frontend/lib/services/cue_predictor.dart`** - Complete TFLite inference service
- **`frontend/lib/widgets/cue_predictor_demo.dart`** - Demo widget for testing ML
- **TFLite models** in `frontend/assets/` (model.tflite, model_float16.tflite)

### ❌ What's Missing
- **ML is NOT used in exercise screens**
- Exercise screens (`writing_exercise_screen.dart`, `comprehension_exercise_screen.dart`) use a **simple timer-based cue system** instead
- The `CuePredictor` class is only used in the demo widget, not in actual exercises

### Current Cue System (What's Actually Used)
The exercise screens use a **timer-based approach**:
```dart
// From comprehension_exercise_screen.dart
_cueTimer = Timer(const Duration(seconds: 15), () {
  // Show function cue after 15 seconds
  _cueLevel = 1;
  _currentCue = currentQuestion.cueHierarchy?['function'];
  
  // Show rhyming cue after 10 more seconds
  // Show written cue after 10 more seconds
});
```

This is **NOT using the ML model** to predict when cues are needed.

---

## 2. Image Assets Status

### ✅ What Exists
- **40 image files** in `images/` folder:
  - 10 animals (dog, cat, bird, etc.)
  - 10 body parts (hand, foot, arm, etc.)
  - 10 clothing items (shirt, pants, dress, etc.)
  - 10 food items (apple, bread, milk, etc.)
- **Image mapping** in `backend/data/image_mapping.csv`
- **Exercise model** has `imageUrl` and `imageOptions` fields

### ❌ What's Missing
- **Images are NOT displayed** in exercises
- Exercise screens show **placeholder icons** instead of actual images
- Images are stored locally but not loaded as Flutter assets

### Current Image Display (What's Actually Shown)
```dart
// From comprehension_exercise_screen.dart (line 461-474)
Container(
  width: 70,
  height: 70,
  decoration: BoxDecoration(
    color: Colors.grey.shade300,
    shape: BoxShape.circle,
  ),
  child: Icon(
    Icons.image,  // ← Just a placeholder icon!
    size: 36,
    color: Colors.grey.shade600,
  ),
),
```

The writing exercise screen tries to load images from `imageUrl` using `Image.network()`, but:
- Images are local files, not network URLs
- They should use `Image.asset()` instead

---

## 3. What Needs to Be Done

### To Integrate ML Pipeline:

1. **Import CuePredictor in exercise screens:**
   ```dart
   import '../../services/cue_predictor.dart';
   ```

2. **Initialize and load the model:**
   ```dart
   final _predictor = CuePredictor();
   await _predictor.loadModel();
   ```

3. **Replace timer-based cues with ML predictions:**
   - Track user response time
   - Collect features (difficulty, category, time of day, etc.)
   - Call `_predictor.predict()` to determine if cue is needed
   - Show cues based on ML prediction instead of fixed timers

4. **Update cue timing logic:**
   ```dart
   // Instead of: Timer(Duration(seconds: 15), ...)
   // Use: ML prediction based on user behavior
   final input = CuePredictorInput.fromSimple(...);
   final result = _predictor.predict(input);
   if (result.needCue) {
     // Show appropriate cue
   }
   ```

### To Integrate Image Assets:

1. **Add images to `pubspec.yaml`:**
   ```yaml
   flutter:
     assets:
       - images/
       - images/animals/
       - images/body_parts/
       - images/clothing/
       - images/food/
   ```

2. **Update exercise model to use asset paths:**
   ```dart
   imageUrl: 'images/animals_dog.png'  // Instead of network URL
   ```

3. **Replace placeholder icons with actual images:**
   ```dart
   // Instead of:
   Icon(Icons.image, ...)
   
   // Use:
   Image.asset(
     'images/${category}_${item}.png',
     width: 70,
     height: 70,
     fit: BoxFit.cover,
   )
   ```

4. **Update mock service to use image paths:**
   - Map exercise questions to actual image files
   - Use the `image_mapping.csv` as reference

---

## 4. Files That Need Changes

### For ML Integration:
- `frontend/lib/screens/patient/writing_exercise_screen.dart`
- `frontend/lib/screens/patient/comprehension_exercise_screen.dart`

### For Image Integration:
- `frontend/pubspec.yaml` (add image assets)
- `frontend/lib/screens/patient/comprehension_exercise_screen.dart` (replace placeholders)
- `frontend/lib/screens/patient/writing_exercise_screen.dart` (use Image.asset)
- `frontend/lib/services/mock_service.dart` (add image paths to exercises)

---

## 5. Current Workflow

### What Happens Now:
1. User starts exercise
2. Timer counts down (15s → function cue, 10s → rhyming cue, 10s → written cue)
3. Images show as placeholder icons
4. User selects text labels, not images

### What Should Happen:
1. User starts exercise
2. **ML model tracks behavior** (response time, hesitation, etc.)
3. **ML predicts** when cue is needed (based on actual user performance)
4. **Real images** are displayed from assets
5. User selects actual images, not just text

---

## 6. Quick Fix Priority

### High Priority (Core Features):
1. ✅ **Add images to pubspec.yaml** - 5 minutes
2. ✅ **Replace icon placeholders with Image.asset()** - 30 minutes
3. ✅ **Update mock service with image paths** - 1 hour

### Medium Priority (Enhancement):
4. ⚠️ **Integrate ML pipeline** - 2-3 hours
   - Requires tracking user behavior
   - Need to collect features during exercise
   - Replace timer logic with ML predictions

### Low Priority (Nice to Have):
5. 🔄 **Optimize image loading** (caching, preloading)
6. 🔄 **Add image fallbacks** (if asset missing)

---

## Conclusion

The ML pipeline and image assets are **ready to use** but **not connected** to the UI. They exist as separate components that need integration work.

**Current State:**
- ML: ✅ Code exists, ❌ Not used
- Images: ✅ Files exist, ❌ Not displayed

**Next Steps:**
1. Integrate images first (easier, immediate visual improvement)
2. Then integrate ML pipeline (more complex, requires behavior tracking)

