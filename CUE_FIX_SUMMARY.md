# Cue Problem - Quick Fix Summary

## Issues Identified & Fixed

### 1. ✅ Cue-Type Encoding Mismatch (PRIMARY ISSUE)
**Problem:** Frontend was encoding cue types in wrong order vs backend:
- **Before:** `functional=1, modeling=2, phonemic=3, rhyming=4, sentence_completion=5, written_initial=7`
- **After:** `functional=1, rhyming=2, written_initial=3, spelling=4, sentence_completion=5, phonemic=6, modeling=7`

**Files Fixed:**
- ✅ `frontend/lib/services/cue_predictor_interface.dart`
- ✅ `frontend/lib/services/cue_predictor_web.dart`
- ✅ `frontend/lib/services/cue_predictor_tflite.dart.bak`

**Impact:** This was causing ML feature vectors to misclassify cue types (e.g., sending `rhyming` but model interprets as `modeling`).

---

### 2. ✅ Category Name Mapping
**Problem:** Database uses localized category names:
- `haiwan` (Bahasa Melayu) → should be `animals`
- `animal` (variant) → should be `animals`
- `bodyParts` → should be `body_parts`
- `pakaian` → should be `clothing`
- `makanan` → should be `food`

**Files Fixed:**
- ✅ `frontend/lib/screens/patient/comprehension_exercise_screen.dart`
- ✅ `frontend/lib/screens/patient/writing_exercise_screen.dart`

**Changes:** Added category mapping before ML feature preparation:
```dart
const categoryMap = {
  'haiwan': 'animals',
  'animal': 'animals',
  'bodyParts': 'body_parts',
  'pakaian': 'clothing',
  'makanan': 'food',
};
categoryName = categoryMap[categoryName] ?? categoryName;
```

**Impact:** ML model now receives correct category encoding (one-hot features for animals, body_parts, etc.).

---

### 3. ℹ️ Difficulty Format (No code change needed)
**Observation:** Database stores numeric difficulty (1=easy, 2=medium, 3=hard), but frontend already converts correctly:
```dart
difficulty: widget.exercise.difficulty >= 3 ? 'hard' : 'easy'
```
✅ **This is already working correctly.**

---

## Data Validation Results

```
Exercises: 17 | Questions: 40
✅ All questions have complete cueHierarchy keys
✅ All cue types present: functional, rhyming, written_initial, spelling, sentence_completion, phonemic, modeling
```

---

## What Was Broken

### Before Fix
1. User types slow response → Frontend sends "rhyming" as cue type
2. ML feature encoding: `'rhyming': 4`
3. Model trained on different encoding sees `4` as `sentence_completion`
4. Wrong cue displayed to patient

### After Fix
1. User types slow response → Frontend sends "rhyming" as cue type
2. ML feature encoding: `'rhyming': 2` (matches backend)
3. Model correctly interprets cue type
4. Correct cue displayed to patient

---

## Quick Testing

Run this to validate your data:
```bash
cd backend
python validate_cue_data.py
```

Test the backend rule engine:
```bash
python test_hierarchical_cueing.py
```

---

## Next Steps (Optional)

If you need deeper ML diagnostics, run backend test:
```bash
python -c "from cueing_engine import run_test_cases; run_test_cases()"
```

This will show:
- Rule-based decisions for 6 test scenarios
- ML predictions (if available)
- Hybrid logic results
